//
//  MouseEasing.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 28.06.24.
//

import Foundation

/// Defines the move dynamics of the traveling mouse cursor
enum MouseEasing: Hashable, Identifiable, Codable {
	/// Directly jump to the target mouse coordinates
	case none
	/// Apply a cubic acceleration and deceleration curve with a smoothing factor. The higher the factor, the slower the mouse will move.
	case cubic(factor: CGFloat)
	
	var id: Self {
		return self
	}
}

extension MouseEasing {
	/// If true, mouse movements will have a certain mouse dynamics.
	var isOn: Bool {
		switch self {
			case .none:
				return false
			default:
				return true
		}
	}
}

// MARK: Cubic factor

extension MouseEasing {
	/// Returns the easing factor if cubic mouse easing is chosen
	var cubicFactor: CGFloat? {
		switch self {
			case .cubic(let factor):
				return factor
			default:
				return nil
		}
	}
	
	/// Returns the default easing factor for cubic mouse easing
	static var cubicDefault: MouseEasing {
		MouseEasing.cubic(factor: 300)
	}
	
	/// Maximum reasonable easing factor for cubic mouse easing
	static var cubicUpperBound: CGFloat = 2500
	/// Minimum reasonable easing factor for cubic mouse easing
	static var cubicLowerBound: CGFloat = 50
	
	/// Localized semantic description of the given mouse easing factor (e.g. "Slow", "Medium", etc)
	var cubicSemanticDescription: String {
		switch self {
			case .cubic(let factor):
				let range = Self.cubicUpperBound - Self.cubicLowerBound
				let subrangeLen = range / 5.0
				switch factor {
					case Self.cubicLowerBound..<subrangeLen:
						return NSLocalizedString("Very Fast", tableName: "Localizable", comment: "")
					case subrangeLen..<subrangeLen*2:
						return NSLocalizedString("Fast", tableName: "Localizable", comment: "")
					case subrangeLen*2..<subrangeLen*3:
						return NSLocalizedString("Medium", tableName: "Localizable", comment: "")
					case subrangeLen*3..<subrangeLen*4:
						return NSLocalizedString("Slow", tableName: "Localizable", comment: "")
					case subrangeLen*4...Self.cubicUpperBound:
						return NSLocalizedString("Very Slow", tableName: "Localizable", comment: "")
					default:
						return NSLocalizedString("Out of Range", tableName: "Localizable", comment: "")
				}
			default:
				return ""
		}
	}
}
