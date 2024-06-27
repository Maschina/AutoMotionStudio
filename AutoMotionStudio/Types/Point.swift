//
//  Point.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import Foundation

struct Point: Codable {
	var x: Double
	var y: Double
	
	init(x: Double, y: Double) {
		self.x = x
		self.y = y
	}
	
	init(_ cgPoint: CGPoint) {
		self.x = cgPoint.x
		self.y = cgPoint.y
	}
	
	var cgPoint: CGPoint {
		CGPoint(x: x, y: y)
	}
}
