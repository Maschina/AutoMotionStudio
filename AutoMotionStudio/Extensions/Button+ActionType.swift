//
//  Button+ActionType.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 06.07.24.
//

import SwiftUI
import SwiftData

extension Button where Label == Text {
	/// Button init to directly add a new action into the model context
	init(insertAction: ActionType, sequence: Sequence, modelContext: ModelContext, selectedActions: Binding<Set<Action>>) {
		self.init(insertAction.description) {
			withAnimation {
				let actions = try? modelContext.fetch(FetchDescriptor<Action>())
				let listIndexMax = actions?.map(\.listIndex).max()
				
				let listIndex = if let listIndexMax { listIndexMax + 1 } else { 0 }
				let action = Action(
					type: insertAction,
					sequence: sequence,
					listIndex: listIndex
				)
				modelContext.insert(action)
				
				selectedActions.wrappedValue = Set(arrayLiteral: action)
			}
		}
	}
}
