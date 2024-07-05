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
	final class Sequence: Identifiable, Hashable {
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
		
		static func == (lhs: Sequence, rhs: Sequence) -> Bool {
			lhs.id == rhs.id
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}
}
