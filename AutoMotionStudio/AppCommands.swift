//
//  CommandGroup.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 02.07.24.
//

import SwiftUI
import SwiftData

struct AppCommands: Commands {
	let pasteboardModel: PasteboardModel
	@Binding var selectedActions: Set<Action>
	
	@Environment(\.modelContext) private var modelContext
	/// List of actions from persistent data source
	@Query(sort: \Action.listIndex) private var actions: [Action]
	
	var body: some Commands {
		// replacing copy/paste with custom actions since copyable in NavigationSplitView does not work currently
		CommandGroup(replacing: .pasteboard) {
			// copy action
			Button("Copy") {
				pasteboardModel.copy(selectedActions)
			}
			.keyboardShortcut("c")
			.disabled(selectedActions.isEmpty)
			
			// paste action
			Button("Paste") {
				pasteboardModel.paste(behind: selectedActions)
			}
			.keyboardShortcut("v")
			.disabled(selectedActions.isEmpty || !pasteboardModel.hasCopiedActions)
			
			// duplicate action
			Button("Duplicate") {
				pasteboardModel.duplicate(selectedActions)
			}
			.keyboardShortcut("d")
			.disabled(selectedActions.isEmpty)
			
			// delete action
			Button("Delete") {
				deleteSelectedAction()
			}
			.keyboardShortcut(.delete)
			.disabled(selectedActions.isEmpty)
			
			Divider()
			
			// "select all" action
			Button("Select All") {
				selectAll()
			}
			.keyboardShortcut("a")
			.disabled(selectedActions.isEmpty)
		}
	}
}

extension AppCommands {
	func selectAll() {
		selectedActions = Set(actions)
	}
	
	func deleteSelectedAction() {
		for selectedAction in selectedActions {
			modelContext.delete(selectedAction)
			selectedActions.remove(selectedAction)
		}
		// save before moving ahead with other modifications
		try? modelContext.save()
		
		// make sure to re-order the list indicies
		var s = actions
		s.reorder(keyPath: \.listIndex)
	}
}
