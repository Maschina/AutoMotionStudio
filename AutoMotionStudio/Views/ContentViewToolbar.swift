//
//  ContentViewToolbar.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import SwiftUI

struct ContentViewToolbar: ToolbarContent {
	@Bindable var viewModel: AutoMotionModel
	
	var body: some ToolbarContent {
		ToolbarItem(placement: .navigation) {
			if !viewModel.isExecuting {
				Button("Run", systemImage: "play.fill") {
					viewModel.executeActions()
				}
			} else {
				Button("Stop", systemImage: "stop.fill") {
					viewModel.cancelActions()
				}
			}
		}
		
		ToolbarItemGroup(placement: .primaryAction) {
			Spacer()
			Menu {
				ForEach(ActionType.allCases) { type in
					Button(action: {
						let action = viewModel.addAction(type: type)
						viewModel.selectedAction = action
					}) {
						Text(type.description)
							.padding()
					}
				}
			} label: {
				Label("Add Action", systemImage: "plus")
			}
			.menuIndicator(.hidden)
		}
	}
}
