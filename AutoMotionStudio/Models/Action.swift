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
class Action: Identifiable {
	var id: UUID = .init()
	var type: ActionType
	var mouseCoordinates: CGPoint = .init(x: 0, y: 0)
	
	init(type: ActionType) {
		self.type = type
	}
	
	func setCurrentMouseCoordinates() {
		let coordinates = AppState.shared.mouseLocation
		mouseCoordinates = coordinates
	}
	
	func execute() {
		switch type {
			case .mouseMove:
				humanizedMouseMove()
			case .mousePrimaryClick:
				mouseClick(mouseButton: .left)
			case .mouseSecondaryClick:
				mouseClick(mouseButton: .right)
			case .mousePrimaryDrag:
				mouseDrag(mouseButton: .left)
			case .mouseSecondaryDrag:
				mouseDrag(mouseButton: .right)
		}
	}
}

extension Action {
	// Moves the mouse from point `from` to point `to`, with some `easing` factor.
	// Easing means ramping up the movement smoothly in the beginning, and ramping it down towards the end.
	// The cheap "humanized" factor.
	private func humanizedMouseMove(easing: Float = 100.0) {
		let from = AppState.shared.mouseLocation
		
		print("current location: ", from)
		print("moving to: ", mouseCoordinates)
		let distance = distanceBetween(from: from, to: mouseCoordinates)
		let steps = Int(distance * CGFloat(easing) / 100) + 1;
		let xDiff = mouseCoordinates.x - from.x
		let yDiff = mouseCoordinates.y - from.y
		let stepSize = 1.0 / Double(steps)
		
		for i in 0 ... steps {
			let factor = cubicEaseOut(point: Float(stepSize) * Float(i))
			let stepPoint = CGPoint(x: from.x + (CGFloat(factor) * xDiff), y: from.y + (CGFloat(factor) * yDiff))
			CGEvent(mouseEventSource: nil, mouseType: CGEventType.mouseMoved, mouseCursorPosition: stepPoint, mouseButton: CGMouseButton.left)?.post(tap: CGEventTapLocation.cghidEventTap)
			usleep(useconds_t(stepPause()))
		}
	}
	
	private func mouseClick(mouseButton: CGMouseButton) {
		let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
		let mouseDownType = mouseButton == .left ? CGEventType.leftMouseDown : CGEventType.rightMouseDown
		let mouseUpType = mouseButton == .left ? CGEventType.leftMouseUp : CGEventType.rightMouseUp
		
		// mouse down
		CGEvent(
			mouseEventSource: source,
			mouseType: mouseDownType,
			mouseCursorPosition: mouseCoordinates,
			mouseButton: mouseButton
		)?.post(tap: CGEventTapLocation.cghidEventTap)
		
		// mouse up
		CGEvent(
			mouseEventSource: source,
			mouseType: mouseUpType,
			mouseCursorPosition: mouseCoordinates,
			mouseButton: mouseButton
		)?.post(tap: CGEventTapLocation.cghidEventTap)
	}
	
	private func mouseDrag(mouseButton: CGMouseButton) {
		let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
		let mouseDownType = mouseButton == .left ? CGEventType.leftMouseDragged : CGEventType.rightMouseDragged
		let mouseUpType = mouseButton == .left ? CGEventType.leftMouseUp : CGEventType.rightMouseUp
		
		// drag down
		CGEvent(
			mouseEventSource: source,
			mouseType: mouseDownType,
			mouseCursorPosition: mouseCoordinates,
			mouseButton: mouseButton
		)?.post(tap: CGEventTapLocation.cghidEventTap)
		
		// mouse up
		CGEvent(
			mouseEventSource: source,
			mouseType: mouseUpType,
			mouseCursorPosition: mouseCoordinates,
			mouseButton: mouseButton
		)?.post(tap: CGEventTapLocation.cghidEventTap)
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
