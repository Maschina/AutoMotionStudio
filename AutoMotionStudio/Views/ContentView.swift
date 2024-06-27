//
//  ContentView.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import SwiftUI
import KeyboardShortcuts

struct ContentView: View {
	@State private var viewModel = ActionViewModel()
	
    var body: some View {
		NavigationSplitView {
			List(viewModel.actions, selection: $viewModel.selectedAction) { action in
				Text(action.type.rawValue)
					.tag(action)
			}
			.listStyle(.sidebar)
			.toolbar {
				ToolbarItem(placement: .navigation) {
					Button("Run", systemImage: "play.fill") {
						viewModel.executeActions()
					}
				}
				
				ToolbarItem(placement: .primaryAction) {
					Menu {
						ForEach(ActionType.allCases) { type in
							Button(action: {
								let action = viewModel.addAction(type: type)
								viewModel.selectedAction = action
							}) {
								Text(type.rawValue)
									.padding()
							}
						}
					} label: {
						Label("Add Action", systemImage: "plus")
					}
					.menuIndicator(.hidden)
				}
			}
		} detail: {
			if let selectedAction = viewModel.selectedAction {
				ActionDetailView(action: selectedAction)
			} else {
				Text("Select an action")
					.foregroundColor(.gray)
			}
		}
    }
	
	private func binding(for action: Action) -> Binding<Action> {
		guard let index = viewModel.actions.firstIndex(where: { $0.id == action.id }) else {
			fatalError("Action not found")
		}
		return $viewModel.actions[index]
	}
}

#Preview {
    ContentView()
}
