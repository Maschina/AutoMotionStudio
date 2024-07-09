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
		
		@Environment(\.modelContext) private var modelContext
		/// List of actions from persistent data source
		@Query(sort: \Action.listIndex) private var actions: [Action]
		
		let multiSelectionStapleAnimationMaxCount: Int = 5
		let multiSelectionStapleAnimationRotations: [Double] = [-1.5, 0.25, 2.0, -1.75, 2.5]
		
		var body: some View {
			if selectedActions.count == 1, let selectedAction = selectedActions.first {
				// single selection details
				ActionDetailView(
					type: Bindable(selectedAction).type,
					mouseCoordinates: Bindable(selectedAction).mouseCoordinates,
					mouseEasing: Bindable(selectedAction).mouseEasing,
					delay: Bindable(selectedAction).delay
				)
				.toolbar {
					ToolbarItem(placement: .destructiveAction) {
						Button("Delete", systemImage: "trash") {
							deleteSelectedActions()
						}
					}
				}
			} else if selectedActions.count > 1 {
				// multiple selections
				ZStack {
					let items = selectedActions.sorted(by: \.listIndex, <).reversed().dropLast(max(selectedActions.count - multiSelectionStapleAnimationMaxCount, 0))
					ForEach(Array(items.enumerated()), id: \.offset) { index, selectedAction in
						let rotation = multiSelectionStapleAnimationRotations[index]
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
						.rotationEffect(.degrees(rotation))
					}
				}
				.toolbar {
					ToolbarItem(placement: .destructiveAction) {
						Button("Delete", systemImage: "trash") {
							deleteSelectedActions()
						}
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
		
		private func deleteSelectedActions() {
			withAnimation {
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
		}
	}
}
