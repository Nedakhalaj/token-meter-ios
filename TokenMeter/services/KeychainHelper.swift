//
//  KeychainHelper.swift
//  TokenMeter
//
//  A small, friendly door in front of iOS's Keychain (the built-in secure vault).
//  The Keychain itself already exists on every iPhone — this just wraps Apple's
//  old, low-level commands behind three clean functions: save, read, delete.
//

import Foundation
import Security   // Apple's framework that talks to the Keychain

enum KeychainHelper {

    /// Store a secret string (like an API key) under a name you choose.
    /// If something is already saved under that name, it's replaced.
    static func save(_ value: String, for account: String) {
        let data = Data(value.utf8)

        // Describe WHICH secret this is: a generic password, named `account`.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
        ]

        // Remove any old copy first, then add the fresh one.
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        SecItemAdd(attributes as CFDictionary, nil)
    }

    /// Read a secret back. Returns nil if nothing is stored under that name.
    static func read(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,        // "give me the value back"
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Delete a secret (e.g. when the user removes the account).
    static func delete(for account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
