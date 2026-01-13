//
//  CommentService.swift
//  AGA
//
//  Created by AGA Team on 01/01/26.
//

import Foundation

// MARK: - API Models
struct APIComment: Codable, Identifiable {
    let _id: String
    let postId: String
    let authorId: String
    let authorName: String
    let authorAvatar: String?
    let content: String
    let likesCount: Int
    let likedBy: [String]?
    let repliesCount: Int
    let createdAt: String
    
    var id: String { _id }
    
    var createdDate: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt) ?? Date()
    }
    
    func isLiked(by userId: String) -> Bool {
        likedBy?.contains(userId) ?? false
    }
}

// MARK: - Comment Service
class CommentService {
    static let shared = CommentService()
    private let baseURL = Config.apiBaseURL
    
    private init() {}
    
    // MARK: - Get Comments
    func getComments(postId: String, page: Int = 1, limit: Int = 20) async throws -> [APIComment] {
        guard let url = URL(string: "\(baseURL)/comments/\(postId)?page=\(page)&limit=\(limit)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        struct Response: Codable {
            let success: Bool
            let data: [APIComment]
        }
        
        let result = try JSONDecoder().decode(Response.self, from: data)
        return result.data
    }
    
    // MARK: - Create Comment
    func createComment(postId: String, authorId: String, authorName: String, content: String) async throws -> APIComment {
        guard let url = URL(string: "\(baseURL)/comments/\(postId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "authorId": authorId,
            "authorName": authorName,
            "content": content
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw APIError.serverError
        }
        
        struct Response: Codable {
            let success: Bool
            let data: APIComment
        }
        
        let result = try JSONDecoder().decode(Response.self, from: data)
        return result.data
    }
    
    // MARK: - Like Comment
    func toggleLike(postId: String, commentId: String, userId: String) async throws -> (comment: APIComment, liked: Bool) {
        guard let url = URL(string: "\(baseURL)/comments/\(postId)/\(commentId)/like") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["userId": userId])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        struct Response: Codable {
            let success: Bool
            let data: APIComment
            let liked: Bool
        }
        
        let result = try JSONDecoder().decode(Response.self, from: data)
        return (result.data, result.liked)
    }
    
    // MARK: - Delete Comment
    func deleteComment(postId: String, commentId: String, authorId: String) async throws {
        guard let url = URL(string: "\(baseURL)/comments/\(postId)/\(commentId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["authorId": authorId])
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
    }
}

