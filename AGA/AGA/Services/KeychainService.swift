//
//  KeychainService.swift
//  AGA
//
//  Secure token storage using iOS Keychain
//

import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    private let service = "com.aga.app"
    private let tokenKey = "auth_token"

    private init() {}

    /// Save authentication token to Keychain
    func saveToken(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw APIError.custom("Invalid token format")
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]

        // Delete existing token first to avoid duplicate
        SecItemDelete(query as CFDictionary)

        // Add new token
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw APIError.custom("Failed to save token")
        }

        print("✅ Token stored successfully: \(token.prefix(20))...")
    }

    /// Retrieve authentication token from Keychain
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    /// Delete authentication token from Keychain
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]

        SecItemDelete(query as CFDictionary)
        print("🗑️ Token deleted from Keychain")
    }
}
