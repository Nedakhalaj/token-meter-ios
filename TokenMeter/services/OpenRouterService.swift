//
//  OpenRouterService.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-07-30.
//

import Foundation

struct OpenRouterService: UsageService {
    let provider: Provider = .openRouter

    func fetchUsage(for account: Account) async throws -> [UsageWindow] {
       
        
        guard let apiKey = KeychainHelper.read(for: account.id.uuidString) else {
            throw UsageError.missingKey
        }

        let url = URL(string: "https://openrouter.ai/api/v1/credits")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 401 {
            throw UsageError.invalidKey
        }
        let decoded = try JSONDecoder().decode(OpenRouterCreditsResponse.self, from: data)

        let total = decoded.data.total_credits
        let used  = decoded.data.total_usage
        let fraction = total > 0 ? used / total : 0

        return [UsageWindow(label: "Credits", fraction: fraction, resetsAt: nil)]
    }
}

enum UsageError: Error {
    case missingKey
    case invalidKey 
}
