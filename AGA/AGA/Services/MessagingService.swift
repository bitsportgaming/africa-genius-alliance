//
//  MessagingService.swift
//  AGA
//
//  Created by AGA Team on 01/01/26.
//

import Foundation

// MARK: - API Models
struct APIConversation: Codable, Identifiable, Hashable {
    let _id: String
    let participants: [String]
    let participantNames: [String]?
    let participantAvatars: [String]?
    let lastMessage: LastMessage?
    let unreadCount: [String: Int]?
    let isGroup: Bool
    let groupName: String?
    let createdAt: String
    let updatedAt: String

    var id: String { _id }

    struct LastMessage: Codable, Hashable {
        let content: String?
        let senderId: String?
        let senderName: String?
        let timestamp: String?
    }

    // Hashable conformance
    static func == (lhs: APIConversation, rhs: APIConversation) -> Bool {
        lhs._id == rhs._id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
    }
    
    func getOtherParticipantName(currentUserId: String) -> String {
        guard let names = participantNames else { return "Unknown" }
        let index = participants.firstIndex(of: currentUserId) == 0 ? 1 : 0
        return index < names.count ? names[index] : "Unknown"
    }
    
    func getUnreadCount(for userId: String) -> Int {
        return unreadCount?[userId] ?? 0
    }
}

struct APIMessage: Codable, Identifiable {
    let _id: String
    let conversationId: String
    let senderId: String
    let senderName: String
    let senderAvatar: String?
    let content: String
    let messageType: String
    let createdAt: String
    
    var id: String { _id }
    
    var createdDate: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt) ?? Date()
    }
}

// MARK: - Messaging Service
class MessagingService {
    static let shared = MessagingService()
    private let baseURL = Config.apiBaseURL
    
    private init() {}
    
    // MARK: - Get Conversations
    func getConversations(userId: String) async throws -> [APIConversation] {
        guard let url = URL(string: "\(baseURL)/messages/conversations?userId=\(userId)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        struct Response: Codable {
            let success: Bool
            let data: [APIConversation]
        }
        
        let result = try JSONDecoder().decode(Response.self, from: data)
        return result.data
    }
    
    // MARK: - Get Messages
    func getMessages(conversationId: String, page: Int = 1, limit: Int = 50) async throws -> [APIMessage] {
        guard let url = URL(string: "\(baseURL)/messages/conversations/\(conversationId)?page=\(page)&limit=\(limit)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        
        struct Response: Codable {
            let success: Bool
            let data: [APIMessage]
        }
        
        let result = try JSONDecoder().decode(Response.self, from: data)
        return result.data
    }
    
    // MARK: - Send Message
    func sendMessage(conversationId: String, senderId: String, senderName: String, content: String) async throws -> APIMessage {
        guard let url = URL(string: "\(baseURL)/messages/conversations/\(conversationId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "senderId": senderId,
            "senderName": senderName,
            "content": content,
            "messageType": "text"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw APIError.serverError
        }
        
        struct Response: Codable {
            let success: Bool
            let data: APIMessage
        }
        
        let result = try JSONDecoder().decode(Response.self, from: data)
        return result.data
    }
    
    // MARK: - Create Conversation
    func createConversation(participants: [String], participantNames: [String]) async throws -> APIConversation {
        guard let url = URL(string: "\(baseURL)/messages/conversations") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "participants": participants,
            "participantNames": participantNames,
            "isGroup": false
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw APIError.serverError
        }
        
        struct Response: Codable {
            let success: Bool
            let data: APIConversation
        }
        
        let result = try JSONDecoder().decode(Response.self, from: data)
        return result.data
    }
    
    // MARK: - Mark as Read
    func markAsRead(conversationId: String, userId: String) async throws {
        guard let url = URL(string: "\(baseURL)/messages/conversations/\(conversationId)/read") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["userId": userId])
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}

