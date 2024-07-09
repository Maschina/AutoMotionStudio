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
		
		/// Search text for a list fuzzy filter by its title
		@State private var searchText: String = ""
		/// Set the sequence to be deleted. Will trigger a confirmationDialog before deleting the sequence.
		@State private var deleteSequence: Sequence?
		/// Set the id of the sequence that requires focus to rename (row textfield focus)
		@FocusState private var rowIsRenaming: UUID?
		
		@Environment(\.modelContext) private var modelContext
		/// List of sequences from persistent data source
		@Query(sort: \Sequence.listIndex) private var sequences: [Sequence]
		/// Sequence filtered by searchText
		private var filteredSequences: [Sequence] {
			return sequences.filter { sequence in
				sequence.title.fuzzyMatch(searchText, casesensitive: false)
			}
		}
		
		/// Binding for the confirmationDialog when deleting a sequence
		private var confirmDeleteSequence: Binding<Bool> {
			Binding {
				deleteSequence != nil
			} set: { newValue in
				if !newValue {
					deleteSequence = nil
				}
			}
		}
		
		// MARK: Body
		
		var body: some View {
			VStack(alignment: .leading) {
				List(selection: $selectedSequence) {
					Section {
						ForEach(filteredSequences) { sequence in
							SequenceRowView(
								title: Bindable(sequence).title,
								id: sequence.id,
								isRenaming: $rowIsRenaming
							)
							.padding(.vertical, 3)
							.tag(sequence)
							.contextMenu { contextMenu(sequence: sequence) }
						}
					}
				}
				.listStyle(.sidebar)
				// Delete by confirmation
				.focusedValue(\.delete, { deleteSequence = selectedSequence })
				.confirmationDialog("Delete Sequence?", isPresented: confirmDeleteSequence, actions: {
					Button("Confirm", role: .destructive) {
						guard let deleteSequence else { return }
						delete(deleteSequence)
					}
				}, message: {
					Text("Are you sure you want to delete \(deleteSequence?.title ?? "?")")
				})
				// Fuzzy search sequence
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

// MARK: Context menu

extension ContentView.SequenceList {
	@ViewBuilder
	func contextMenu(sequence: Sequence) -> some View {
		Button("Run All Actions", systemImage: "play.fill") {
			let sequenceRunner = SequenceRunModel.shared
			sequenceRunner.run(sequence.actions.sorted(by: \.listIndex, <))
		}
		
		Button("Rename", systemImage: "pencil") {
			rowIsRenaming = sequence.id
		}
		
		Divider()
		
		Button("Delete", systemImage: "trash") {
			deleteSequence = sequence
		}
	}
}

// MARK: List actions

extension ContentView.SequenceList {
	/// Add a new sequence to the list and set focus to renaming that sequence (textfield focus)
	private func addSequence() {
		let sequence = Sequence(title: "\(Date.now.formatted(date: .abbreviated, time: .shortened))")
		modelContext.insert(sequence)
		
		selectedSequence = sequence
		rowIsRenaming = sequence.id
	}
	
	/// Delete the given sequence and resorts all listIndex
	private func delete(_ sequence: Sequence?) {
		guard let sequence else { return }
		
		modelContext.delete(sequence)
		if selectedSequence == sequence {
			self.selectedSequence = nil
		}
		
		// save before moving ahead with other modifications
		try? modelContext.save()
		
		// make sure to re-order the list indicies
		var s = sequences
		s.reorder(keyPath: \.listIndex)
	}
}
