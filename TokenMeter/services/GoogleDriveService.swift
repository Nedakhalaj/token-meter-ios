//
//  GoogleDriveService.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-09-22.
//

import Foundation

struct GoogleDriveService: UsageService {
    let provider: Provider = .googleDrive

    func fetchUsage(for account: Account) async throws -> [UsageWindow] {
        guard let refreshToken = KeychainHelper.read(for: account.id.uuidString) else {
            throw UsageError.missingKey
        }

        let accessToken = try await accessToken(from: refreshToken)

        var request = URLRequest(url: URL(string:
            "https://www.googleapis.com/drive/v3/about?fields=storageQuota,user")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 401 {
            throw UsageError.invalidKey
        }

        let about = try JSONDecoder().decode(DriveAboutResponse.self, from: data)

        guard let used = about.storageQuota?.usageBytes,
              let limit = about.storageQuota?.limitBytes, limit > 0 else {
            return []
        }

        return [UsageWindow(label: "Storage",
                            fraction: Double(used) / Double(limit),
                            resetsAt: nil)]
    }

    private func accessToken(from refreshToken: String) async throws -> String {
        var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var form = URLComponents()
        form.queryItems = [
            URLQueryItem(name: "client_id",     value: GoogleOAuth.clientID),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "grant_type",    value: "refresh_token")
        ]
        request.httpBody = form.percentEncodedQuery.map { Data($0.utf8) }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw UsageError.invalidKey
        }
        return try JSONDecoder().decode(GoogleTokenResponse.self, from: data).access_token
    }
}
