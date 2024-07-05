//
//  ContentView+ActionList.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 05.07.24.
//

import SwiftUI
import SwiftData

extension ContentView {
	struct ActionList: View {
		/// Multiple selections the user can choose from the content list
		@Binding var selectedActions: Set<Action>
		
		@Environment(\.modelContext) private var modelContext
		@Query private var actions: [Action]
		
		init(selectedSequence: Sequence?, selectedActions: Binding<Set<Action>>) {
			self._selectedActions = selectedActions
			
			let selectedSequenceId = selectedSequence?.id
			let predicate = #Predicate<Action> {
				$0.sequence?.id == selectedSequenceId
			}
			self._actions = Query(filter: predicate, sort: \Action.listIndex, animation: .default)
		}
		
		var body: some View {
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
}
