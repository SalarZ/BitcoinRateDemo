//
//  Task.swift
//  BitcoinRateDemo
//
//  Created by Salar on 3/7/26.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds duration: TimeInterval) async throws {
        try await Self.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }
}
