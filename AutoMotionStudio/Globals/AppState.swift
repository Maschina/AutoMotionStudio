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
	
	private init() {

	}
}
