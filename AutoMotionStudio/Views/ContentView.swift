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
	@State private var selectedActions: Set<Action> = .init()
	
    var body: some View {
		NavigationSplitView {
			// sidebar
			List(selection: $selectedActions) {
				ForEach(actions) { action in
					ListElement(action: action)
						.padding(.vertical, 3)
						.tag(action)
				}
				.onMove(perform: onMove)
				.onDelete(perform: onDelete)
			}
			.frame(minWidth: 190, idealWidth: 200)
			.toolbar {
				ContentViewToolbar()
			}
		} detail: {
			if selectedActions.count == 1, let selectedAction = selectedActions.first {
				// single selection details
				DetailView(action: selectedAction)
					.toolbar {
						deleteSelectionToolbar
					}
			} else if selectedActions.count > 1 {
				// multiple selections
				ZStack {
					ForEach(Array(selectedActions).reversed(), id: \.self) { selectedAction in
						let randomRotation = Double.random(in: -3.5...3.5)
						DetailView(action: selectedAction)
							.disabled(true)
							.clipShape(RoundedRectangle(cornerRadius: 15.0))
							.shadow(radius: 2)
							.padding(25)
							.rotationEffect(.degrees(randomRotation))
					}
				}
				.toolbar {
					deleteSelectionToolbar
				}
			} else {
				// no selection
				VStack(spacing: 25) {
					Text("AutoMotion Studio")
						.font(.largeTitle)
						.fontWeight(.semibold)
					
					Text("Select an Action in the sidebar or add a new Action from the \(Image(systemName: "plus")) menu.")
						
				}
				.multilineTextAlignment(.center)
				.foregroundStyle(Color.secondary)
				.padding(.horizontal, 30)
			}
		}
		.navigationTitle("")
		.onDeleteCommand {
			deleteSelectedAction()
		}
		.task {
			for await event in KeyboardShortcuts.events(for: .getCurrentMouseCoordinates) where event == .keyUp {
				for selectedAction in selectedActions {
					selectedAction.setCurrentMouseCoordinates()
				}
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
		for selectedAction in selectedActions {
			modelContext.delete(selectedAction)
			self.selectedActions.remove(selectedAction)
		}
	}
	
	var deleteSelectionToolbar: some ToolbarContent {
		ToolbarItem(placement: .destructiveAction) {
			Button("Delete", systemImage: "trash") {
				deleteSelectedAction()
			}
		}
	}
}

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: Action.self, configurations: config)
	
    return ContentView()
		.modelContainer(container)
}
