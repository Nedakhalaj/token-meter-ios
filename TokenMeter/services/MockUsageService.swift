//
//  MockUsageService.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-23.
//

import Foundation

struct MockUsageService: UsageService {
    let provider: Provider
    var delay: Duration = .seconds(1)
    
    func fetchUsage(for account: Account) async throws -> [UsageWindow] {
        try await Task.sleep(for: delay)
        return [
            UsageWindow(label: "5-hour", fraction: .random(in:0...1), resetsAt: Date().addingTimeInterval(60 * 60 * 2)),
            UsageWindow(label: "7-day", fraction: .random(in: 0...1), resetsAt: Date().addingTimeInterval(60 * 60 * 26))
        ]
    }
}
