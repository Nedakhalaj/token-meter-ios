//
//  CodexAuthService.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-09-25.
//

import Foundation

enum CodexOAuth {
    static let clientID = "app_EMoamEEZ73f0CkXaXp7hrann"
    static let userCodeURL = URL(string: "https://auth.openai.com/api/accounts/deviceauth/usercode")!
    static let pollURL = URL(string: "https://auth.openai.com/api/accounts/deviceauth/token")!
    static let tokenURL = URL(string: "https://auth.openai.com/oauth/token")!
    static let verificationURL = URL(string: "https://auth.openai.com/codex/device")!
    static let redirectURI = "https://auth.openai.com/deviceauth/callback"
}

enum CodexAuthError: Error {
    case requestFailed
    case expired
    case declined
}

struct CodexDeviceCode {
    let userCode: String        // what the user types, e.g. "WDJB-MJHT"
    let deviceAuthID: String    // our id for this login, sent back when polling
    let interval: Int           // seconds between polls
}

struct CodexAuthService {

    func requestCode() async throws -> CodexDeviceCode {
        var request = URLRequest(url: CodexOAuth.userCodeURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["client_id": CodexOAuth.clientID])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw CodexAuthError.requestFailed
        }

        let reply = try JSONDecoder().decode(CodexUserCodeResponse.self, from: data)
        return CodexDeviceCode(userCode: reply.code,
                               deviceAuthID: reply.device_auth_id,
                               interval: max(reply.pollSeconds, 2))
    }
    
    /// Waits until the user approves the code, then returns what to store.
    func waitForApproval(_ code: CodexDeviceCode) async throws -> CodexCredential {
        let approval = try await poll(code)
        let tokens = try await exchange(approval)
        return try CodexCredential(tokens: tokens)
    }
    

    /// Trades the refresh token for new tokens. OpenAI returns a NEW refresh token every time.
    func refresh(_ credential: CodexCredential) async throws -> CodexCredential {
        var request = URLRequest(url: CodexOAuth.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode([
            "client_id": CodexOAuth.clientID,
            "grant_type": "refresh_token",
            "refresh_token": credential.refreshToken
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw UsageError.invalidKey        // refresh token no longer works → reconnect
        }
        return try CodexCredential(tokens: JSONDecoder().decode(CodexTokenResponse.self, from: data))
    }



    // Ask "approved yet?" every few seconds, for up to 15 minutes.
    private func poll(_ code: CodexDeviceCode) async throws -> CodexAuthCodeResponse {
        var request = URLRequest(url: CodexOAuth.pollURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode([
            "device_auth_id": code.deviceAuthID,
            "user_code": code.userCode
        ])

        var wait = code.interval
        let deadline = Date().addingTimeInterval(15 * 60)

        while Date() < deadline {
            try await Task.sleep(for: .seconds(wait))

            // A network blip shouldn't end the login. Just try again next round.
            guard let (data, response) = try? await URLSession.shared.data(for: request) else { continue }
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0

            if (200...299).contains(status) {
                return try JSONDecoder().decode(CodexAuthCodeResponse.self, from: data)
            }
            
            if (500...599).contains(status) {
                            continue                                  // OpenAI hiccup: just try again
                        }
            
            let error = (try? JSONDecoder().decode(CodexErrorResponse.self, from: data))?.error

            if error == "slow_down" || status == 429 {
                wait = min(wait + 5, 60)                  // asked too fast: back off
            } else if error == "authorization_pending" || status == 403 || status == 404 {
                continue                                  // not approved yet: keep waiting
            } else if error == "expired_token" {
                throw CodexAuthError.expired
            } else if error == "access_denied" {
                throw CodexAuthError.declined
            } else {
                throw CodexAuthError.requestFailed
            }
        }
        throw CodexAuthError.expired
    }

    // Trade the approval for tokens. Almost identical to Google's exchange().
    private func exchange(_ approval: CodexAuthCodeResponse) async throws -> CodexTokenResponse {
        var request = URLRequest(url: CodexOAuth.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var form = URLComponents()
        form.queryItems = [
            URLQueryItem(name: "grant_type",    value: "authorization_code"),
            URLQueryItem(name: "code",          value: approval.authorization_code),
            URLQueryItem(name: "redirect_uri",  value: CodexOAuth.redirectURI),
            URLQueryItem(name: "client_id",     value: CodexOAuth.clientID),
            URLQueryItem(name: "code_verifier", value: approval.code_verifier)
        ]
        request.httpBody = form.percentEncodedQuery.map { Data($0.utf8) }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw CodexAuthError.requestFailed
        }
        return try JSONDecoder().decode(CodexTokenResponse.self, from: data)
    }

}
