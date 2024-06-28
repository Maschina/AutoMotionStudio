//
//  ActionListElement.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import SwiftUI

struct ListElement: View {
	@Bindable var action: Action
	
	var delay: Duration {
		let modf = modf(action.delay)
		return Duration(secondsComponent: Int64(modf.0), attosecondsComponent: Int64(modf.1 * 1000) * 1_000_000_000_000_000)
	}
	
    var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			Text(action.type.description)
			
			HStack {
				if let factor = action.mouseEasing.cubicFactor {
					Label("\(factor, format: .number.precision(.fractionLength(0)))", systemImage: "figure.walk.motion")
						.contentTransition(.numericText())
						.help("Humanized easing factor")
				}
				
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
	let action = Action(type: .linearMove)
	action.delay = 2.5
	return ListElement(action: action)
		.padding()
}
