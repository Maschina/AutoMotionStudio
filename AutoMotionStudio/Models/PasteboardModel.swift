//
//  AppState.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import Foundation
import SwiftData

/// Model to handle the copy and paste actions
@Observable
final class PasteboardModel {
	private var modelContext: ModelContext
	private var copiedActions: Set<Action> = []
	
	@MainActor
	init(persistence: ModelContainer) {
		self.modelContext = persistence.mainContext
	}
}

extension PasteboardModel {
	/// Indicate if user has copied already something
	var hasCopiedActions: Bool {
		!copiedActions.isEmpty
	}
}

extension PasteboardModel {
	/// List of actions from persistent data source
	private var actions: Actions {
		do {
			return try modelContext.fetch(FetchDescriptor<Action>())
		} catch {
			print("Fetch failed: \(error)")
			return []
		}
	}
}

// MARK: Copy/Paste

extension PasteboardModel {
	/// Copy the given actions into the pasteboard
	/// - Parameter actions: Actions to be copied
	func copy(_ actions: Set<Action>) {
		copiedActions = actions
	}
	
	/// Paste the previously copied actions behind the currently selected location.
	func paste(behind selectedActions: Set<Action>) {
		// paste behind the location of the last selected item
		let listIndexMax = Array(selectedActions).map(\.listIndex).max()
		var listIndex = if let listIndexMax { listIndexMax + 1 } else { 0 }
		
		// shift up list indexes of all existing following items
		let offset = copiedActions.count
		for action in actions.filter({ $0.listIndex >= listIndex }) {
			action.listIndex += offset
		}
		
		// insert copied actions into the context
		for action in copiedActions.sorted(by: \.listIndex, <) {
			let duplicate = action.duplicate
			duplicate.listIndex = listIndex
			modelContext.insert(duplicate)
			listIndex += 1
		}
	}
}
