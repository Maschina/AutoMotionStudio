//
//  ContentView.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

/// Main view containing the navigation split view
struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.undoManager) var undoManager
	/// List of actions from persistent data source
	@Query(sort: \Action.listIndex) private var actions: [Action]
	/// Selected sequence from the sidebar
	@State private var selectedSequence: Sequence?
	/// Multiple selections the user can choose from the content list
	@State private var selectedActions: Set<Action> = []
	
	@FocusedValue (\.delete) var delete
	
    var body: some View {
		NavigationSplitView {
			SequenceList(
				selectedSequence: $selectedSequence
			)
			.frame(minWidth: 190, idealWidth: 200)
		} content: {
			ActionList(
				selectedSequence: selectedSequence,
				selectedActions: $selectedActions
			)
			.frame(minWidth: 190, idealWidth: 200)
		} detail: {
			Detail(
				selectedActions: $selectedActions
			)
		}
		// perform actions when user presses ⌫ key
		.onDeleteCommand(perform: delete)
		// receive notification that selections has been changed
		.onReceive(for: .selectionsChanged) { newValue in
			selectedActions = newValue
		}
		// send notification that selections has been changed
		.onChange(of: selectedActions) {
			NotificationCenter.default.post(.selectionsChanged, data: selectedActions)
		}
		// instantiating UndoManager
		.onChange(of: undoManager, initial: true) {
			modelContext.undoManager = undoManager
		}
		// keyboard shortcut observer for setting current mouse coordinates
		.task {
			for await event in KeyboardShortcuts.events(for: .getCurrentMouseCoordinates) where event == .keyUp {
				for selectedAction in selectedActions {
					selectedAction.setCurrentMouseCoordinates()
				}
			}
		}
	}
	
	var deleteSelectedActionsToolbar: some ToolbarContent {
		ToolbarItem(placement: .destructiveAction) {
			Button("Delete", systemImage: "trash") {
				deleteSelectedActions()
			}
		}
	}
}

extension ContentView {
	private func deleteSelectedActions() {
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

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: Action.self, configurations: config)
	
    return ContentView()
		.modelContainer(container)
}
