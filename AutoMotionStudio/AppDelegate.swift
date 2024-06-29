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
		return true
	}
}
