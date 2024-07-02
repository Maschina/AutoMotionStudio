//
//  Collection+.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 02.07.24.
//

import Foundation

extension Collection{
	func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>, _ comparator: (_ lhs: Value, _ rhs: Value)->Bool) -> [Element] {
		return self.sorted {
			comparator($0[keyPath: keyPath], $1[keyPath: keyPath])
		}
	}
}
