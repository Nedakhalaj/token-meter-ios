//
//  StubUsageService.swift
//  TokenMeterTests
//
//  Created by neda khalajnejad on 2026-09-02.
//

import Testing
import Foundation

@testable import TokenMeter

struct StubUsageService: UsageService {
    let provider: Provider
    var errorToThrow: Error? = nil
    var windowsToReturn: [UsageWindow] = []
    
    func fetchUsage(for account: Account) async throws -> [UsageWindow] {
        if let errorToThrow { throw errorToThrow}
        return windowsToReturn
    }
    
}



