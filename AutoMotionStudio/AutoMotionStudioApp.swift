//
//  AutoMotionStudioApp.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import SwiftUI
import SwiftData

@main
struct AutoMotionStudioApp: App {
	@State private var appState = AppState.shared
	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	
	var sharedModelContainer: ModelContainer = {
		let schema = Schema([
			Action.self,
		])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		
		do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(appState)
        }
		.defaultSize(width: 700, height: 550)
		.modelContainer(sharedModelContainer)
		
		Settings {
			SettingsView()
		}
    }
}
