//
//  ContentView+SequenceList.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 05.07.24.
//

import SwiftUI
import SwiftData
import SwiftExtensions

extension ContentView {
	struct SequenceList: View {
		@Binding var selectedSequence: Sequence?
		
		@State var searchText: String = ""
		
		@Environment(\.undoManager) var undoManager
		
		@Environment(\.modelContext) private var modelContext
		/// List of sequences from persistent data source
		@Query(sort: \Sequence.listIndex) private var sequences: [Sequence]
		/// Sequence filtered by searchText
		private var filteredSequences: [Sequence] {
			return sequences.filter { sequence in
				sequence.title.fuzzyMatch(searchText, casesensitive: false)
			}
		}
		
		var body: some View {
			VStack(alignment: .leading) {
				List(selection: $selectedSequence) {
					Section {
						ForEach(filteredSequences) { sequence in
							SequenceRowView(
								title: Bindable(sequence).title
							)
							.padding(.vertical, 3)
							.tag(sequence)
						}
					}
				}
				.listStyle(.sidebar)
				.focusedValue(\.delete, deleteSelectedSequence)
				.searchable(
					text: $searchText,
					placement: .sidebar,
					prompt: Text("Sequences")
				)
				.onAppear {
					selectedSequence = sequences.first
				}
				
				Spacer()
				
				// add new sequence
				Button("New Sequence", systemImage: "plus.circle") {
					addSequence()
				}
				.buttonStyle(.borderless)
				.padding()
			}
		}
	}
}

extension ContentView.SequenceList {
	private func addSequence() {
		let sequence = Sequence(title: NSLocalizedString("New Sequence", tableName: "Localizable", comment: ""))
		modelContext.insert(sequence)
		
		selectedSequence = sequence
	}
	
	private func deleteSelectedSequence() {
		guard let selectedSequence else { return }
		
		modelContext.delete(selectedSequence)
		self.selectedSequence = nil
		
		// save before moving ahead with other modifications
		try? modelContext.save()
		
		// make sure to re-order the list indicies
		var s = sequences
		s.reorder(keyPath: \.listIndex)
	}
}
