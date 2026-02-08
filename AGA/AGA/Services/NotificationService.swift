import Foundation

// MARK: - API Notification Model
struct APINotification: Codable, Identifiable {
    let id: String
    let userId: String
    let type: String
    let title: String
    let message: String
    let relatedPostId: String?
    let relatedUserId: String?
    let relatedUserName: String?
    var isRead: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, type, title, message
        case relatedPostId, relatedUserId, relatedUserName
        case isRead, createdAt
    }
}

struct NotificationsResponse: Codable {
    let success: Bool
    let data: [APINotification]?
    let error: String?
}

struct UnreadCountResponse: Codable {
    let success: Bool
    let data: UnreadCountData?
    let error: String?
    
    struct UnreadCountData: Codable {
        let count: Int
    }
}

// MARK: - Notification Service
@MainActor
class NotificationService {
    static let shared = NotificationService()
    private let baseURL = "https://africageniusalliance.com/api"
    
    private init() {}
    
    // Fetch notifications for a user
    func getNotifications(userId: String, limit: Int = 50, unreadOnly: Bool = false) async throws -> [APINotification] {
        var urlString = "\(baseURL)/notifications?userId=\(userId)&limit=\(limit)"
        if unreadOnly {
            urlString += "&unreadOnly=true"
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(NotificationsResponse.self, from: data)
        
        if let error = response.error {
            throw NSError(domain: "NotificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
        }
        
        return response.data ?? []
    }
    
    // Get unread notification count
    func getUnreadCount(userId: String) async throws -> Int {
        guard let url = URL(string: "\(baseURL)/notifications/unread-count?userId=\(userId)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(UnreadCountResponse.self, from: data)
        
        return response.data?.count ?? 0
    }
    
    // Mark a single notification as read
    func markAsRead(notificationId: String) async throws {
        guard let url = URL(string: "\(baseURL)/notifications/\(notificationId)/read") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let _ = try await URLSession.shared.data(for: request)
    }
    
    // Mark all notifications as read
    func markAllAsRead(userId: String) async throws {
        guard let url = URL(string: "\(baseURL)/notifications/read-all") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["userId": userId])
        
        let _ = try await URLSession.shared.data(for: request)
    }
}

