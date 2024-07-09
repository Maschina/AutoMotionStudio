//
//  PermissionsService.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 08.07.24.
//

import Cocoa

@Observable
final class PermissionsService {
	/// Indicates if accessibility permissions has been granted by the user
	var isGrantedForAccessibility: Bool = AXIsProcessTrusted()
	
	private var pollingTask: Task<(), Never>?
	
	deinit {
		// auto-cancel polling task
		pollingTask?.cancel()
	}
	
	/// Poll the accessibility state every 1 second to check and update the trust status.
	func startPolling() {
		self.pollingTask?.cancel()
		
		self.pollingTask = Task { [weak self] in
			var isGrantedForAccessibility = AXIsProcessTrusted()
			
			while(!isGrantedForAccessibility) {
				try? Task.checkCancellation()
				
				isGrantedForAccessibility = AXIsProcessTrusted()
				self?.isGrantedForAccessibility = isGrantedForAccessibility
				
				try? await Task.sleep(seconds: 1)
			}
		}
	}
	
	func cancelPolling() {
		self.pollingTask?.cancel()
	}
	
	/// Request accessibility permissions, this should prompt macOS to open and present the required dialogue open to the correct page for the user to just hit the add button.
	static func acquireAccessibilityPrivileges() {
		// fake an event to trigger the permission dialog from macOS
		CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)?
			.post(tap: CGEventTapLocation.cghidEventTap)
	}
	
	static func openSystemPrefPrivacyAccessibility() {
		NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
	}
	
	/// One-time check if accessibility permissions has been given by user
	static func checkIsTrusted() -> Bool {
		#if DEBUG
		return true
		#else
		let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
		let enabled = AXIsProcessTrustedWithOptions(options)
		
		return enabled
		#endif
	}
}
