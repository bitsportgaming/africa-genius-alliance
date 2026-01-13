//
//  LiveStreamService.swift
//  AGA
//
//  Created by AGA Team on 01/01/26.
//

import Foundation

// MARK: - API Models
struct APILiveStream: Codable, Identifiable, Hashable {
    let _id: String
    let hostId: String
    let hostName: String
    let hostAvatar: String?
    let hostPosition: String?
    let title: String
    let description: String?
    let thumbnailURL: String?
    let status: String
    let scheduledStartTime: String?
    let actualStartTime: String?
    let endTime: String?
    let viewerCount: Int
    let peakViewerCount: Int
    let totalViews: Int
    let currentViewers: [String]?
    let likesCount: Int
    let likedBy: [String]?
    let commentsCount: Int
    let category: String?
    let tags: [String]?
    let createdAt: String
    let updatedAt: String
    
    var id: String { _id }
    
    var isLive: Bool { status == "live" }
    
    func isLikedBy(userId: String) -> Bool {
        likedBy?.contains(userId) ?? false
    }
    
    static func == (lhs: APILiveStream, rhs: APILiveStream) -> Bool {
        lhs._id == rhs._id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
    }
}

// MARK: - Response Types
struct LiveStreamResponse: Codable {
    let success: Bool
    let data: APILiveStream?
    let isLive: Bool?
}

struct LiveStreamsResponse: Codable {
    let success: Bool
    let data: [APILiveStream]
}

struct LiveStreamLikeResponse: Codable {
    let success: Bool
    let data: APILiveStream
    let liked: Bool
}

// MARK: - Service
class LiveStreamService {
    static let shared = LiveStreamService()
    private let baseURL = Config.apiBaseURL

    private init() {}

    // MARK: - Get Active Streams
    func getActiveStreams() async throws -> [APILiveStream] {
        guard let url = URL(string: "\(baseURL)/live") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(LiveStreamsResponse.self, from: data)
        return response.data
    }
    
    // MARK: - Get Stream by ID
    func getStream(id: String) async throws -> APILiveStream? {
        guard let url = URL(string: "\(baseURL)/live/\(id)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(LiveStreamResponse.self, from: data)
        return response.data
    }

    // MARK: - Check if Host is Live
    func checkHostLive(hostId: String) async throws -> APILiveStream? {
        guard let url = URL(string: "\(baseURL)/live/host/\(hostId)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(LiveStreamResponse.self, from: data)
        return response.data
    }

    // MARK: - Start Live Stream
    func startStream(hostId: String, hostName: String, hostAvatar: String?, hostPosition: String?, title: String, description: String?) async throws -> APILiveStream {
        guard let url = URL(string: "\(baseURL)/live/start") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any?] = [
            "hostId": hostId, "hostName": hostName, "hostAvatar": hostAvatar,
            "hostPosition": hostPosition, "title": title, "description": description
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(LiveStreamResponse.self, from: data)
        guard let stream = response.data else { throw URLError(.badServerResponse) }
        return stream
    }

    // MARK: - Stop Live Stream
    func stopStream(streamId: String) async throws -> APILiveStream {
        guard let url = URL(string: "\(baseURL)/live/\(streamId)/stop") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{}".data(using: .utf8)
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(LiveStreamResponse.self, from: data)
        guard let stream = response.data else { throw URLError(.badServerResponse) }
        return stream
    }

    // MARK: - Join Stream
    func joinStream(streamId: String, userId: String) async throws -> APILiveStream {
        guard let url = URL(string: "\(baseURL)/live/\(streamId)/join") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["userId": userId])
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(LiveStreamResponse.self, from: data)
        guard let stream = response.data else { throw URLError(.badServerResponse) }
        return stream
    }

    // MARK: - Leave Stream
    func leaveStream(streamId: String, userId: String) async throws -> APILiveStream {
        guard let url = URL(string: "\(baseURL)/live/\(streamId)/leave") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["userId": userId])
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(LiveStreamResponse.self, from: data)
        guard let stream = response.data else { throw URLError(.badServerResponse) }
        return stream
    }

    // MARK: - Like Stream
    func likeStream(streamId: String, userId: String) async throws -> (stream: APILiveStream, liked: Bool) {
        guard let url = URL(string: "\(baseURL)/live/\(streamId)/like") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["userId": userId])
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(LiveStreamLikeResponse.self, from: data)
        return (response.data, response.liked)
    }
}

