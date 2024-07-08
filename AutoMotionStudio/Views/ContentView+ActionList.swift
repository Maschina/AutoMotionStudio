//
//  ContentView+ActionList.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 05.07.24.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts
import TipKit

extension ContentView {
	struct ActionList: View {
		let selectedSequence: Sequence?
		/// Multiple selections the user can choose from the content list
		@Binding var selectedActions: Set<Action>
		/// Model to run all actions
		@State private var sequenceRunner = SequenceRunModel.shared
		
		@Environment(\.modelContext) private var modelContext
		@Query(animation: .default) private var actions: [Action]
		
		init(selectedSequence: Sequence?, selectedActions: Binding<Set<Action>>) {
			self._selectedActions = selectedActions
			self.selectedSequence = selectedSequence
			
			let selectedSequenceId = selectedSequence?.id
			let predicate = #Predicate<Action> {
				$0.sequence?.id == selectedSequenceId
			}
			self._actions = Query(filter: predicate, sort: \Action.listIndex, animation: .default)
		}
		
		// MARK: Body
		
		var body: some View {
			if let selectedSequence {
				List(selection: $selectedActions) {
					ForEach(actions) { action in
						ActionRowView(
							type: action.type,
							listIndex: action.listIndex,
							mouseEasing: action.mouseEasing,
							delay: action.delay
						)
						.padding(.vertical, 3)
						.tag(action)
						.contextMenu {
							contextMenu(focusAction: action)
						}
					}
					.onMove(perform: onMove)
					.onDelete(perform: onDelete)
				}
				.focusedValue(\.delete, { delete(selectedActions) })
				.toolbar {
					Toolbar(
						selectedSequence: selectedSequence,
						selectedActions: $selectedActions,
						sequenceRunner: sequenceRunner,
						actions: actions
					)
				}
			} else {
				// no selection
				Text("No Sequence Selected")
					.font(.largeTitle)
					.fontWeight(.light)
					.multilineTextAlignment(.center)
					.foregroundStyle(Color.secondary)
					.padding(.horizontal, 30)
			}
		}
	}
}

// MARK: Context menu

extension ContentView.ActionList {
	@ViewBuilder
	func contextMenu(focusAction: Action) -> some View {
		if selectedActions.contains(focusAction), selectedActions.count > 1 {
			Section("\(selectedActions.count) Items Selected") {
				Divider()
				
				Button("Preview Selected Actions", systemImage: "play.fill") {
					sequenceRunner.run(selectedActions.sorted(by: \.listIndex, <))
				}
				.keyboardShortcut("r", modifiers: [.command, .shift])
				
				Divider()
				
				Button("Delete", systemImage: "trash") {
					delete(selectedActions)
				}
			}
		} else {
			Button("Preview Action", systemImage: "play.fill") {
				sequenceRunner.run([focusAction])
			}
			.keyboardShortcut("r", modifiers: [.command, .shift])
			
			Divider()
			
			Button("Delete", systemImage: "trash") {
				delete([focusAction])
			}
			.keyboardShortcut(.delete)
		}
	}
}

// MARK: Toolbar

extension ContentView.ActionList {
	struct Toolbar: ToolbarContent {
		let selectedSequence: Sequence
		@Binding var selectedActions: Set<Action>
		let sequenceRunner: SequenceRunModel
		let actions: [Action]
		
		@Environment(\.modelContext) private var modelContext
		
		/// Shortcut Tip to stop execution
		private let stopActionShortcutTip = StopActionShortcutTip()
		
		var body: some ToolbarContent {
			// add action button
			ToolbarItem(placement: .confirmationAction) {
				Menu {
					Button(insertAction: .linearMove, sequence: selectedSequence, modelContext: modelContext, selectedActions: $selectedActions)
					Divider()
					Button(insertAction: .primaryClick, sequence: selectedSequence, modelContext: modelContext, selectedActions: $selectedActions)
					Button(insertAction: .secondaryClick, sequence: selectedSequence, modelContext: modelContext, selectedActions: $selectedActions)
					Button(insertAction: .dragStart, sequence: selectedSequence, modelContext: modelContext, selectedActions: $selectedActions)
					Button(insertAction: .dragEnd, sequence: selectedSequence, modelContext: modelContext, selectedActions: $selectedActions)
				} label: {
					Label("Add Action", systemImage: "plus")
				}
				.menuIndicator(.hidden)
				.disabled(sequenceRunner.isExecuting)
			}
			
			if !sequenceRunner.isExecuting {
				// runner play button
				ToolbarItem(placement: .primaryAction) {
					Button("Run", systemImage: "play.fill") {
						sequenceRunner.run(actions)
					}
					// Avoid animation
					.transaction { $0.animation = nil }
					.disabled(actions.isEmpty)
				}
			} else {
				// runner stop button
				ToolbarItem(placement: .primaryAction) {
					Button("Stop", systemImage: "stop.fill") {
						sequenceRunner.stop()
					}
					.popoverTip(stopActionShortcutTip, arrowEdge: .trailing)
					.task {
						try? Tips.configure()
					}
				}
			}
		}
	}
}

// MARK: List actions

extension ContentView.ActionList {
	private func onMove(indices: IndexSet, newOffset: Int) {
		var s = actions
		s.move(fromOffsets: indices, toOffset: newOffset)
		// make sure to re-order the list indicies
		s.reorder(keyPath: \.listIndex)
	}
	
	private func onDelete(indices: IndexSet) {
		withAnimation {
			for i in indices {
				let action = actions[i]
				modelContext.delete(action)
				selectedActions.remove(action)
			}
			// save before moving ahead with other modifications
			try? modelContext.save()
			
			// make sure to re-order the list indicies
			var s = actions
			s.reorder(keyPath: \.listIndex)
		}
	}
	
	private func delete(_ actions: Set<Action>) {
		withAnimation {
			for action in actions {
				modelContext.delete(action)
				selectedActions.remove(action)
			}
			// save before moving ahead with other modifications
			try? modelContext.save()
			
			// make sure to re-order the list indicies
			var s = self.actions
			s.reorder(keyPath: \.listIndex)
		}
	}
	
	private func delete(_ actions: [Action]) {
		delete(Set(actions))
	}
}
