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
	/// List of actions from persistent data source
	@Query(sort: \Action.listIndex) private var actions: [Action]
	/// Multiple selections the user can choose from the sidebar
	@State private var selectedActions: Set<Action> = []
	
    var body: some View {
		NavigationSplitView {
			// Navigation View sidebar
			
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
			// Navigation View details
			
			if selectedActions.count == 1, let selectedAction = selectedActions.first {
				// single selection details
				DetailView(action: selectedAction)
					.toolbar {
						deleteSelectionToolbar
					}
			} else if selectedActions.count > 1 {
				// multiple selections
				ZStack {
					ForEach(Array(selectedActions).reversed().dropLast(max(selectedActions.count - 5, 0)), id: \.self) { selectedAction in
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
		// perform actions when user presses ⌫ key
		.onDeleteCommand {
			deleteSelectedAction()
		}
		// receive notification that selections has been changed
		.onReceive(for: .selectionsChanged) { newValue in
			selectedActions = newValue
		}
		// send notification that selections has been changed
		.onChange(of: selectedActions) {
			NotificationCenter.default.post(.selectionsChanged, data: selectedActions)
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
	
	private func deleteSelectedAction() {
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
