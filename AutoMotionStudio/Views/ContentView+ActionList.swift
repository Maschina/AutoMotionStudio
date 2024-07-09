//
//  ContentView+ActionList.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 05.07.24.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts
import TipKit

extension ContentView {
	struct ActionList: View {
		let selectedWorkflow: Workflow?
		/// Multiple selections the user can choose from the content list
		@Binding var selectedActions: Set<Action>
		/// Model to run all actions
		@State private var workflowRunner = WorkflowRunModel.shared
		/// Toggle to trigger granting accessibility permissions
		@State private var giveAccessibilityPermissions: Bool = false
		
		@Environment(\.modelContext) private var modelContext
		@Query(animation: .default) private var actions: [Action]
		
		init(selectedWorkflow: Workflow?, selectedActions: Binding<Set<Action>>) {
			self._selectedActions = selectedActions
			self.selectedWorkflow = selectedWorkflow
			
			let selectedWorkflowId = selectedWorkflow?.id
			let predicate = #Predicate<Action> {
				$0.workflow?.id == selectedWorkflowId
			}
			self._actions = Query(filter: predicate, sort: \Action.listIndex, animation: .default)
		}
		
		// MARK: Body
		
		var body: some View {
			if let selectedWorkflow {
				List(selection: $selectedActions) {
					ForEach(actions) { action in
						ActionRowView(
							type: action.type,
							listIndex: action.listIndex,
							mouseEasing: action.mouseEasing,
							delay: action.delay
						)
						.padding(.vertical, 3)
						.tag(action)
						.contextMenu {
							contextMenu(focusAction: action)
						}
					}
					.onMove(perform: onMove)
					.onDelete(perform: onDelete)
				}
				.focusedValue(\.delete, { delete(selectedActions) })
				.toolbar {
					Toolbar(
						selectedWorkflow: selectedWorkflow,
						selectedActions: $selectedActions,
						workflowRunner: workflowRunner,
						actions: actions,
						giveAccessibilityPermissions: $giveAccessibilityPermissions
					)
				}
				// manage accessibility permission request
				.sheet(isPresented: $giveAccessibilityPermissions) {
					AccessibilityPermissionRequest(
						giveAccessibilityPermissions: $giveAccessibilityPermissions
					)
				}
				// auto-close accessibility permission request sheet
				.onReceive(for: .windowDidChange) { status in
					switch status {
						case .didBecomeFocused:
							guard giveAccessibilityPermissions, PermissionsService.checkIsTrusted() else { break }
							giveAccessibilityPermissions = false
							
						default:
							break
					}
				}
			} else {
				// no selection
				Text("No Workflow Selected")
					.font(.largeTitle)
					.fontWeight(.light)
					.multilineTextAlignment(.center)
					.foregroundStyle(Color.secondary)
					.padding(.horizontal, 30)
			}
		}
	}
}

// MARK: Accessibility Permission

extension ContentView.ActionList {
	struct AccessibilityPermissionRequest: View {
		@Binding var giveAccessibilityPermissions: Bool
		
		var body: some View {
			NavigationStack {
				VStack(spacing: 20) {
					Image(systemName: "lock.circle")
						.resizable()
						.scaledToFit()
						.frame(height: 50)
						.foregroundStyle(Color.accentColor)
					
					Text("AutoMotion Studio requires Accessibility Permissions to automatically move your mouse and access your keyboard. The granted permissions are used during the workflow run only.")
						.multilineTextAlignment(.center)
					
					Image(.accessibilityPermissions)
						.resizable()
						.scaledToFit()
						.frame(height: 39)
						.shadow(radius: 2, x: 0, y: 1)
				}
				.toolbar {
					ToolbarItem(placement: .confirmationAction) {
						Button("Grant Accessibility Permissions…") {
							PermissionsService.acquireAccessibilityPrivileges()
						}
					}
					
					ToolbarItem(placement: .cancellationAction) {
						Button("Dismiss") {
							giveAccessibilityPermissions = false
						}
					}
				}
			}
			.frame(width: 350)
			.padding()
		}
	}
}

// MARK: Context menu

extension ContentView.ActionList {
	@ViewBuilder
	func contextMenu(focusAction: Action) -> some View {
		if selectedActions.contains(focusAction), selectedActions.count > 1 {
			Section("\(selectedActions.count) Items Selected") {
				Divider()
				
				Button("Preview Selected Actions", systemImage: "play.fill") {
					workflowRunner.run(selectedActions.sorted(by: \.listIndex, <))
				}
				.keyboardShortcut("r", modifiers: [.command, .shift])
				
				Divider()
				
				Button("Delete", systemImage: "trash") {
					delete(selectedActions)
				}
			}
		} else {
			Button("Preview Action", systemImage: "play.fill") {
				workflowRunner.run([focusAction])
			}
			.keyboardShortcut("r", modifiers: [.command, .shift])
			
			Divider()
			
			Button("Delete", systemImage: "trash") {
				delete([focusAction])
			}
			.keyboardShortcut(.delete)
		}
	}
}

// MARK: Toolbar

extension ContentView.ActionList {
	struct Toolbar: ToolbarContent {
		let selectedWorkflow: Workflow
		@Binding var selectedActions: Set<Action>
		let workflowRunner: WorkflowRunModel
		let actions: [Action]
		@Binding var giveAccessibilityPermissions: Bool
		
		@Environment(\.modelContext) private var modelContext
		
		/// Shortcut Tip to stop execution
		private let stopActionShortcutTip = StopActionShortcutTip()
		
		var body: some ToolbarContent {
			// add action button
			ToolbarItem(placement: .confirmationAction) {
				Menu {
					Button(insertAction: .linearMove, workflow: selectedWorkflow, modelContext: modelContext, selectedActions: $selectedActions)
					Divider()
					Button(insertAction: .primaryClick, workflow: selectedWorkflow, modelContext: modelContext, selectedActions: $selectedActions)
					Button(insertAction: .secondaryClick, workflow: selectedWorkflow, modelContext: modelContext, selectedActions: $selectedActions)
					Button(insertAction: .dragStart, workflow: selectedWorkflow, modelContext: modelContext, selectedActions: $selectedActions)
					Button(insertAction: .dragEnd, workflow: selectedWorkflow, modelContext: modelContext, selectedActions: $selectedActions)
				} label: {
					Label("Add Action", systemImage: "plus")
				}
				.menuIndicator(.hidden)
				.disabled(workflowRunner.isExecuting)
			}
			
			if !workflowRunner.isExecuting {
				// runner play button
				ToolbarItem(placement: .primaryAction) {
					Button("Run", systemImage: "play.fill") {
						startWorkflowRunner()
					}
					// Avoid animation
					.transaction { $0.animation = nil }
					.disabled(actions.isEmpty)
				}
			} else {
				// runner stop button
				ToolbarItem(placement: .primaryAction) {
					Button("Stop", systemImage: "stop.fill") {
						stopWorkflowRunner()
					}
					.popoverTip(stopActionShortcutTip, arrowEdge: .trailing)
					.task {
						try? Tips.configure()
					}
				}
			}
		}
		
		private func startWorkflowRunner() {
			guard PermissionsService.checkIsTrusted() else {
				giveAccessibilityPermissions = true
				return
			}
			workflowRunner.run(actions)
		}
		
		private func stopWorkflowRunner() {
			workflowRunner.stop()
		}
	}
}

// MARK: List actions

extension ContentView.ActionList {
	private func onMove(indices: IndexSet, newOffset: Int) {
		var s = actions
		s.move(fromOffsets: indices, toOffset: newOffset)
		// make sure to re-order the list indicies
		s.reorder(keyPath: \.listIndex)
	}
	
	private func onDelete(indices: IndexSet) {
		withAnimation {
			for i in indices {
				let action = actions[i]
				modelContext.delete(action)
				selectedActions.remove(action)
			}
			// save before moving ahead with other modifications
			try? modelContext.save()
			
			// make sure to re-order the list indicies
			var s = actions
			s.reorder(keyPath: \.listIndex)
		}
	}
	
	private func delete(_ actions: Set<Action>) {
		withAnimation {
			for action in actions {
				modelContext.delete(action)
				selectedActions.remove(action)
			}
			// save before moving ahead with other modifications
			try? modelContext.save()
			
			// make sure to re-order the list indicies
			var s = self.actions
			s.reorder(keyPath: \.listIndex)
		}
	}
	
	private func delete(_ actions: [Action]) {
		delete(Set(actions))
	}
}
