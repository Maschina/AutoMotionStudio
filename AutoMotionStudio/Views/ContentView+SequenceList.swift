//
//  ContentView+SequenceList.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 05.07.24.
//

import SwiftUI
import SwiftData

extension ContentView {
	struct SequenceList: View {
		@Binding var selectedSequence: Sequence?
		
		@Environment(\.modelContext) private var modelContext
		/// List of sequences from persistent data source
		@Query(sort: \Sequence.listIndex) private var sequences: [Sequence]
		
		var body: some View {
			List(selection: $selectedSequence) {
				ForEach(sequences) { sequence in
					SequenceRowView(
						title: Bindable(sequence).title,
						listIndex: sequence.listIndex
					)
					.padding(.vertical, 3)
					.tag(sequence)
				}
			}
			.listStyle(.sidebar)
		}
	}
}
