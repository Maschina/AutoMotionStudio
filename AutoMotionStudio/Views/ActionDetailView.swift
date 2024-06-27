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
						Text(type.description)
							.tag(type)
					}
				}
				.pickerStyle(.menu)
			}
			
			Section {
				TextField("X", value: xCoordinate, format: .number.precision(.fractionLength(3)))
					.fontDesign(.monospaced)
				
				TextField("Y", value: yCoordinate, format: .number.precision(.fractionLength(3)))
					.fontDesign(.monospaced)
			} header: {
				Text("Target Mouse Coordinates")
			} footer: {
				KeyboardShortcuts.Recorder("Get Current Mouse Coordinates:", name: .getCurrentMouseCoordinates)
					.foregroundStyle(Color.secondary)
			}
			
			Section("Mouse Dynamics") {
				Toggle("Humanized", isOn: $action.humanizedMouseMovement)
				
				if action.humanizedMouseMovement {
					Slider(value: $action.easing, in: 50...2500) {
						Text("Easing")
					}
				}
			}
			
			Section("Trigger Delay") {
				HStack {
					Text("Duration (in seconds)")

					let secondsBinding = Binding<TimeInterval> {
						let seconds = Double(action.delay.components.seconds) + Double(action.delay.components.attoseconds) * 1e-18
						return TimeInterval(seconds)
					} set: { newValue in
						let modf = modf(newValue)
						action.delay = Duration(secondsComponent: Int64(modf.0), attosecondsComponent: Int64(modf.1) * 1_000_000_000_000_000_000)
					}

					
					TextField(value: secondsBinding, format: .number.precision(.fractionLength(2))) { 
						ControlGroup {
							Button(action: { action.delay -= .milliseconds(500) }, label: {
								Image(systemName: "minus")
							})
							
							Button(action: { action.delay += .milliseconds(500) }, label: {
								Image(systemName: "plus")
							})
						}
					}
				}
			}
		}
		.formStyle(.grouped)
		.padding()
	}
}

#Preview {
	let action = Action(type: .linearMove)
	return ActionDetailView(action: action)
		.frame(width: 400, height: 800)
}
