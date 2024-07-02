//
//  ActionListElement.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import SwiftUI

/// List element view for the sidebar
struct ListElement: View {
	@Bindable var action: Action
	
	/// Delay of the action before being executed
	var delay: Duration {
		let modf = modf(action.delay)
		return Duration(secondsComponent: Int64(modf.0), attosecondsComponent: Int64(modf.1 * 1000) * 1_000_000_000_000_000)
	}
	
    var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			#if DEBUG
			Text("\(action.type.description) (\(action.listIndex))")
			#else
			Text(action.type.description)
			#endif
			
			HStack {
				// indicate mouse easing speed
				if action.mouseEasing.cubicFactor != nil {
					Label("\(action.mouseEasing.cubicSemanticDescription)", systemImage: "computermouse")
						.help("Mouse Easing Speed")
				}
				
				// indicate delay of the action
				if action.delay != 0 {
					Label("\(delay, format: .time(pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2, roundFractionalSeconds: .toNearestOrEven)))", systemImage: "timer")
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
	let action = Action.new(type: .linearMove)
	action.delay = 2.5
	return ListElement(action: action)
		.padding()
}
