//
//  PostAPIService.swift
//  AGA
//
//  Created by AGA Team on 01/01/26.
//

import Foundation
import UIKit

// MARK: - API Response Types
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

struct PaginatedResponse<T: Codable>: Codable {
    let success: Bool
    let data: [T]
    let pagination: Pagination?
    let error: String?
}

struct Pagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let pages: Int
}

// MARK: - API Post Model
struct APIPost: Codable, Identifiable {
    let _id: String
    let authorId: String
    let authorName: String
    let authorAvatar: String?
    let authorPosition: String?
    let content: String
    let mediaURLs: [String]?
    let mediaType: String?
    let postType: String?
    let likesCount: Int
    let commentsCount: Int
    let sharesCount: Int
    let likedBy: [String]?
    let isAdminPost: Bool?
    let authorRole: String?
    let declaration: String?
    let createdAt: String
    let updatedAt: String

    var id: String { _id }

    var shouldShowAdminBadge: Bool {
        return isAdminPost == true || authorRole == "admin" || authorRole == "superadmin"
    }

    var hasDeclaration: Bool {
        return declaration != nil && !(declaration?.isEmpty ?? true)
    }

    var createdDate: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt) ?? Date()
    }

    func isLikedBy(userId: String) -> Bool {
        likedBy?.contains(userId) ?? false
    }
}

// MARK: - Post API Service
class PostAPIService {
    static let shared = PostAPIService()
    private let baseURL = Config.apiBaseURL
    
    private init() {}
    
    // MARK: - Get Posts (Feed)
    func getPosts(page: Int = 1, limit: Int = 20, authorId: String? = nil, userId: String? = nil, feedType: String? = nil) async throws -> [APIPost] {
        var urlString = "\(baseURL)/posts?page=\(page)&limit=\(limit)"
        if let authorId = authorId {
            urlString += "&authorId=\(authorId)"
        }
        if let userId = userId, let feedType = feedType {
            urlString += "&userId=\(userId)&feedType=\(feedType)"
        }

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }

        let result = try JSONDecoder().decode(PaginatedResponse<APIPost>.self, from: data)

        if result.success {
            return result.data
        } else {
            throw APIError.custom(result.error ?? "Unknown error")
        }
    }
    
    // MARK: - Create Post with Media
    func createPost(
        authorId: String,
        authorName: String,
        authorAvatar: String?,
        authorPosition: String?,
        content: String,
        images: [UIImage]? = nil,
        videoURL: URL? = nil
    ) async throws -> APIPost {
        guard let url = URL(string: "\(baseURL)/posts") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add text fields
        let fields: [String: String] = [
            "authorId": authorId,
            "authorName": authorName,
            "authorAvatar": authorAvatar ?? "",
            "authorPosition": authorPosition ?? "",
            "content": content
        ]
        
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add images
        if let images = images {
            for (index, image) in images.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"media\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    body.append(imageData)
                    body.append("\r\n".data(using: .utf8)!)
                }
            }
        }
        
        // Add video
        if let videoURL = videoURL, let videoData = try? Data(contentsOf: videoURL) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"media\"; filename=\"video.mp4\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
            body.append(videoData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError
        }
        
        if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
            let result = try JSONDecoder().decode(APIResponse<APIPost>.self, from: data)
            if let post = result.data {
                return post
            }
        }
        
        throw APIError.serverError
    }

    // MARK: - Like/Unlike Post
    func likePost(postId: String, userId: String) async throws -> (post: APIPost, liked: Bool) {
        guard let url = URL(string: "\(baseURL)/posts/\(postId)/like") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["userId": userId]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }

        struct LikeResponse: Codable {
            let success: Bool
            let data: APIPost?
            let liked: Bool
        }

        let result = try JSONDecoder().decode(LikeResponse.self, from: data)

        if result.success, let post = result.data {
            return (post, result.liked)
        }

        throw APIError.serverError
    }

    // MARK: - Delete Post
    func deletePost(postId: String, authorId: String) async throws {
        guard let url = URL(string: "\(baseURL)/posts/\(postId)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["authorId": authorId]
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
    }

    // MARK: - Build full media URL
    func getFullMediaURL(_ path: String) -> URL? {
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        // Remove /api from base URL for static files
        let baseWithoutApi = Config.apiBaseURL.replacingOccurrences(of: "/api", with: "")
        // Ensure path starts with /
        let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
        let urlString = "\(baseWithoutApi)\(normalizedPath)"
        print("📸 Loading image from: \(urlString)")  // Debug log
        return URL(string: urlString)
    }

    // MARK: - Upload Media
    func uploadMedia(image: UIImage, userId: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/posts/upload") else {
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

        // Add user ID field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"userId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)

        // Add image file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"media\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw APIError.serverError
        }

        struct UploadResponse: Codable {
            let success: Bool
            let data: UploadData?
            let error: String?

            struct UploadData: Codable {
                let url: String
            }
        }

        let result = try JSONDecoder().decode(UploadResponse.self, from: data)

        if result.success, let uploadData = result.data {
            return uploadData.url
        } else {
            throw APIError.custom(result.error ?? "Failed to upload image")
        }
    }

    // MARK: - Create Post with Media (Multipart)
    func createPostWithMedia(
        authorId: String,
        authorName: String,
        authorPosition: String,
        content: String,
        images: [UIImage]
    ) async throws -> APIPost {
        guard let url = URL(string: "\(baseURL)/posts") else {
            throw APIError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add text fields
        let fields: [(String, String)] = [
            ("authorId", authorId),
            ("authorName", authorName),
            ("authorPosition", authorPosition),
            ("content", content)
        ]

        for (name, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add images
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"media\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw APIError.serverError
        }

        let result = try JSONDecoder().decode(APIResponse<APIPost>.self, from: data)

        if result.success, let post = result.data {
            return post
        } else {
            throw APIError.custom(result.error ?? "Failed to create post")
        }
    }
}

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case serverError
    case decodingError
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError:
            return "Server error"
        case .decodingError:
            return "Failed to decode response"
        case .custom(let message):
            return message
        }
    }
}

