//
//  SettingsView.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 28.06.24.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    var body: some View {
		Form {
			Section("Hotkeys") {
				KeyboardShortcuts.Recorder("Get Current Mouse Coordinates", name: .getCurrentMouseCoordinates)
				KeyboardShortcuts.Recorder("Stop Action Execution", name: .stopActionExecution)
			}
		}
		.formStyle(.grouped)
		.frame(maxWidth: 500)
		.frame(height: 150)
    }
}

#Preview {
    SettingsView()
		.frame(width: 400)
		.padding()
}
