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
	/// An object that manages the app's lifecycle events.
	@NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	/// A shared model container for persistent data.
	@State private var sharedModelContainer: ModelContainer
	/// A model for managing the pasteboard actions.
	@State private var pasteboardModel: PasteboardModel
	/// A set of actions currently selected by the user. Is being notified by `TypeSafeNotification.selectionsChanged` notification.
	@State private var selectedActions: Set<Action> = []
	
	internal init() {
		let persistence = Container.persistent
		self._sharedModelContainer = State(initialValue: persistence)
		self._pasteboardModel = State(initialValue: PasteboardModel(persistence: persistence))
	}
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(pasteboardModel)
				// receive notification that selections has been changed
				.onReceive(for: .selectionsChanged) { newValue in
					selectedActions = newValue
				}
				// send notification that selections has been changed
				.onChange(of: selectedActions) {
					NotificationCenter.default.post(.selectionsChanged, data: selectedActions)
				}
        }
		.windowStyle(.hiddenTitleBar)
		.windowToolbarStyle(.unified)
		.defaultSize(width: 800, height: 550)
		.commands {
			AppCommands(
				pasteboardModel: pasteboardModel,
				selectedActions: $selectedActions
			)
		}
		.modelContainer(sharedModelContainer)
		
		// app's settings window
		Settings {
			SettingsView()
		}
    }
}
