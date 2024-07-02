// Copyright (C) 2023 Robert Hahn. All Rights Reserved.

import SwiftUI
import Combine

/// Native Notifications that support type-safety.
///
///
/// # Define custom notification
/// Extend `TypeSafeNotification`  and define a new static like this:
///
/// `static var customNotification: TypeSafeNotification<...> { .init(name: .init(#function)) }`
///
///
/// # Post notification
/// `NotificationCenter.default.post(.customNotiication, data: ...)`
///
///
/// # Observe notifications
/// `NotificationCenter.default.addObserver(for: .customNotification, ...)`
struct TypeSafeNotification<T> {
	let name: NSNotification.Name
}

enum NotificationData<T> {
	case some(T)
	case void
}

private let notificationDataKey = "_notificationData"

extension NotificationCenter {
	/// Creates a given notification with a type-safe parameter to the notification center.
	/// - Parameters:
	///   - notification: Pre-defined notification with the respective type
	///   - data: Type-safe data to be sent with the notification
	func post<T>(_ notification: TypeSafeNotification<T>, data: T) {
		Task.detached { @MainActor [weak self] in
			self?.post(name: notification.name, object: nil, userInfo: [notificationDataKey: NotificationData.some(data)])
		}
	}
	
	func post(_ notification: TypeSafeNotification<Void>) {
		Task.detached { @MainActor [weak self] in
			self?.post(name: notification.name, object: nil, userInfo: [notificationDataKey: NotificationData<Void>.void])
		}
	}
	
	func addObserver<T>(for notification: TypeSafeNotification<T>, queue: OperationQueue? = .main, using block: @escaping (T) -> Void) -> NotificationDisposer {
		let token = addObserver(forName: notification.name, object: nil, queue: queue) { n in
			if let data = n.userInfo?[notificationDataKey] as? NotificationData<T> {
				switch data {
					case .some(let value):
						block(value)
					case .void:
						break // Do nothing for void notifications
				}
			}
		}
		return NotificationDisposer(tokens: [token], center: self)
	}
	
	func notifications<T>(for notification: TypeSafeNotification<T>) -> AsyncStream<T> {
		AsyncStream { continuation in
			let task = Task {
				for await n in NotificationCenter.default.notifications(named: notification.name) {
					if let data = n.userInfo?[notificationDataKey] as? NotificationData<T> {
						switch data {
							case .some(let value):
								continuation.yield(value)
							case .void:
								break // Do nothing for void notifications
						}
					}
				}
			}
			continuation.onTermination = { _ in task.cancel() }
		}
	}
}

extension View {
	/// Adds an action with type-safe payload to perform when this view detects data emitted by the given publisher.
	/// - Parameters:
	///   - notification: The notification to subscribe to.
	///   - block: The action to perform when an event is emitted by publisher. The event's type-safed parameter is passed to the closure.
	/// - Returns: A view that triggers action when publisher emits an event.
	func onReceive<T>(for notification: TypeSafeNotification<T>, perform block: @escaping (T) -> Void) -> some View {
		self.onReceive(NotificationCenter.default.publisher(for: notification.name)) { output in
			if let data = output.userInfo?[notificationDataKey] as? NotificationData<T> {
				switch data {
					case .some(let value):
						block(value)
					case .void:
						break // Do nothing for void notifications
				}
			}
		}
	}
}

class NotificationDisposer: Cancellable {
	private var tokens: [NSObjectProtocol] = []
	private let center: NotificationCenter
	
	init(tokens: [NSObjectProtocol], center: NotificationCenter) {
		self.tokens = tokens
		self.center = center
	}
	
	func addToken(_ token: NSObjectProtocol) {
		tokens.append(token)
	}
	
	deinit {
		cancel()
	}
	
	func cancel() {
		tokens.forEach { center.removeObserver($0) }
		tokens.removeAll()
	}
}

// Extend AnyCancellable to store multiple tokens
extension AnyCancellable {
	func store(in token: NotificationDisposer) {
		token.addToken(self as! NSObjectProtocol)
	}
}
