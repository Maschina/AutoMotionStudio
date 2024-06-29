//
//  ContentViewToolbar.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

struct ContentViewToolbar: ToolbarContent {
	@Environment(\.modelContext) private var modelContext
	@State private var runtime = ActionRuntime()
	
	@Query(sort: \Action.listIndex) private var actions: [Action]
	
	@MainActor
	var shortcutDescriptionStopActionExecution: String? {
		guard let shortcut = KeyboardShortcuts.getShortcut(for: .stopActionExecution) else {
			return nil
		}
		return shortcut.description
	}
	
	@MainActor
	var body: some ToolbarContent {
		if !runtime.isExecuting {
			ToolbarItemGroup(placement: .navigation) {
				Button("Run", systemImage: "play.fill") {
					runtime.execute(actions)
				}
				
//				Button("Export", systemImage: "square.and.arrow.up") {
//					
//				}
			}
		} else {
			ToolbarItemGroup(placement: .navigation) {
				Button("Stop", systemImage: "stop.fill") {
					runtime.cancelActions()
				}
				
				if let shortcutDescriptionStopActionExecution {
					Text("Press \(shortcutDescriptionStopActionExecution) to stop execution")
						.font(.footnote)
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
			.disabled(runtime.isExecuting)
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
