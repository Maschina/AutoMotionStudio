//
//  Task+.swift
//  AutoMotionStudio
//
//  Created by Robert Hahn on 27.06.24.
//

import Foundation

extension Task where Success == Never, Failure == Never {
	public static func sleep(seconds: Int) async throws {
		let nanoseconds = UInt64(seconds) * NSEC_PER_SEC
		try await sleep(nanoseconds: nanoseconds)
	}
	
	public static func sleep(timeInterval: TimeInterval) async throws {
		let nanoseconds = UInt64(timeInterval * TimeInterval(NSEC_PER_SEC))
		try await sleep(nanoseconds: nanoseconds)
	}
	
	public static func sleep(milliseconds: Int) async throws {
		let nanoseconds = UInt64(milliseconds) * NSEC_PER_MSEC
		try await sleep(nanoseconds: nanoseconds)
	}
	
	public static func sleep(duration: Duration) async throws {
		let seconds = Double(duration.components.seconds) + Double(duration.components.attoseconds) * 1e-18
		let nanoseconds = UInt64(seconds) * NSEC_PER_SEC
		try await sleep(nanoseconds: nanoseconds)
	}
}
