//
//  ContentView.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

struct ContentView: View {
	@Environment(\.modelContext) var modelContext
	@Query(sort: \Action.listIndex, animation: .default) var actions: [Action]
	@State private var selectedAction: Action?
	
    var body: some View {
		NavigationSplitView {
			List(selection: $selectedAction) {
				ForEach(actions) { action in
					ActionListElement(action: action)
						.padding(.vertical, 3)
						.tag(action)
				}
				.onMove(perform: onMove)
				.onDelete(perform: onDelete)
			}
			.frame(minWidth: 180, idealWidth: 200)
			.toolbar {
				ContentViewToolbar()
			}
		} detail: {
			if let selectedAction = selectedAction {
				ActionDetailView(action: selectedAction)
					.toolbar {
						ToolbarItem(placement: .destructiveAction) {
							Button("Delete", systemImage: "trash") {
								deleteSelectedAction()
							}
						}
					}
			} else {
				Text("Select Action")
					.foregroundColor(.gray)
			}
		}
		.onDeleteCommand {
			deleteSelectedAction()
		}
		.task {
			for await event in KeyboardShortcuts.events(for: .getCurrentMouseCoordinates) where event == .keyUp {
				self.selectedAction?.setCurrentMouseCoordinates()
			}
		}
    }
	
	private func onMove(indices: IndexSet, newOffset: Int) {
		var s = actions.sorted(by: { $0.listIndex < $1.listIndex })
		s.move(fromOffsets: indices, toOffset: newOffset)
		for (index, item) in s.enumerated() {
			item.listIndex = index
		}
		try? modelContext.save()
	}
	
	private func onDelete(indices: IndexSet) {
		for i in indices {
			let action = actions[i]
			modelContext.delete(action)
		}
	}
	
	private func deleteSelectedAction() {
		if let selectedAction {
			modelContext.delete(selectedAction)
			self.selectedAction = nil
		}
	}
}

#Preview {
    ContentView()
}
