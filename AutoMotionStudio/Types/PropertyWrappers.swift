//
//  PropertyWrappers.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import Foundation

@propertyWrapper
struct Clamp<V: Comparable & Codable & Hashable>: Codable, Hashable {
	var value: V
	let range: ClosedRange<V>
	let precision: Int?
	
	init(wrappedValue value: V, _ range: ClosedRange<V>, precision: Int? = nil) {
		self.range = range
		self.value = min(max(range.lowerBound, value), range.upperBound)
		self.precision = precision
	}
	
	var wrappedValue: V {
		get { value }
		set { value = min(max(range.lowerBound, newValue), range.upperBound) }
	}
}

@propertyWrapper
struct ClampFrom<V: Comparable & Codable & Hashable>: Codable, Hashable {
	static func == (lhs: ClampFrom<V>, rhs: ClampFrom<V>) -> Bool {
		lhs.hashValue == rhs.hashValue
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.value)
	}
	
	var value: V
	let range: PartialRangeFrom<V>
	let precision: Int?
	
	init(wrappedValue value: V, _ range: PartialRangeFrom<V>, precision: Int? = nil) {
		self.range = range
		self.value = max(range.lowerBound, value)
		self.precision = precision
	}
	
	var wrappedValue: V {
		get { value }
		set { value = max(range.lowerBound, newValue) }
	}
}
