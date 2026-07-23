//
//  UsageService.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-23.
//

import Foundation

protocol UsageService {
    var provider: Provider{ get }
    
    func fetchUsage(for account: Account) async throws -> [UsageWindow]
}
