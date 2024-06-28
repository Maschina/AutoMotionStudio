//
//  MouseEasing.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 28.06.24.
//

import Foundation

enum MouseEasing: Hashable, Identifiable, Codable {
	case none
	case cubic(factor: CGFloat)
	
	var id: Self {
		return self
	}
}

extension MouseEasing {
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
	var cubicFactor: CGFloat? {
		switch self {
			case .cubic(let factor):
				return factor
			default:
				return nil
		}
	}
	
	static var cubicDefault: MouseEasing {
		MouseEasing.cubic(factor: 300)
	}
	
	static var cubicUpperBound: CGFloat = 2500
	static var cubicLowerBound: CGFloat = 50
	
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
