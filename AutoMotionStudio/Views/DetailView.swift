//
//  ActionDetailView.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import SwiftUI
import KeyboardShortcuts

/// Action detail view that is shown when list element in the sidebar is being selected
struct DetailView: View {
	@Binding var type: ActionType
	@Binding var mouseCoordinates: Point
	@Binding var mouseEasing: MouseEasing
	@Binding var delay: TimeInterval
	
	var body: some View {
		Form {
			actionTypeView
			MouseCoordinatesView(mouseCoordinates: $mouseCoordinates)
			triggerDelayView
			mouseDynamicsView
		}
		.formStyle(.grouped)
	}
	
	var actionTypeView: some View {
		Section {
			Picker("Action Type", selection: $type) {
				ForEach(ActionType.allCases) { type in
					Text(type.description)
						.tag(type)
				}
			}
			.pickerStyle(.menu)
		}
	}
	
	struct MouseCoordinatesView: View {
		@Binding var mouseCoordinates: Point
		
		var xCoordinate: Binding<Double> {
			Binding {
				mouseCoordinates.x
			} set: { newValue in
				mouseCoordinates.x = newValue
			}
		}
		
		var yCoordinate: Binding<Double> {
			Binding {
				mouseCoordinates.y
			} set: { newValue in
				mouseCoordinates.y = newValue
			}
		}
		
		@MainActor
		var shortcutDescriptionGetMouseCoordinates: String? {
			guard let shortcut = KeyboardShortcuts.getShortcut(for: .getCurrentMouseCoordinates) else {
				return nil
			}
			return shortcut.description
		}
		
		var body: some View {
			Section {
				TextField("X", value: xCoordinate, format: .number.precision(.fractionLength(3)))
					.fontDesign(.monospaced)
				
				TextField("Y", value: yCoordinate, format: .number.precision(.fractionLength(3)))
					.fontDesign(.monospaced)
			} header: {
				Text("Target Mouse Coordinates")
			} footer: {
				if let shortcutDescriptionGetMouseCoordinates {
					Text("Press \(shortcutDescriptionGetMouseCoordinates) to get current mouse coordinates.")
						.foregroundStyle(Color.secondary)
						.font(.footnote)
					SettingsLink()
						.buttonStyle(.link)
						.font(.footnote)
				}
			}
		}
	}
	
	var mouseDynamicsView: some View {
		Section("Mouse Dynamics") {
			// mouse cubic easing
			
			HStack {
				let isOnMouseEasing = Binding<Bool> {
					mouseEasing.isOn
				} set: { newValue in
					mouseEasing = newValue ? MouseEasing.cubicDefault : .none
				}

				Toggle(isOn: isOnMouseEasing) {
					HStack {
						Text("Cubic Easing")
					}
				}
			}
			
			if mouseEasing.isOn {
				let mouseEasingFactor = Binding<CGFloat> {
					let factor = mouseEasing.cubicFactor ?? 0.0
					return MouseEasing.cubicUpperBound - factor + MouseEasing.cubicLowerBound // inverse value
				} set: {
					let newValue = MouseEasing.cubicUpperBound - $0 + MouseEasing.cubicLowerBound // inverse value
					mouseEasing = MouseEasing.cubic(factor: newValue)
				}
				
				Slider(
					value: mouseEasingFactor,
					in: MouseEasing.cubicLowerBound...MouseEasing.cubicUpperBound,
					label: { Text("Speed") },
					minimumValueLabel: { Image(systemName: "tortoise") },
					maximumValueLabel: { Image(systemName: "hare") }
				)
			}
		}
	}
	
	var triggerDelayView: some View {
		Section("Trigger Delay") {
			HStack {
				Text("Duration (in seconds)")
				
				TextField(value: $delay, format: .number.precision(.fractionLength(2))) {
					ControlGroup {
						Button(action: { delay -= 0.5 }, label: {
							Image(systemName: "minus")
						})
						
						Button(action: { delay += 0.5 }, label: {
							Image(systemName: "plus")
						})
					}
				}
			}
		}
	}
}

#Preview {
	let action = Action.new(type: .linearMove)
	return DetailView(type: .constant(action.type), mouseCoordinates: .constant(action.mouseCoordinates), mouseEasing: .constant(action.mouseEasing), delay: .constant(action.delay))
		.frame(width: 400, height: 800)
}
