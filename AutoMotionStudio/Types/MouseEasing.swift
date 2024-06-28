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
	
	static var cubicUpperBound: CGFloat = 3000
	static var cubicLowerBound: CGFloat = 50
}
