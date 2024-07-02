//
//  AppDelegate.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 29.06.24.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		// make sure to close the app when last window has been closed by the user
		return true
	}
}
