//
//  Notification+PasteboardModel.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 02.07.24.
//

import Foundation

extension TypeSafeNotification {
	/// Notifications when selections in the sidebar have been changed
	static var selectionsChanged: TypeSafeNotification<Set<Action>> { .init(name: .init(#function)) }
}
