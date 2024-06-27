//
//  ActionListElement.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import SwiftUI

struct ActionListElement: View {
	@Bindable var action: Action
	
    var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			Text(action.type.description)
			
			HStack {
				if action.humanizedMouseMovement {
					Label("\(action.easing, format: .number.precision(.fractionLength(0)))", systemImage: "figure.walk.diamond")
						.help("Humanized easing factor")
				}
				
				if action.delay != .zero {
					Label("\(action.delay, format: .time(pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2, roundFractionalSeconds: .toNearestOrEven)))", systemImage: "timer")
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
	action.delay = .seconds(2)
	return ActionListElement(action: action)
		.padding()
}
