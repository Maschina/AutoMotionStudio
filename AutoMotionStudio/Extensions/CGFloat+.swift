//
//  CGFloat+.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import Foundation

extension CGFloat {
	func cubicEaseOut() -> CGFloat {
		if(self < 0.5) {
			return 4 * self * self * self
		} else {
			let f = ((2 * self) - 2)
			return 0.5 * f * f * f + 1
		}
	}

}
