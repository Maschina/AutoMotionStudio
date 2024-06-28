//
//  ContentViewToolbar.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import SwiftUI
import SwiftData

struct ContentViewToolbar: ToolbarContent {
	@Environment(\.modelContext) var modelContext
	@Query(sort: \Action.listIndex) var actions: [Action]
	
	@State private var runtime = ActionRuntime()
	@State private var runtimeTask: Task<Void, Never>? = nil
	
	var body: some ToolbarContent {
		ToolbarItem(placement: .navigation) {
			if !runtime.isExecuting {
				Button("Run", systemImage: "play.fill") {
					runtimeTask = Task {
						await runtime.execute(with: actions)
					}
				}
			} else {
				Button("Stop", systemImage: "stop.fill") {
					runtimeTask?.cancel()
					runtime.isExecuting = false
				}
			}
		}
		
		ToolbarItemGroup(placement: .primaryAction) {
			Spacer(minLength: 0)
			Menu {
				Button(actionType: .linearMove, modelContext: modelContext)
				Divider()
				Button(actionType: .primaryClick, modelContext: modelContext)
				Button(actionType: .secondaryClick, modelContext: modelContext)
				Button(actionType: .dragStart, modelContext: modelContext)
				Button(actionType: .dragEnd, modelContext: modelContext)
			} label: {
				Label("Add Action", systemImage: "plus")
			}
			.menuIndicator(.hidden)
		}
	}
}

extension Button where Label == Text {
	init(actionType: ActionType, modelContext: ModelContext) {
		self.init(actionType.description) {
			let action = Action(type: actionType)
			modelContext.insert(action)
		}
	}
}
