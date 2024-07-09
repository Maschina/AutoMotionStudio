//
//  ModelContainer.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 01.07.24.
//

import Foundation
import SwiftData

struct Container {
	/// Persistence container to the Model Container
	@MainActor
	static var persistent: ModelContainer = {
		let schema = Schema([
			Action.self,
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		
		do {
			let container = try ModelContainer(
				for: schema,
				migrationPlan: DataMigrationsPlan.self,
				configurations: [modelConfiguration]
			)
			return container
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()
}
