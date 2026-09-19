//
//  PKCE.swift
//  TokenMeter
//
//  Created by neda khalajnejad on 2026-09-12.
//

import Foundation
import CryptoKit

enum PKCE {

    /// A fresh random secret. Never sent until the token exchange.
    static func makeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncoded()
    }

    /// The SHA256 hash of the verifier. This is what Google sees first.
    static func makeChallenge(from verifier: String) -> String {
        let hash = SHA256.hash(data: Data(verifier.utf8))
        return Data(hash).base64URLEncoded()
    }
}

extension Data {
    /// base64, adjusted to be safe inside a URL.
    func base64URLEncoded() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
