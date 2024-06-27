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
	var mouseCoordinates: CGPoint
	var humanizedMouseMovement: Bool
	/// Easing means ramping up the movement smoothly in the beginning, and ramping it down towards the end.
	var easing: CGFloat
	var delay: Duration
	
	init(
		type: ActionType,
		mouseCoordinates: CGPoint = .init(x: 0, y: 0),
		humanizedMouseMovement: Bool = true,
		easing: CGFloat = 100,
		delay: Duration = .zero
	) {
		self.type = type
		self.mouseCoordinates = mouseCoordinates
		self.humanizedMouseMovement = humanizedMouseMovement
		self.easing = easing
		self.delay = delay
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
				mouseMove()
				mouseClick(mouseButton: .left)
				
			case .secondaryClick:
				mouseMove()
				mouseClick(mouseButton: .right)
				
			case .dragStart:
				mouseMove()
				mouseDrag(mouseButton: .left)
				
			case .dragEnd:
				mouseMove()
				mouseDrag(mouseButton: .right)
		}
	}
}

extension Action {
	private func mouseMove() {
		if !humanizedMouseMovement {
			let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
			CGEvent(
				mouseEventSource: source,
				mouseType: CGEventType.mouseMoved,
				mouseCursorPosition: mouseCoordinates,
				mouseButton: CGMouseButton.left
			)?.post(tap: CGEventTapLocation.cghidEventTap)
			
		} else {
			let from = AppState.shared.cgMouseLocation
			
			let distance = from.distance(to: mouseCoordinates)
			let steps = Int(distance * CGFloat(easing) / 100) + 1;
			let xDiff = mouseCoordinates.x - from.x
			let yDiff = mouseCoordinates.y - from.y
			let stepSize = 1.0 / CGFloat(steps)
			
			for i in 0...steps {
				let factor = (stepSize * CGFloat(i)).cubicEaseOut()
				let stepPoint = CGPoint(x: from.x + (factor * xDiff), y: from.y + (factor * yDiff))
				
				let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
				CGEvent(
					mouseEventSource: source,
					mouseType: CGEventType.mouseMoved,
					mouseCursorPosition: stepPoint,
					mouseButton: CGMouseButton.left
				)?.post(tap: CGEventTapLocation.cghidEventTap)
				
				usleep(useconds_t(Int.random(in: 200..<300)))
			}
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
