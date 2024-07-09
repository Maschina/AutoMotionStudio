//
//  Array+Action.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 01.07.24.
//

import Foundation

extension Array {
	// Function to increment the specified integer property
	mutating func reorder(keyPath: WritableKeyPath<Element, Int>) {
		var i = 0
		for index in self.indices {
			self[index][keyPath: keyPath] = i
			i += 1
		}
	}
}
