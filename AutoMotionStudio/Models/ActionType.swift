//
//  ActionType.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import Foundation

enum ActionType: String, Identifiable, CaseIterable {
	case mouseMove = "Mouse Move"
	case mousePrimaryClick = "Mouse Primary Click"
	case mouseSecondaryClick = "Mouse Secondary Click"
	case mousePrimaryDrag = "Mouse Primary Drag"
	case mouseSecondaryDrag = "Mouse Secondary Drag"
	
	var id: String { self.rawValue }
}
