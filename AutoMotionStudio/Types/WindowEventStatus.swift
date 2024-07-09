//
//  WindowEventStatus.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 09.07.24.
//

import Foundation

enum WindowEventStatus {
	case didBecomeFocused
	case didResign
}

extension TypeSafeNotification {
	static var windowDidChange: TypeSafeNotification<WindowEventStatus> { .init(name: .init(#function)) }
}
