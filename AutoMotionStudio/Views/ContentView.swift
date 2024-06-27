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
			List(viewModel.actions, selection: $viewModel.selectedAction) { action in
				Text("\(action.type.description)")
					.tag(action)
			}
			.listStyle(.sidebar)
			.frame(minWidth: 180, idealWidth: 200)
			.toolbar {
				ContentViewToolbar(viewModel: viewModel)
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
