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
					ListElement(action: action)
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
				DetailView(action: selectedAction)
					.toolbar {
						ToolbarItem(placement: .destructiveAction) {
							Button("Delete", systemImage: "trash") {
								deleteSelectedAction()
							}
						}
					}
			} else {
				ContentUnavailableView(
					"AutoMotion Studio",
					systemImage: "rectangle.and.text.magnifyingglass",
					description: Text("Select an Action in the sidebar oder add a new Action from the \(Image(systemName: "plus")) menu.")
				)
			}
		}
		.navigationTitle("")
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
