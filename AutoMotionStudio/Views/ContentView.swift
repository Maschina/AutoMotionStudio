//
//  ContentView.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import SwiftUI
import KeyboardShortcuts

struct ContentView: View {
	@State private var viewModel = AutoMotionModel()
	
    var body: some View {
		NavigationSplitView {
			List(selection: $viewModel.selectedAction) {
				ForEach(viewModel.actions) { action in
					ActionListElement(action: action)
						.tag(action)
				}
				.onDelete(perform: { indexSet in
					withAnimation {
						viewModel.actions.remove(atOffsets: indexSet)
					}
				})
			}
			.listStyle(.sidebar)
			.frame(minWidth: 180, idealWidth: 200)
			.toolbar {
				ContentViewToolbar(viewModel: viewModel)
			}
		} detail: {
			if let selectedAction = viewModel.selectedAction {
				ActionDetailView(action: selectedAction)
					.toolbar {
						ToolbarItem(placement: .destructiveAction) {
							Button("Delete", systemImage: "trash") {
								withAnimation {
									deleteSelectedAction()
								}
							}
						}
					}
			} else {
				Text("Select an action")
					.foregroundColor(.gray)
			}
		}
		.onDeleteCommand {
			withAnimation {
				deleteSelectedAction()
			}
		}
    }
	
	private func binding(for action: Action) -> Binding<Action> {
		guard let index = viewModel.actions.firstIndex(where: { $0.id == action.id }) else {
			fatalError("Action not found")
		}
		return $viewModel.actions[index]
	}
	
	private func deleteSelectedAction() {
		viewModel.actions.removeAll(where: { viewModel.selectedAction == $0 })
		viewModel.selectedAction = nil
	}
}

#Preview {
    ContentView()
}
