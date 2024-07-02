//
//  Action.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import Cocoa
import Foundation
import KeyboardShortcuts
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

typealias Actions = [Action]

/// Model to store an action. An action is a set of action type definition (e.g. mouse click), target mouse coordinates and dynamics and a delay to wait before executing this action.
@Model
class Action: Identifiable, Codable {
	/// ID of the action to identify its uniqueness
	@Attribute(.unique) var id: UUID = UUID()
	/// Defines the type of what to do
	var type: ActionType
	/// Travel the mouse cursor to these coordinates before doing the action as defined in Action `type`
	var mouseCoordinates: Point = Point(x: 0, y: 0)
	/// Defines the move dynamics of the traveling mouse cursor
	var mouseEasing: MouseEasing = MouseEasing.cubic(factor: 300)
	/// Delay in seconds before executing the action
	var delay: TimeInterval = 0.5
	/// List index in the sidebar view
	var listIndex: Int = 0

	// MARK: Init
	
	fileprivate init(
		type: ActionType,
		listIndex: Int = 0
	) {
		self.type = type
		self.listIndex = listIndex
	}

	private init(
		type: ActionType,
		mouseCoordinates: Point,
		mouseEasing: MouseEasing,
		delay: TimeInterval,
		listIndex: Int
	) {
		self.type = type
		self.mouseCoordinates = mouseCoordinates
		self.mouseEasing = mouseEasing
		self.delay = delay
		self.listIndex = listIndex
	}
	
	/// Creates and returns a new action
	/// - Parameters:
	///   - type: Defines the type of what to do
	///   - listIndex: List index in the sidebar view
	static func new(
		type: ActionType,
		listIndex: Int = 0
	) -> Action {
		Action(
			type: type,
			listIndex: listIndex
		)
	}

	// MARK: Codable requirements

	enum CodingKeys: CodingKey {
		case id, type, mouseCoordinates, mouseEasing, delay, listIndex
	}

	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(UUID.self, forKey: .id)
		type = try container.decode(ActionType.self, forKey: .type)
		mouseCoordinates = try container.decode(Point.self, forKey: .mouseCoordinates)
		mouseEasing = try container.decode(MouseEasing.self, forKey: .mouseEasing)
		delay = try container.decode(TimeInterval.self, forKey: .delay)
		listIndex = try container.decode(Int.self, forKey: .listIndex)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(type, forKey: .type)
		try container.encode(mouseCoordinates, forKey: .mouseCoordinates)
		try container.encode(mouseEasing, forKey: .mouseEasing)
		try container.encode(delay, forKey: .delay)
		try container.encode(listIndex, forKey: .listIndex)
	}
}

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
	var duplicate: Action {
		Action(
			type: self.type,
			mouseCoordinates: self.mouseCoordinates,
			mouseEasing: self.mouseEasing,
			delay: self.delay,
			listIndex: self.listIndex
		)
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
