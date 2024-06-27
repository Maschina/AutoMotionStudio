//
//  AutoMotionStudioApp.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import SwiftUI

@main
struct AutoMotionStudioApp: App {
	@State private var appState = AppState.shared
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(appState)
        }
    }
}
