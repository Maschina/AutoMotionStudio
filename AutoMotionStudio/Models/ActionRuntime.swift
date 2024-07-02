//
//  ActionRuntime.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 28.06.24.
//

import Foundation
import SwiftData
import KeyboardShortcuts

/// Model to execute actions in the respective order
@Observable
class ActionRuntime {
	/// Indicates if action runtime is running
	private(set) var isExecuting: Bool = false
	
	private var executionTask: Task<Void, any Error>?
	
	init() {
		Task { [weak self] in
			for await event in KeyboardShortcuts.events(for: .stopActionExecution) where event == .keyUp {
				self?.cancelActions()
			}
		}
	}
	
	/// Start execution of the given actions
	/// - Parameter actions: List actions to be executed
	func execute(_ actions: Actions) {
		print("Executing \(actions.count) actions…")
		
		self.executionTask?.cancel()
		isExecuting = true
		
		self.executionTask = Task { [actions, weak self] in
			let startTime = CFAbsoluteTimeGetCurrent()

			for action in actions {
				try Task.checkCancellation()
				try await Task.sleep(milliseconds: Int(action.delay * 1000))
				action.execute()
			}
			
			self?.isExecuting = false
			
			let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
			print("Completed execution in \(timeElapsed) seconds.")
		}
	}
	
	/// Immediately stop the current execution of the previously given action list
	func cancelActions() {
		self.executionTask?.cancel()
		self.isExecuting = false
		print("Cancelled execution.")
	}
}
