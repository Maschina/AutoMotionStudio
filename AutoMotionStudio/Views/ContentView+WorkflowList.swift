//
//  ContentView+WorkflowList.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 05.07.24.
//

import SwiftUI
import SwiftData
import SwiftExtensions

extension ContentView {
	struct WorkflowList: View {
		@Binding var selectedWorkflow: Workflow?
		
		/// Search text for a list fuzzy filter by its title
		@State private var searchText: String = ""
		/// Set the workflow to be deleted. Will trigger a confirmationDialog before deleting the workflow.
		@State private var deleteWorkflow: Workflow?
		/// Set the id of the workflow that requires focus to rename (row textfield focus)
		@FocusState private var rowIsRenaming: UUID?
		
		@Environment(\.modelContext) private var modelContext
		/// List of workflows from persistent data source
		@Query(sort: \Workflow.listIndex) private var workflows: [Workflow]
		/// Workflow filtered by searchText
		private var filteredWorkflows: [Workflow] {
			return workflows.filter { workflow in
				workflow.title.fuzzyMatch(searchText, casesensitive: false)
			}
		}
		
		/// Binding for the confirmationDialog when deleting a workflow
		private var confirmDeleteWorkflow: Binding<Bool> {
			Binding {
				deleteWorkflow != nil
			} set: { newValue in
				if !newValue {
					deleteWorkflow = nil
				}
			}
		}
		
		// MARK: Body
		
		var body: some View {
			VStack(alignment: .leading) {
				List(selection: $selectedWorkflow) {
					Section {
						ForEach(filteredWorkflows) { workflow in
							WorkflowRowView(
								title: Bindable(workflow).title,
								id: workflow.id,
								isRenaming: $rowIsRenaming
							)
							.padding(.vertical, 3)
							.tag(workflow)
							.contextMenu { contextMenu(workflow: workflow) }
						}
					}
				}
				.listStyle(.sidebar)
				// Delete by confirmation
				.focusedValue(\.delete, { deleteWorkflow = selectedWorkflow })
				.confirmationDialog("Delete Workflow?", isPresented: confirmDeleteWorkflow, actions: {
					Button("Confirm", role: .destructive) {
						guard let deleteWorkflow else { return }
						delete(deleteWorkflow)
					}
				}, message: {
					Text("Are you sure you want to delete \(deleteWorkflow?.title ?? "?")")
				})
				// Fuzzy search workflow
				.searchable(
					text: $searchText,
					placement: .sidebar,
					prompt: Text("Workflows")
				)
				.onAppear {
					selectedWorkflow = workflows.first
				}
				
				Spacer()
				
				// add new workflow
				Button("New Workflow", systemImage: "plus.circle") {
					addWorkflow()
				}
				.buttonStyle(.borderless)
				.padding()
			}
		}
	}
}

// MARK: Context menu

extension ContentView.WorkflowList {
	@ViewBuilder
	func contextMenu(workflow: Workflow) -> some View {
		Button("Run All Actions", systemImage: "play.fill") {
			let workflowRunner = WorkflowRunModel.shared
			workflowRunner.run(workflow.actions.sorted(by: \.listIndex, <))
		}
		
		Button("Rename", systemImage: "pencil") {
			rowIsRenaming = workflow.id
		}
		
		Divider()
		
		Button("Delete", systemImage: "trash") {
			deleteWorkflow = workflow
		}
	}
}

// MARK: List actions

extension ContentView.WorkflowList {
	/// Add a new workflow to the list and set focus to renaming that workflow (textfield focus)
	private func addWorkflow() {
		let workflow = Workflow(title: "\(Date.now.formatted(date: .abbreviated, time: .shortened))")
		modelContext.insert(workflow)
		
		selectedWorkflow = workflow
		rowIsRenaming = workflow.id
	}
	
	/// Delete the given workflow and resorts all listIndex
	private func delete(_ workflow: Workflow?) {
		guard let workflow else { return }
		
		modelContext.delete(workflow)
		if selectedWorkflow == workflow {
			self.selectedWorkflow = nil
		}
		
		// save before moving ahead with other modifications
		try? modelContext.save()
		
		// make sure to re-order the list indicies
		var s = workflows
		s.reorder(keyPath: \.listIndex)
	}
}
