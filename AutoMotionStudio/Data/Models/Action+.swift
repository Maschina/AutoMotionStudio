//
//  Action+Execute.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 04.07.24.
//

import Foundation
import Cocoa

/// Model to store an action. An action is a set of action type definition (e.g. mouse click), target mouse coordinates and dynamics and a delay to wait before executing this action.
typealias Action = SchemaV2.Action

extension Action {
	func setCurrentMouseCoordinates() {
		let coordinates = MouseLocations.cgMouseLocation
		mouseCoordinates = Point(coordinates)
	}
	
	/// Execute the defined action
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

// MARK: Execution operators

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
				)?
					.post(tap: CGEventTapLocation.cghidEventTap)
				
			case .cubic(let factor):
				easingMouseAction(easingFactor: factor, eventType: .mouseMoved, mouseButton: .left)
		}
	}
	
	private func mouseClick(mouseButton: CGMouseButton) {
		// mouse move
		mouseMove()
		
		let mouseDownType =
		mouseButton == .left ? CGEventType.leftMouseDown : CGEventType.rightMouseDown
		let mouseUpType = mouseButton == .left ? CGEventType.leftMouseUp : CGEventType.rightMouseUp
		
		// mouse down
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: mouseDownType,
			mouseCursorPosition: mouseCoordinates.cgPoint,
			mouseButton: mouseButton
		)?
			.post(tap: CGEventTapLocation.cghidEventTap)
		
		// mouse up
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: mouseUpType,
			mouseCursorPosition: mouseCoordinates.cgPoint,
			mouseButton: mouseButton
		)?
			.post(tap: CGEventTapLocation.cghidEventTap)
	}
	
	private func mouseDragStart() {
		mouseMove()
		
		// mouse down
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: .leftMouseDown,
			mouseCursorPosition: mouseCoordinates.cgPoint,
			mouseButton: .left
		)?
			.post(tap: CGEventTapLocation.cghidEventTap)
	}
	
	private func mouseDragEnd() {
		// drag
		if case .cubic(let factor) = mouseEasing {
			easingMouseAction(
				easingFactor: factor,
				eventType: .leftMouseDragged,
				mouseButton: .left
			)
		}
		
		// mouse up
		CGEvent(
			mouseEventSource: CGEventSource(stateID: CGEventSourceStateID.hidSystemState),
			mouseType: .leftMouseUp,
			mouseCursorPosition: mouseCoordinates.cgPoint,
			mouseButton: .left
		)?
			.post(tap: CGEventTapLocation.cghidEventTap)
	}
}

extension Action {
	private func easingMouseAction(
		easingFactor: CGFloat,
		eventType: CGEventType,
		mouseButton: CGMouseButton
	) {
		let from = MouseLocations.cgMouseLocation
		
		let distance = from.distance(to: mouseCoordinates.cgPoint)
		let steps = Int(distance * CGFloat(easingFactor) / 100) + 1
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
				)?
					.post(tap: CGEventTapLocation.cghidEventTap)
				
				try Task.checkCancellation()
				usleep(useconds_t(Int.random(in: 200..<300)))
			}
		}
		catch {
			print("easingMouseAction cancelled")
		}
	}
}

// MARK: Duplicate

extension Action {
	func duplicate() -> Action {
		Action(
			type: self.type,
			mouseCoordinates: self.mouseCoordinates,
			mouseEasing: self.mouseEasing,
			delay: self.delay,
			listIndex: self.listIndex,
			sequence: self.sequence
		)
	}
}
