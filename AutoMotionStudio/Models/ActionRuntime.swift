//
//  ActionRuntime.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 28.06.24.
//

import Foundation

struct ActionRuntime {
	private(set) var actions: Actions = .init()
	var isExecuting: Bool = false
	
	private var executionTask: Task<Void, any Error>?
	
	mutating func execute(with newActions: Actions) async {
		actions = newActions
		
		print("Executing actions…")
		
		cancelActions()
		isExecuting = true
		
		for action in actions {
			try? Task.checkCancellation()
			try? await Task.sleep(milliseconds: Int(action.delay * 1000))
			action.execute()
		}
		
		isExecuting = false
		
		print("Completed run")
	}
	
	mutating private func cancelActions() {
		self.executionTask?.cancel()
		self.isExecuting = false
	}
}
