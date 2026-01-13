//
//  GeniusAPIService.swift
//  AGA
//
//  Service to fetch geniuses from API
//

import Foundation

// MARK: - API Genius Model
struct APIGenius: Codable, Identifiable {
    let userId: String
    let username: String
    let displayName: String
    let email: String?
    let profileImageURL: String?
    let bio: String?
    let country: String?
    let role: String
    let positionTitle: String?
    let positionCategory: String?
    let isVerified: Bool?
    let followersCount: Int?
    let followingCount: Int?
    let votesReceived: Int?
    let profileViews: Int?
    let manifestoShort: String?
    
    var id: String { userId }
    
    var initials: String {
        let names = displayName.split(separator: " ")
        if names.count >= 2 {
            return "\(names[0].prefix(1))\(names[1].prefix(1))"
        }
        return String(displayName.prefix(2)).uppercased()
    }
}

// MARK: - Response Types
struct GeniusListResponse: Codable {
    let success: Bool
    let data: [APIGenius]?
    let error: String?
}

// MARK: - Genius API Service
@MainActor
final class GeniusAPIService {
    static let shared = GeniusAPIService()
    
    private let baseURL = "https://api.globalgeniusalliance.org/api"
    
    private init() {}
    
    // MARK: - Get All Geniuses
    func getGeniuses(limit: Int = 50) async throws -> [APIGenius] {
        guard let url = URL(string: "\(baseURL)/users?role=genius&limit=\(limit)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        let result = try JSONDecoder().decode(GeniusListResponse.self, from: data)
        
        if result.success, let geniuses = result.data {
            return geniuses
        } else {
            throw APIError.custom(result.error ?? "Failed to load geniuses")
        }
    }
    
    // MARK: - Follow/Unfollow
    func toggleFollow(followerId: String, geniusId: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/users/\(geniusId)/follow") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["followerId": followerId])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        struct FollowResponse: Codable {
            let success: Bool
            let following: Bool
        }
        
        let result = try JSONDecoder().decode(FollowResponse.self, from: data)
        return result.following
    }
    
    // MARK: - Vote for Genius
    func voteForGenius(voterId: String, geniusId: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/users/\(geniusId)/vote") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["voterId": voterId])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        struct VoteResponse: Codable {
            let success: Bool
        }
        
        let result = try JSONDecoder().decode(VoteResponse.self, from: data)
        return result.success
    }
    
    // MARK: - Get User's Following List
    func getFollowingList(userId: String) async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/users/\(userId)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return []
        }
        
        struct UserResponse: Codable {
            let success: Bool
            let data: UserData?
            struct UserData: Codable {
                let following: [String]?
            }
        }
        
        let result = try JSONDecoder().decode(UserResponse.self, from: data)
        return result.data?.following ?? []
    }
}

