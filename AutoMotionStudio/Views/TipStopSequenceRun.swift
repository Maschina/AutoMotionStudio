//
//  AutoMotionStudio
//
//  Created by Robert Hahn on 08.07.24.
//

import SwiftUI
import KeyboardShortcuts
import TipKit

struct StopActionShortcutTip: Tip {
	@MainActor
	var title: Text {
		Text("Keyboard Shortcut")
	}
	
	@MainActor
	var message: Text? {
		Text("Press \(KeyboardShortcuts.getShortcut(for: .stopActionExecution)?.description ?? "?") to stop execution")
	}
	
	var image: Image? {
		Image(systemName: "keyboard")
	}
}
