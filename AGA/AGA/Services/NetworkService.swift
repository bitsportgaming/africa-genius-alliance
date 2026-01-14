//
//  NetworkService.swift
//  AGA
//
//  Helper for making authenticated API requests with JWT tokens
//

import Foundation

class NetworkService {
    static let shared = NetworkService()

    private init() {}

    /// Create an authenticated URLRequest with Authorization header
    func createAuthenticatedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add Authorization header with JWT token
        if let token = KeychainService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Adding Authorization header with token")
        }

        return request
    }

    /// Perform an authenticated API request with automatic token handling
    func performAuthenticatedRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError
        }

        // Handle 401 Unauthorized - token expired or invalid
        if httpResponse.statusCode == 401 {
            // Clear stored token and user session
            KeychainService.shared.deleteToken()
            await MainActor.run {
                AuthService.shared.signOut()
            }
            throw APIError.custom("Session expired. Please sign in again.")
        }

        return (data, httpResponse)
    }
}
