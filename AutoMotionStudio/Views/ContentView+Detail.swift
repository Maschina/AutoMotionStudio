//
//  ContentView+Detail.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 05.07.24.
//

import SwiftUI
import SwiftData

extension ContentView {
	struct Detail: View {
		/// Multiple selections the user can choose from the content list
		@Binding var selectedActions: Set<Action>
		
		var body: some View {
			if selectedActions.count == 1, let selectedAction = selectedActions.first {
				// single selection details
				ActionDetailView(
					type: Bindable(selectedAction).type,
					mouseCoordinates: Bindable(selectedAction).mouseCoordinates,
					mouseEasing: Bindable(selectedAction).mouseEasing,
					delay: Bindable(selectedAction).delay
				)
			} else if selectedActions.count > 1 {
				// multiple selections
				ZStack {
					ForEach(Array(selectedActions).reversed().dropLast(max(selectedActions.count - 5, 0)), id: \.self) { selectedAction in
						let randomRotation = Double.random(in: -3.5...3.5)
						ActionDetailView(
							type: Bindable(selectedAction).type,
							mouseCoordinates: Bindable(selectedAction).mouseCoordinates,
							mouseEasing: Bindable(selectedAction).mouseEasing,
							delay: Bindable(selectedAction).delay
						)
						.disabled(true)
						.clipShape(RoundedRectangle(cornerRadius: 15.0))
						.shadow(radius: 2)
						.padding(25)
						.rotationEffect(.degrees(randomRotation))
					}
				}
			} else {
				// no selection
				Text("No Action Selected")
					.font(.largeTitle)
					.fontWeight(.light)
					.multilineTextAlignment(.center)
					.foregroundStyle(Color.secondary)
					.padding(.horizontal, 30)
			}
		}
	}
}
