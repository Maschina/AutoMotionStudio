//
//  FocusedValues.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 06.07.24.
//

import SwiftUI

extension FocusedValues {
	struct DeleteValueKey: FocusedValueKey {
		typealias Value = () -> Void
	}
	
	var delete: DeleteValueKey.Value? {
		get { self[DeleteValueKey.self] }
		set { self[DeleteValueKey.self] = newValue }
	}
}
