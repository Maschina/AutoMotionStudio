//
//  Sequence.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 04.07.24.
//

import Foundation
import SwiftData

extension SchemaV2 {
	/// Model to store a sequence. A sequence holds an array of actions.
	@Model
	final class Sequence: Identifiable, Codable, Hashable {
		/// ID of the action to identify its uniqueness
		@Attribute(.unique) var id: UUID = UUID()
		/// Describing title of the sequence
		var title: String
		/// Creation timestamp
		var createdOn: Date = Date.now
		/// List index in the sidebar view
		var listIndex: Int = 0
		/// List of actions belonging to the sequence
		@Relationship(deleteRule: .cascade, inverse: \Action.sequence)
		var actions: [Action] = []
		
		init(title: String) {
			self.title = title
		}
		
		// MARK: Codable requirements
		
		enum CodingKeys: CodingKey {
			case id, title, createdOn, listIndex, actions
		}
		
		required init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			id = try container.decode(UUID.self, forKey: .id)
			title = try container.decode(String.self, forKey: .title)
			createdOn = try container.decode(Date.self, forKey: .createdOn)
			listIndex = try container.decode(Int.self, forKey: .listIndex)
			actions = try container.decode([Action].self, forKey: .actions)
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(id, forKey: .id)
			try container.encode(title, forKey: .title)
			try container.encode(createdOn, forKey: .createdOn)
			try container.encode(listIndex, forKey: .listIndex)
			try container.encode(actions, forKey: .actions)
		}
		
		// MARK: Hashable
		
		static func == (lhs: Sequence, rhs: Sequence) -> Bool {
			lhs.id == rhs.id
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}
}
