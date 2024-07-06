//
//  SequenceRowView.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 05.07.24.
//

import SwiftUI

struct SequenceRowView: View {
	@Binding var title: String
	
    var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			TextField("Title", text: $title)
		}
    }
}

#Preview {
	SequenceRowView(title: .constant("Row Item"))
}
