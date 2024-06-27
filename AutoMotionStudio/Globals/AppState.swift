//
//  AppState.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import Foundation
import Cocoa

@Observable 
final class AppState: ObservableObject {
	static let shared = AppState()
	
	var mouseLocation: NSPoint {
		NSEvent.mouseLocation
	}
	
	var cgMouseLocation: CGPoint {
		let location = self.mouseLocation
		let cgPoint = CGPoint(x: location.x, y: CGDisplayBounds(CGMainDisplayID()).height - location.y)
		return cgPoint
	}
	
	private init() {

	}
}
