//
//  Action.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import Foundation
import SwiftData

extension SchemaV1 {
	/// Model to store an action. An action is a set of action type definition (e.g. mouse click), target mouse coordinates and dynamics and a delay to wait before executing this action.
	@Model
	final class Action: Identifiable, Codable, Hashable {
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
		
		/// Creates and returns a new action
		/// - Parameters:
		///   - type: Defines the type of what to do
		///   - listIndex: List index in the sidebar view
		init(
			type: ActionType,
			listIndex: Int = 0
		) {
			self.type = type
			self.listIndex = listIndex
		}
		
		init(
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
		
		static func == (lhs: Action, rhs: Action) -> Bool {
			lhs.id == rhs.id
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}
}
