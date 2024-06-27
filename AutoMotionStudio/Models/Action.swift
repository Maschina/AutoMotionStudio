//
//  Action.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import Foundation
import KeyboardShortcuts
import Cocoa

@Observable
class Action: Identifiable, Codable {
	var id: UUID = .init()
	var type: ActionType
	var mouseCoordinates: CGPoint = .init(x: 0, y: 0)
	var humanizedMouseMovement: Bool = true
	/// Easing means ramping up the movement smoothly in the beginning, and ramping it down towards the end.
	var easing: CGFloat = 300
	var delay: Duration = .milliseconds(500)
	
	init(
		type: ActionType
	) {
		self.type = type
	}
	
	func setCurrentMouseCoordinates() {
		let coordinates = AppState.shared.cgMouseLocation
		mouseCoordinates = coordinates
	}
	
	func execute() {
		switch type {
			case .linearMove:
				mouseMove()
				
			case .primaryClick:
				mouseClick(mouseButton: .left)
				
			case .secondaryClick:
				mouseClick(mouseButton: .right)
				
			case .dragStart:
				mouseDragStart()
				
			case .dragEnd:
				mouseDragEnd()
		}
	}
}

extension Action {
	private func mouseMove() {
		if humanizedMouseMovement {
			humanizedMouseAction(eventType: .mouseMoved, mouseButton: .left)
		} else {
			// mouse move
			CGEvent(
				mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
				mouseType: .mouseMoved,
				mouseCursorPosition: mouseCoordinates,
				mouseButton: .left
			)?.post(tap: CGEventTapLocation.cghidEventTap)
		}
	}
	
	private func mouseClick(mouseButton: CGMouseButton) {
		// mouse move
		mouseMove()
		
		let mouseDownType = mouseButton == .left ? CGEventType.leftMouseDown : CGEventType.rightMouseDown
		let mouseUpType = mouseButton == .left ? CGEventType.leftMouseUp : CGEventType.rightMouseUp
		
		// mouse down
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: mouseDownType,
			mouseCursorPosition: mouseCoordinates,
			mouseButton: mouseButton
		)?.post(tap: CGEventTapLocation.cghidEventTap)
		
		// mouse up
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: mouseUpType,
			mouseCursorPosition: mouseCoordinates,
			mouseButton: mouseButton
		)?.post(tap: CGEventTapLocation.cghidEventTap)
	}
	
	private func mouseDragStart() {
		mouseMove()
		
		// mouse down
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: .leftMouseDown,
			mouseCursorPosition: mouseCoordinates,
			mouseButton: .left
		)?.post(tap: CGEventTapLocation.cghidEventTap)
	}
	
	private func mouseDragEnd() {
		// drag
		humanizedMouseAction(eventType: .leftMouseDragged, mouseButton: .left)
		
		// mouse up
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: .leftMouseUp,
			mouseCursorPosition: mouseCoordinates,
			mouseButton: .left
		)?.post(tap: CGEventTapLocation.cghidEventTap)
	}
}

extension Action {
	private func humanizedMouseAction(eventType: CGEventType, mouseButton: CGMouseButton) {
		let from = AppState.shared.cgMouseLocation
		
		let distance = from.distance(to: mouseCoordinates)
		let steps = Int(distance * CGFloat(easing) / 100) + 1;
		let xDiff = mouseCoordinates.x - from.x
		let yDiff = mouseCoordinates.y - from.y
		let stepSize = 1.0 / CGFloat(steps)
		
		for i in 0...steps {
			let factor = (stepSize * CGFloat(i)).cubicEaseOut()
			let stepPoint = CGPoint(x: from.x + (factor * xDiff), y: from.y + (factor * yDiff))
			
			CGEvent(
				mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
				mouseType: eventType,
				mouseCursorPosition: stepPoint,
				mouseButton: mouseButton
			)?.post(tap: CGEventTapLocation.cghidEventTap)
			
			usleep(useconds_t(Int.random(in: 200..<300)))
		}
	}
}

// MARK: Equatable

extension Action: Equatable {
	static func == (lhs: Action, rhs: Action) -> Bool {
		lhs.id == rhs.id
	}
}

// MARK: Hashable

extension Action: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
