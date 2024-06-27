//
//  CGPoint+.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import Foundation

extension CGPoint {
	func distance(to: CGPoint) -> CGFloat {
		let distanceX = self.x - to.x
		let distanceY = self.y - to.y
		return sqrt(distanceX * distanceX + distanceY * distanceY)
	}
}
