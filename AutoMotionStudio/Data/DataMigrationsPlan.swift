//
//  DataMigrationsPlan.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 04.07.24.
//

import Foundation
import SwiftData

enum DataMigrationsPlan: SchemaMigrationPlan {
	static var schemas: [any VersionedSchema.Type] {
		[SchemaV1.self, SchemaV2.self]
	}
	
	static var stages: [MigrationStage] {
		[migrateV1toV2]
	}
	
	static let migrateV1toV2 = MigrationStage.custom(
		fromVersion: SchemaV1.self,
		toVersion: SchemaV2.self, 
		willMigrate: nil,
		didMigrate: { context in
			// new sequence for all orphaned actions
			let sequence = Sequence(
				title: NSLocalizedString("Migrated on \(Date.now.formatted(date: .abbreviated, time: .omitted))", tableName: "Localizable", comment: "")
			)
			
			// add new model instance for orphaned actions
			let orphanedFetchDescriptor = FetchDescriptor<Action>(predicate: #Predicate { $0.sequence == nil })
			let orphanedActions = try? context.fetch(orphanedFetchDescriptor)
			for action in orphanedActions ?? [] {
				action.sequence = sequence
			}
			
			// insert new sequence
			context.insert(sequence)
			
			try? context.save()
		}
	)
}
