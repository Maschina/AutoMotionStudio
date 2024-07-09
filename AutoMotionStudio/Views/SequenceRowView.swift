//
//  AutoMotionStudio
//
//  Created by Robert Hahn on 05.07.24.
//

import SwiftUI
import SwiftExtensions

struct WorkflowRowView: View {
	@Binding var title: String
	let id: UUID
	var isRenaming: FocusState<UUID?>.Binding?
	
    var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			TextField("Title", text: $title)
				.ifLet(isRenaming) { view, isRenaming  in // hacky solution, but necessary for Preview
					view.focused(isRenaming, equals: id)
				}
		}
    }
}

extension WorkflowRowView {
	enum FocusedField {
		case title
	}
}

#Preview {
	List {
		WorkflowRowView(
			title: .constant("Row Item"),
			id: UUID(),
			isRenaming: nil
		)
	}
	.frame(width: 200, height: 90)
	.padding()
}
