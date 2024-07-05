//
//  ActionListElement.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import SwiftUI

/// List element view for the sidebar
struct ActionRowView: View {
	let type: ActionType
	let listIndex: Int
	let mouseEasing: MouseEasing
	let delay: TimeInterval
	
	/// Delay of the action before being executed
	var duration: Duration {
		let modf = modf(delay)
		return Duration(secondsComponent: Int64(modf.0), attosecondsComponent: Int64(modf.1 * 1000) * 1_000_000_000_000_000)
	}
	
    var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			Text(type.description)
			
			HStack {
				// indicate mouse easing speed
				if mouseEasing.cubicFactor != nil {
					Label("\(mouseEasing.cubicSemanticDescription)", systemImage: "computermouse")
						.help("Mouse Easing Speed")
				}
				
				// indicate delay of the action
				if delay != 0 {
					Label("\(duration, format: .time(pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2, roundFractionalSeconds: .toNearestOrEven)))", systemImage: "timer")
						.contentTransition(.numericText())
						.help("Trigger Delay")
				}
			}
			.foregroundStyle(Color.secondary)
			.font(.caption)
		}
    }
}

#Preview {
	let action = Action(type: .linearMove)
	action.delay = 2.5
	return ActionRowView(type: action.type, listIndex: action.listIndex, mouseEasing: action.mouseEasing, delay: action.delay)
		.padding()
}
