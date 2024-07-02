//
//  MouseLocations.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 02.07.24.
//

import Foundation
import Cocoa

struct MouseLocations {
	static var mouseLocation: NSPoint {
		NSEvent.mouseLocation
	}
	
	static var cgMouseLocation: CGPoint {
		let location = Self.mouseLocation
		let cgPoint = CGPoint(x: location.x, y: CGDisplayBounds(CGMainDisplayID()).height - location.y)
		return cgPoint
	}
}
