//
//  ContentViewToolbar.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

/// Default toolbar content
struct ContentViewToolbar: ToolbarContent {
	@Environment(\.modelContext) private var modelContext
	/// List of actions from persistent data source
	@Query(sort: \Action.listIndex) private var actions: [Action]
	/// Model to run all actions
	@State private var runtime = ActionRuntime()
	
	@MainActor
	var body: some ToolbarContent {
		// toolbar item to add new action
		ToolbarItemGroup(placement: .primaryAction) {
			Spacer(minLength: 0)
			Menu {
				Button(insertAction: .linearMove, modelContext: modelContext)
				Divider()
				Button(insertAction: .primaryClick, modelContext: modelContext)
				Button(insertAction: .secondaryClick, modelContext: modelContext)
				Button(insertAction: .dragStart, modelContext: modelContext)
				Button(insertAction: .dragEnd, modelContext: modelContext)
			} label: {
				Label("Add Action", systemImage: "plus")
			}
			.menuIndicator(.hidden)
			.disabled(runtime.isExecuting)
		}
		
		if !runtime.isExecuting {
			// default list of toolbar items
			ToolbarItemGroup(placement: .navigation) {
				Button("Run", systemImage: "play.fill") {
					runtime.execute(actions)
				}
				
//				Button("Export", systemImage: "square.and.arrow.up") {
//					
//				}
			}
		} else {
			// list of toolbar items during execution of ActionRuntime
			ToolbarItemGroup(placement: .navigation) {
				Button("Stop", systemImage: "stop.fill") {
					runtime.cancelActions()
				}
				
				if let shortcutDescription = KeyboardShortcuts.getShortcut(for: .stopActionExecution)?.description {
					Text("Press \(shortcutDescription) to stop execution")
						.font(.footnote)
				}
			}
		}
	}
}

extension Button where Label == Text {
	/// Button init to directly add a new action into the model context
	init(insertAction: ActionType, modelContext: ModelContext) {
		self.init(insertAction.description) {
			let actions = try? modelContext.fetch(FetchDescriptor<Action>())
			let listIndexMax = actions?.map(\.listIndex).max()
			
			let listIndex = if let listIndexMax { listIndexMax + 1 } else { 0 }
			let action = Action.new(
				type: insertAction,
				listIndex: listIndex
			)
			modelContext.insert(action)
		}
	}
}
