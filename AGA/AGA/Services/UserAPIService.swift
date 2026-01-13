//
//  UserAPIService.swift
//  AGA
//
//  Created by AGA Team on 1/1/26.
//

import Foundation
import UIKit

// MARK: - API User Response
struct APIUser: Codable {
    let userId: String
    let username: String
    let displayName: String
    let email: String
    let profileImageURL: String?
    let bio: String?
    let country: String?
    let role: String
    let positionTitle: String?
    let isVerified: Bool?
    let followersCount: Int?
    let followingCount: Int?
    let votesReceived: Int?
    let createdAt: String?
    let updatedAt: String?
}

// MARK: - Auth Response
struct AuthResponse: Codable {
    let success: Bool
    let data: APIUser?
    let message: String?
    let error: String?
}

// MARK: - User API Service
class UserAPIService {
    static let shared = UserAPIService()
    private let baseURL = Config.apiBaseURL
    
    private init() {}
    
    // MARK: - Register
    func register(
        username: String,
        email: String,
        password: String,
        displayName: String,
        role: UserRole,
        country: String? = nil,
        bio: String? = nil
    ) async throws -> APIUser {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "displayName": displayName,
            "role": role == .genius ? "genius" : "regular"
        ]
        
        if let country = country {
            body["country"] = country
        }
        if let bio = bio {
            body["bio"] = bio
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError
        }
        
        let result = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        if httpResponse.statusCode == 201, result.success, let user = result.data {
            return user
        } else {
            throw APIError.custom(result.error ?? "Registration failed")
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> APIUser {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError
        }
        
        let result = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        if httpResponse.statusCode == 200, result.success, let user = result.data {
            return user
        } else {
            throw APIError.custom(result.error ?? "Login failed")
        }
    }
    
    // MARK: - Get Profile
    func getProfile(userId: String) async throws -> APIUser {
        guard let url = URL(string: "\(baseURL)/auth/profile/\(userId)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let result = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        if result.success, let user = result.data {
            return user
        } else {
            throw APIError.custom(result.error ?? "Failed to get profile")
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(
        userId: String,
        displayName: String? = nil,
        bio: String? = nil,
        country: String? = nil,
        profileImageURL: String? = nil
    ) async throws -> APIUser {
        guard let url = URL(string: "\(baseURL)/auth/profile/\(userId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [:]
        if let displayName = displayName { body["displayName"] = displayName }
        if let bio = bio { body["bio"] = bio }
        if let country = country { body["country"] = country }
        if let profileImageURL = profileImageURL { body["profileImageURL"] = profileImageURL }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let result = try JSONDecoder().decode(AuthResponse.self, from: data)

        if result.success, let user = result.data {
            return user
        } else {
            throw APIError.custom(result.error ?? "Failed to update profile")
        }
    }

    // MARK: - Update Genius Profile (Onboarding)
    func updateGeniusProfile(
        userId: String,
        displayName: String,
        country: String,
        bio: String,
        positionCategory: String?,
        positionTitle: String?,
        manifestoShort: String,
        problemSolved: String,
        proofLinks: [String],
        credentials: [String],
        videoIntroURL: String?
    ) async throws -> APIUser {
        guard let url = URL(string: "\(baseURL)/auth/profile/\(userId)/genius") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "displayName": displayName,
            "country": country,
            "bio": bio,
            "manifestoShort": manifestoShort,
            "problemSolved": problemSolved,
            "proofLinks": proofLinks,
            "credentials": credentials,
            "onboardingCompleted": true
        ]

        if let positionCategory = positionCategory { body["positionCategory"] = positionCategory }
        if let positionTitle = positionTitle { body["positionTitle"] = positionTitle }
        if let videoIntroURL = videoIntroURL { body["videoIntroURL"] = videoIntroURL }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }

        let result = try JSONDecoder().decode(AuthResponse.self, from: data)

        if result.success, let user = result.data {
            return user
        } else {
            throw APIError.custom(result.error ?? "Failed to update genius profile")
        }
    }

    // MARK: - Upload Profile Image
    func uploadProfileImage(image: UIImage, userId: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/auth/profile/\(userId)/image") else {
            throw APIError.invalidURL
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.custom("Failed to convert image to data")
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add image file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw APIError.serverError
        }

        let result = try JSONDecoder().decode(AuthResponse.self, from: data)

        if result.success, let user = result.data, let imageURL = user.profileImageURL {
            return imageURL
        } else {
            throw APIError.custom(result.error ?? "Failed to upload profile image")
        }
    }

    // MARK: - Get Geniuses by Category
    func getGeniusesByCategory(category: String) async throws -> [APIUser] {
        var components = URLComponents(string: "\(baseURL)/users/geniuses")!
        components.queryItems = [
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "limit", value: "50")
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }

        struct GeniusesResponse: Codable {
            let success: Bool
            let data: [APIUser]?
            let error: String?
        }

        let result = try JSONDecoder().decode(GeniusesResponse.self, from: data)

        if result.success, let geniuses = result.data {
            return geniuses
        }
        throw APIError.custom(result.error ?? "Failed to get geniuses")
    }
}
