//
//  DonationAPIService.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import Foundation

// MARK: - Donation Models
struct DonationRecord: Codable, Identifiable {
    let id: String
    let donorId: String
    let donorName: String
    let recipientId: String
    let recipientName: String
    let recipientType: String
    let amount: Double
    let currency: String
    let paymentMethod: String?
    let status: String
    let message: String?
    let isAnonymous: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case donorId, donorName, recipientId, recipientName, recipientType
        case amount, currency, paymentMethod, status, message, isAnonymous, createdAt
    }
}

struct DonationResponse: Codable {
    let success: Bool
    let data: DonationRecord?
    let error: String?
}

struct DonationsListResponse: Codable {
    let success: Bool
    let data: [DonationRecord]?
    let error: String?
}

struct DonationStatsResponse: Codable {
    let success: Bool
    let data: DonationStats?
    let error: String?
}

struct DonationStats: Codable {
    let totalDonated: Double
    let donationsCount: Int
    let recipientsSupported: Int
    let currency: String
}

// MARK: - Donation API Service
class DonationAPIService {
    static let shared = DonationAPIService()
    private let baseURL = Config.apiBaseURL
    
    private init() {}
    
    // MARK: - Create Donation
    func createDonation(
        donorId: String,
        donorName: String,
        recipientId: String,
        recipientName: String,
        recipientType: String,
        amount: Double,
        currency: String = "USD",
        message: String? = nil,
        isAnonymous: Bool = false
    ) async throws -> DonationRecord {
        guard let url = URL(string: "\(baseURL)/donations") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "donorId": donorId,
            "donorName": donorName,
            "recipientId": recipientId,
            "recipientName": recipientName,
            "recipientType": recipientType,
            "amount": amount,
            "currency": currency,
            "isAnonymous": isAnonymous
        ]
        if let message = message { body["message"] = message }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(DonationResponse.self, from: data)
        
        if response.success, let donation = response.data {
            return donation
        }
        throw APIError.custom(response.error ?? "Failed to create donation")
    }
    
    // MARK: - Get User Donations
    func getUserDonations(userId: String) async throws -> [DonationRecord] {
        guard let url = URL(string: "\(baseURL)/donations/user/\(userId)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(DonationsListResponse.self, from: data)
        
        if response.success, let donations = response.data {
            return donations
        }
        throw APIError.custom(response.error ?? "Failed to get donations")
    }
    
    // MARK: - Get Recipient Donations
    func getRecipientDonations(recipientId: String, recipientType: String) async throws -> [DonationRecord] {
        guard let url = URL(string: "\(baseURL)/donations/recipient/\(recipientId)?type=\(recipientType)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(DonationsListResponse.self, from: data)
        
        if response.success, let donations = response.data {
            return donations
        }
        throw APIError.custom(response.error ?? "Failed to get donations")
    }
    
    // MARK: - Get User Donation Stats
    func getUserDonationStats(userId: String) async throws -> DonationStats {
        guard let url = URL(string: "\(baseURL)/donations/stats/\(userId)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(DonationStatsResponse.self, from: data)
        
        if response.success, let stats = response.data {
            return stats
        }
        throw APIError.custom(response.error ?? "Failed to get stats")
    }
}

