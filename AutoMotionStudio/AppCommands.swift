//
//  CommandGroup.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 02.07.24.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

struct AppCommands: Commands {
	let pasteboardModel: PasteboardModel
	@Binding var selectedActions: Set<Action>
	
	@Environment(\.modelContext) private var modelContext
	/// List of actions from persistent data source
	@Query(sort: \Action.listIndex) private var actions: [Action]
	/// Model to run all actions
	@State private var sequence = SequenceModel.shared
	
	/// Indicating if there are any undo operations in the stack
	@State private var canUndo: Bool = false
	/// Notification being fired when UndoManager closes a undo group
	private let undoObserver = NotificationCenter.default.publisher(for: .NSUndoManagerDidCloseUndoGroup)
//	private let undoChange = NotificationCenter.default.publisher(for: .NSUndoManagerDidUndoChange)
	
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
		
		CommandMenu("Sequence") {
			Button("Run All Actions") {
				sequence.execute(actions)
			}
			.keyboardShortcut("r", modifiers: .command)
			.disabled(sequence.isExecuting)
			
			Button("Run Selected Actions") {
				sequence.execute(selectedActions.sorted(by: \.listIndex, <))
			}
			.keyboardShortcut("r", modifiers: [.command, .shift])
			.disabled(selectedActions.isEmpty || sequence.isExecuting)
			
			Divider()
			
			Button("Stop") {
				sequence.stop()
			}
			.keyboardShortcut(.stopActionExecution)
		}
	}
}

extension AppCommands {
	func selectAll() {
		selectedActions = Set(actions)
	}
	
	func deleteSelectedAction() {
		// delete action
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
