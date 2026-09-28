//
//  CodexService.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-09-25.
//

import Foundation

struct CodexService: UsageService {
    let provider: Provider = .codex
    private let auth = CodexAuthService()
    private let usageURL = URL(string: "https://chatgpt.com/backend-api/wham/usage")!

    func fetchUsage(for account: Account) async throws -> [UsageWindow] {
        let key = account.id.uuidString
        guard let secret = KeychainHelper.read(for: key),
              var credential = CodexCredential(secret: secret) else {
            throw UsageError.missingKey
        }

        // 1. Refresh early if it's been over 8 days, like the Android app and Codex CLI.
        if Date().timeIntervalSince(credential.lastRefresh) > 8 * 24 * 60 * 60 {
            credential = try await refreshAndSave(credential, key: key)
        }

        // 2. Try with the access token we have.
        if let usage = try await usage(with: credential.accessToken) {
            return windows(from: usage)
        }

        // 3. It was rejected (401): refresh once and try again.
        credential = try await refreshAndSave(credential, key: key)
        guard let usage = try await usage(with: credential.accessToken) else {
            throw UsageError.invalidKey
        }
        return windows(from: usage)
    }

    // Decision A: OpenAI replaced the refresh token, so this service saves the new one itself.
    private func refreshAndSave(_ credential: CodexCredential, key: String) async throws -> CodexCredential {
        let fresh = try await auth.refresh(credential)
        KeychainHelper.save(fresh.secret, for: key)
        return fresh
    }

    // Returns nil on 401, so the caller knows to refresh and retry.
    private func usage(with accessToken: String) async throws -> CodexUsageResponse? {
        var request = URLRequest(url: usageURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36",
                         forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0

        if status == 401 { return nil }
        guard (200...299).contains(status) else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(CodexUsageResponse.self, from: data)
    }

    // Map OpenAI's reply to our shared bars.
    private func windows(from usage: CodexUsageResponse) -> [UsageWindow] {
        [
            window(usage.rate_limit?.primary_window, fallback: "5-hour"),
            window(usage.rate_limit?.secondary_window, fallback: "Weekly")
        ].compactMap { $0 }
    }

    private func window(_ dto: CodexUsageResponse.Window?, fallback: String) -> UsageWindow? {
        guard let dto, let percent = dto.used_percent else { return nil }
        return UsageWindow(
            label: label(seconds: dto.limit_window_seconds, fallback: fallback),
            fraction: min(max(percent / 100, 0), 1),
            resetsAt: dto.reset_after_seconds.map { Date().addingTimeInterval(TimeInterval($0)) }
        )
    }

    // 18000 → "5-hour", 604800 → "Weekly", 172800 → "2-day"
    private func label(seconds: Int?, fallback: String) -> String {
        guard let seconds, seconds > 0 else { return fallback }
        if seconds == 604_800 { return "Weekly" }
        if seconds % 86_400 == 0 { return "\(seconds / 86_400)-day" }
        if seconds % 3_600 == 0 { return "\(seconds / 3_600)-hour" }
        return fallback
    }
}
