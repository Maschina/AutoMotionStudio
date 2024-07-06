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
	@State private var sequenceRunner = SequenceRunModel.shared
	
	@MainActor
	var body: some ToolbarContent {
		// toolbar item to add new action
		ToolbarItemGroup(placement: .primaryAction) {
			Spacer(minLength: 0)
			Menu {
				Button(insertAction: .linearMove, sequence: nil, modelContext: modelContext)
				Divider()
				Button(insertAction: .primaryClick, sequence: nil, modelContext: modelContext)
				Button(insertAction: .secondaryClick, sequence: nil, modelContext: modelContext)
				Button(insertAction: .dragStart, sequence: nil, modelContext: modelContext)
				Button(insertAction: .dragEnd, sequence: nil, modelContext: modelContext)
			} label: {
				Label("Add Action", systemImage: "plus")
			}
			.menuIndicator(.hidden)
			.disabled(sequenceRunner.isExecuting)
		}
		
		if !sequenceRunner.isExecuting {
			// default list of toolbar items
			ToolbarItemGroup(placement: .navigation) {
				Button("Run", systemImage: "play.fill") {
					sequenceRunner.run(actions)
				}
			}
		} else {
			// list of toolbar items during execution of ActionRuntime
			ToolbarItemGroup(placement: .navigation) {
				Button("Stop", systemImage: "stop.fill") {
					sequenceRunner.stop()
				}
				
				if let shortcutDescription = KeyboardShortcuts.getShortcut(for: .stopActionExecution)?.description {
					Text("Press \(shortcutDescription) to stop execution")
						.font(.footnote)
				}
			}
		}
	}
}
