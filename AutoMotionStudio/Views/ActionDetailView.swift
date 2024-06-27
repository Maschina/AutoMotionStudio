//
//  ActionDetailView.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import SwiftUI
import KeyboardShortcuts

struct ActionDetailView: View {
	@Bindable var action: Action
	
	var xCoordinate: Binding<Double> {
		Binding {
			action.mouseCoordinates.x
		} set: { newValue in
			action.mouseCoordinates.x = newValue
		}
	}
	
	var yCoordinate: Binding<Double> {
		Binding {
			action.mouseCoordinates.y
		} set: { newValue in
			action.mouseCoordinates.y = newValue
		}
	}
	
	var body: some View {
		Form {
			Section {
				Picker("Action Type", selection: $action.type) {
					ForEach(ActionType.allCases) { type in
						Text(type.rawValue)
							.tag(type)
					}
				}
				.pickerStyle(.menu)
			}
			
			Section {
				TextField("X", value: xCoordinate, format: .number)
					.fontDesign(.monospaced)
				
				TextField("Y", value: yCoordinate, format: .number)
					.fontDesign(.monospaced)
			} header: {
				Text("Target Mouse Coordinates")
			} footer: {
				KeyboardShortcuts.Recorder("Get Current Mouse Coordinates:", name: .getCurrentMouseCoordinates)
			}
		}
		.formStyle(.grouped)
		.padding()
	}
}

#Preview {
	let action = Action(type: .mouseMove)
	return ActionDetailView(action: action)
}
