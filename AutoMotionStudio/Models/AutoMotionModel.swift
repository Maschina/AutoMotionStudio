//
//  ActionViewModel.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import Foundation
import KeyboardShortcuts

@Observable
class AutoMotionModel {
	var actions: [Action] = []
	var selectedAction: Action?
	
	private var executionTask: Task<Void, Never>?
	
	init() {
		initKeyboardObserver()
	}
	
	private func initKeyboardObserver() {
		Task {
			for await event in KeyboardShortcuts.events(for: .getCurrentMouseCoordinates) where event == .keyUp {
				selectedAction?.setCurrentMouseCoordinates()
			}
		}
	}
	
	@discardableResult
	func addAction(type: ActionType) -> Action {
		let newAction = Action(type: type)
		actions.append(newAction)
		return newAction
	}
	
	func executeActions() {
		executionTask = Task { [weak self] in
			for action in self?.actions ?? [] {
				try? Task.checkCancellation()
				action.execute()
				try? await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
			}
		}
	}
	
	func cancelActions() {
		executionTask?.cancel()
	}
}
