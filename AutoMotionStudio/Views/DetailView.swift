//
//  ActionDetailView.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import SwiftUI
import KeyboardShortcuts

struct DetailView: View {
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
			actionTypeView
			mouseCoordinatesView
			mouseDynamicsView
			triggerDelayView
		}
		.formStyle(.grouped)
		.padding()
	}
	
	@ViewBuilder
	var actionTypeView: some View {
		Section {
			Picker("Action Type", selection: $action.type) {
				ForEach(ActionType.allCases) { type in
					Text(type.description)
						.tag(type)
				}
			}
			.pickerStyle(.menu)
		}
	}
	
	@ViewBuilder
	var mouseCoordinatesView: some View {
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
	}
	
	@ViewBuilder
	var mouseDynamicsView: some View {
		Section("Mouse Dynamics") {
			// mouse cubic easing
			
			HStack {
				let isOnMouseEasing = Binding<Bool> {
					action.mouseEasing.isOn
				} set: { newValue in
					action.mouseEasing = newValue ? MouseEasing.cubicDefault : .none
				}

				Toggle(isOn: isOnMouseEasing) {
					HStack {
						Text("Cubic Easing")
					}
				}
			}
			
			if action.mouseEasing.isOn {
				let mouseEasingFactor = Binding<CGFloat> {
					let factor = action.mouseEasing.cubicFactor ?? 0.0
					return MouseEasing.cubicUpperBound - factor + MouseEasing.cubicLowerBound // inverse value
				} set: {
					let newValue = MouseEasing.cubicUpperBound - $0 + MouseEasing.cubicLowerBound // inverse value
					action.mouseEasing = MouseEasing.cubic(factor: newValue)
				}
				
				Slider(
					value: mouseEasingFactor,
					in: MouseEasing.cubicLowerBound...MouseEasing.cubicUpperBound,
					label: { Text("Factor") },
					minimumValueLabel: { Image(systemName: "tortoise") },
					maximumValueLabel: { Image(systemName: "hare") }
				)
			}
		}
	}
	
	@ViewBuilder
	var triggerDelayView: some View {
		Section("Trigger Delay") {
			HStack {
				Text("Duration (in seconds)")
				
				TextField(value: $action.delay, format: .number.precision(.fractionLength(2))) {
					ControlGroup {
						Button(action: { action.delay -= 0.5 }, label: {
							Image(systemName: "minus")
						})
						
						Button(action: { action.delay += 0.5 }, label: {
							Image(systemName: "plus")
						})
					}
				}
			}
		}
	}
}

#Preview {
	let action = Action(type: .linearMove)
	return DetailView(action: action)
		.frame(width: 400, height: 800)
}
