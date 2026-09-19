//
//  GoogleAuthService.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-09-12.
//

import Foundation
import AuthenticationServices

enum GoogleAuthError: Error {
    case noCallback
    case noCode
}

/// What we get back from the login screen.
struct GoogleAuthCode {
    let code: String
    let verifier: String
}

@MainActor
final class GoogleAuthService: NSObject {

    private let clientID = "566157747328-3k56ek5nhc85lof3oq0o3fo9sh2jmqgo.apps.googleusercontent.com"
    private let scope = "https://www.googleapis.com/auth/drive.file"

    private let redirectScheme = "com.googleusercontent.apps.566157747328-3k56ek5nhc85lof3oq0o3fo9sh2jmqgo"
    private var redirectURI: String { redirectScheme + ":/oauth2callback" }

    private var session: ASWebAuthenticationSession?

    func authorize() async throws -> GoogleAuthCode {
        let verifier = PKCE.makeVerifier()
        let challenge = PKCE.makeChallenge(from: verifier)

        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]

        let callbackURL = try await present(url: components.url!)

        guard let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "code" })?.value else {
            throw GoogleAuthError.noCode
        }

        return GoogleAuthCode(code: code, verifier: verifier)
    }

    private func present(url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: redirectScheme
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: GoogleAuthError.noCallback)
                }
            }
            session.presentationContextProvider = self
            session.start()
            self.session = session
        }
    }
}

extension GoogleAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
