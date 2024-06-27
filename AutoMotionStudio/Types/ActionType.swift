//
//  ActionType.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 26.06.24.
//

import Foundation

enum ActionType: Identifiable, CaseIterable {
	case linearMove
	case primaryClick
	case secondaryClick
	case dragStart
	case dragEnd
	
	var id: Self {
		return self
	}
}

extension ActionType: CustomStringConvertible {
	var description: String {
		switch self {
			case .linearMove:
				return NSLocalizedString("Mouse Move", tableName: "Localizable", comment: "")
			case .primaryClick:
				return NSLocalizedString("Primary Click", tableName: "Localizable", comment: "")
			case .secondaryClick:
				return NSLocalizedString("Secondary Click", tableName: "Localizable", comment: "")
			case .dragStart:
				return NSLocalizedString("Drag Start", tableName: "Localizable", comment: "")
			case .dragEnd:
				return NSLocalizedString("Drag End", tableName: "Localizable", comment: "")
		}
	}
}
