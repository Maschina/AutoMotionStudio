//
//  Action.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import Foundation
import KeyboardShortcuts
import Cocoa
import SwiftData

typealias Actions = [Action]

@Model
class Action: Identifiable {
	@Attribute(.unique) var id: UUID = UUID()
	var type: ActionType
	var mouseCoordinates: Point = Point(x: 0, y: 0)
	var mouseEasing: MouseEasing = MouseEasing.cubic(factor: 300)
	var delay: TimeInterval = 0.5
	var listIndex: Int = 0
	
	init(
		type: ActionType
	) {
		self.type = type
	}
	
	func setCurrentMouseCoordinates() {
		let coordinates = AppState.shared.cgMouseLocation
		mouseCoordinates = Point(coordinates)
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
		switch mouseEasing {
			case .none:
				// mouse move
				CGEvent(
					mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
					mouseType: .mouseMoved,
					mouseCursorPosition: mouseCoordinates.cgPoint,
					mouseButton: .left
				)?.post(tap: CGEventTapLocation.cghidEventTap)
				
			case .cubic(let factor):
				easingMouseAction(easingFactor: factor, eventType: .mouseMoved, mouseButton: .left)
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
			mouseCursorPosition: mouseCoordinates.cgPoint,
			mouseButton: mouseButton
		)?.post(tap: CGEventTapLocation.cghidEventTap)
		
		// mouse up
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: mouseUpType,
			mouseCursorPosition: mouseCoordinates.cgPoint,
			mouseButton: mouseButton
		)?.post(tap: CGEventTapLocation.cghidEventTap)
	}
	
	private func mouseDragStart() {
		mouseMove()
		
		// mouse down
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: .leftMouseDown,
			mouseCursorPosition: mouseCoordinates.cgPoint,
			mouseButton: .left
		)?.post(tap: CGEventTapLocation.cghidEventTap)
	}
	
	private func mouseDragEnd() {
		// drag
		if case .cubic(let factor) = mouseEasing {
			easingMouseAction(easingFactor: factor, eventType: .leftMouseDragged, mouseButton: .left)
		}
		
		// mouse up
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: .leftMouseUp,
			mouseCursorPosition: mouseCoordinates.cgPoint,
			mouseButton: .left
		)?.post(tap: CGEventTapLocation.cghidEventTap)
	}
}

extension Action {
	private func easingMouseAction(easingFactor: CGFloat, eventType: CGEventType, mouseButton: CGMouseButton) {
		let from = AppState.shared.cgMouseLocation
		
		let distance = from.distance(to: mouseCoordinates.cgPoint)
		let steps = Int(distance * CGFloat(easingFactor) / 100) + 1;
		let xDiff = mouseCoordinates.x - from.x
		let yDiff = mouseCoordinates.y - from.y
		let stepSize = 1.0 / CGFloat(steps)
		
		do {
			for i in 0...steps {
				let factor = (stepSize * CGFloat(i)).cubicEaseOut()
				let stepPoint = CGPoint(x: from.x + (factor * xDiff), y: from.y + (factor * yDiff))
				
				CGEvent(
					mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
					mouseType: eventType,
					mouseCursorPosition: stepPoint,
					mouseButton: mouseButton
				)?.post(tap: CGEventTapLocation.cghidEventTap)
				
				try Task.checkCancellation()
				usleep(useconds_t(Int.random(in: 200..<300)))
			}
		} catch {
			print("easingMouseAction cancelled")
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
