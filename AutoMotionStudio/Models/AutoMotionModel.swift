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
	var isExecuting: Bool = false
	
	private var executionTask: Task<Void, any Error>?
	
	init() {
		initKeyboardObserver()
	}
	
	private func initKeyboardObserver() {
		Task { [weak self] in
			for await event in KeyboardShortcuts.events(for: .getCurrentMouseCoordinates) where event == .keyUp {
				self?.selectedAction?.setCurrentMouseCoordinates()
			}
		}
		
		Task { [weak self] in
			for await event in KeyboardShortcuts.events(for: .stopRun) where event == .keyUp {
				self?.cancelActions()
			}
		}
	}
	
	@discardableResult
	func addAction(type: ActionType) -> Action {
		let newAction = Action(type: type)
		actions.append(newAction)
		return newAction
	}
	
	func cancelActions() {
		self.executionTask?.cancel()
		self.isExecuting = false
	}
	
	func executeActions() {
		print("Executing actions…")
		
		self.cancelActions()
		self.isExecuting = true
		
		self.executionTask = Task { [weak self] in
			for action in self?.actions ?? [] {
				try Task.checkCancellation()
				try await Task.sleep(duration: action.delay)
				action.execute()
			}
			
			self?.isExecuting = false
			
			print("Completed run")
		}
	}
}
