//
//  ClaudeService.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-08-12.
//

import Foundation

struct ClaudeService: UsageService {
    let provider: Provider = .claude

    func fetchUsage(for account: Account) async throws -> [UsageWindow] {
        guard let sessionKey = KeychainHelper.read(for: account.id.uuidString) else {
            throw UsageError.missingKey
        }

        // 1 — which organization? The chat one; an API org has no usage limits.
        let orgsData = try await get("https://claude.ai/api/organizations", sessionKey: sessionKey)
        let orgs = try JSONDecoder().decode([ClaudeOrg].self, from: orgsData)
        guard let orgId = orgs.first(where: { $0.capabilities?.contains("chat") == true })?.uuid else {
            throw UsageError.invalidKey
        }

        // 2 — that org's usage
        let usageData = try await get("https://claude.ai/api/organizations/\(orgId)/usage", sessionKey: sessionKey)
        let usage = try JSONDecoder().decode(ClaudeUsageResponse.self, from: usageData)

        return windows(from: usage)
    }

    // Build a request with Claude's REQUIRED headers, run it, check 401.
    private func get(_ urlString: String, sessionKey: String) async throws -> Data {
        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
        request.setValue("web_claude_ai", forHTTPHeaderField: "anthropic-client-platform")
        request.setValue("https://claude.ai/settings/usage", forHTTPHeaderField: "Referer")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0 Safari/537.36",
                         forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 401 {
            throw UsageError.invalidKey
        }
        // Any other error must not decode into an empty usage response.
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        return data
    }

    // Map Claude's response → our shared UsageWindow list.
    private func windows(from usage: ClaudeUsageResponse) -> [UsageWindow] {
        // Prefer the modern `limits` array.
        if let limits = usage.limits, !limits.isEmpty {
            return limits.compactMap { limit in
                guard let percent = limit.percent else { return nil }
                return UsageWindow(label: label(for: limit.kind),
                                   fraction: percent / 100,
                                   resetsAt: date(from: limit.resets_at))
            }
        }
        // Legacy fallback.
        var result: [UsageWindow] = []
        if let w = usage.five_hour, let u = w.utilization {
            result.append(UsageWindow(label: "5-hour", fraction: u / 100, resetsAt: date(from: w.resets_at)))
        }
        if let w = usage.seven_day, let u = w.utilization {
            result.append(UsageWindow(label: "Weekly", fraction: u / 100, resetsAt: date(from: w.resets_at)))
        }
        return result
    }

    private func label(for kind: String?) -> String {
        switch kind {
        case "session":    return "5-hour"
        case "weekly_all": return "Weekly"
        default:           return kind ?? "Usage"
        }
    }

    private func date(from iso: String?) -> Date? {
        guard let iso else { return nil }
        // Claude usually sends fractional seconds (…00.158365+00:00), but accept both.
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: iso) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: iso)
    }
}
