//
//  AppDelegate.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 29.06.24.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
	private(set) static var windowIsActive: Bool = false
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		// make sure to close the app when last window has been closed by the user
		return true
	}
	
	// MARK: Life cycle
	
	func applicationDidBecomeActive(_ notification: Notification) {
		// The app is in foreground and active
		
		Self.windowIsActive = true
		NotificationCenter.default.post(.windowDidChange, data: .didBecomeFocused)
	}
	
	func applicationDidResignActive(_ notification: Notification) {
		// The app is in background and not active
		
		Self.windowIsActive = false
		NotificationCenter.default.post(.windowDidChange, data: .didResign)
	}
}
