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
	static var persistent: ModelContainer {
		let schema = Schema([
			Action.self,
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		
		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}
}
