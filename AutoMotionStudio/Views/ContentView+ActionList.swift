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
		/// Shortcut Tip to stop execution
		private let stopActionShortcutTip = StopActionShortcutTip()
		/// Model to run all actions
		@State private var sequenceRunner = SequenceRunModel.shared
		
		@Environment(\.modelContext) private var modelContext
		@Query private var actions: [Action]
		
		init(selectedSequence: Sequence?, selectedActions: Binding<Set<Action>>) {
			self.selectedSequence = selectedSequence
			self._selectedActions = selectedActions
			
			let selectedSequenceId = selectedSequence?.id
			let predicate = #Predicate<Action> {
				$0.sequence?.id == selectedSequenceId
			}
			self._actions = Query(filter: predicate, sort: \Action.listIndex, animation: .default)
		}
		
		var body: some View {
			if selectedSequence != nil {
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
					}
					.onMove(perform: onMove)
					.onDelete(perform: onDelete)
				}
				.focusedValue(\.delete, deleteSelectedActions)
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Menu {
							Button(insertAction: .linearMove, sequence: selectedSequence, modelContext: modelContext)
							Divider()
							Button(insertAction: .primaryClick, sequence: selectedSequence, modelContext: modelContext)
							Button(insertAction: .secondaryClick, sequence: selectedSequence, modelContext: modelContext)
							Button(insertAction: .dragStart, sequence: selectedSequence, modelContext: modelContext)
							Button(insertAction: .dragEnd, sequence: selectedSequence, modelContext: modelContext)
						} label: {
							Label("Add Action", systemImage: "plus")
						}
						.menuIndicator(.hidden)
					}
					
					if !sequenceRunner.isExecuting {
						ToolbarItem(placement: .primaryAction) {
							Button("Run", systemImage: "play.fill") {
								sequenceRunner.run(actions)
							}
						}
					} else {
						ToolbarItem(placement: .primaryAction) {
							Button("Stop", systemImage: "stop.fill") {
								sequenceRunner.stop()
							}
							.popoverTip(stopActionShortcutTip)
							.task {
								try? Tips.configure()
							}
						}
					}
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

extension ContentView.ActionList {
	private func onMove(indices: IndexSet, newOffset: Int) {
		var s = actions
		s.move(fromOffsets: indices, toOffset: newOffset)
		// make sure to re-order the list indicies
		s.reorder(keyPath: \.listIndex)
	}
	
	private func onDelete(indices: IndexSet) {
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
	
	private func deleteSelectedActions() {
		withAnimation {
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
}

// MARK: Shortcut Tip for Stop Execution

extension ContentView.ActionList {
	struct StopActionShortcutTip: Tip {
		@MainActor
		var title: Text {
			Text("Keyboard Shortcut")
		}
		
		@MainActor
		var message: Text? {
			Text("Press \(KeyboardShortcuts.getShortcut(for: .stopActionExecution)?.description ?? "?") to stop execution")
		}
		
		var image: Image? {
			Image(systemName: "keyboard")
		}
	}
}
