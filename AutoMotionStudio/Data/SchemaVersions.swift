//
//  SchemaVersions.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 04.07.24.
//

import Foundation
import SwiftData

enum SchemaV1: VersionedSchema {
	static var models: [any PersistentModel.Type] {
		return [Action.self]
	}
	
	static var versionIdentifier: Schema.Version = .init(1, 0, 0)
}

enum SchemaV2: VersionedSchema {
	static var models: [any PersistentModel.Type] {
		return [Action.self, Sequence.self]
	}
	
	static var versionIdentifier: Schema.Version = .init(2, 0, 0)
}
