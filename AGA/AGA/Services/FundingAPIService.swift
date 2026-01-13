//
//  FundingAPIService.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//
//  Uses DonationRecord from DonationAPIService.swift
//

import Foundation

// Note: DonationRecord and DonationResponse are defined in DonationAPIService.swift

struct FundingDonationHistoryResponse: Codable {
    let success: Bool
    let data: [DonationRecord]?
    let error: String?
}

struct TransparencyData: Codable {
    let totalRaised: Double
    let totalDonors: Int
    let totalTransactions: Int
    let byType: DonationByType
    let recentDonations: [RecentDonation]
}

struct DonationByType: Codable {
    let genius: Double
    let project: Double
    let product: Double
}

struct RecentDonation: Codable, Identifiable {
    var id: String { "\(createdAt)-\(amount)" }
    let amount: Double
    let currency: String
    let recipientType: String
    let createdAt: String
    let donorName: String
}

struct TransparencyResponse: Codable {
    let success: Bool
    let data: TransparencyData?
    let error: String?
}

// MARK: - Funding API Service
class FundingAPIService {
    static let shared = FundingAPIService()
    private let baseURL = Config.apiBaseURL
    
    private init() {}
    
    // MARK: - Make Donation
    func donate(donorId: String, donorName: String, recipientId: String, recipientType: String, amount: Double, message: String?, isAnonymous: Bool) async throws -> DonationRecord {
        guard let url = URL(string: "\(baseURL)/funding/donate") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "donorId": donorId,
            "donorName": donorName,
            "recipientId": recipientId,
            "recipientType": recipientType,
            "amount": amount,
            "isAnonymous": isAnonymous
        ]
        if let message = message { body["message"] = message }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(DonationResponse.self, from: data)
        
        if response.success, let donation = response.data {
            return donation
        }
        throw APIError.custom(response.error ?? "Donation failed")
    }
    
    // MARK: - Get Donation History
    func getDonationHistory(userId: String) async throws -> [DonationRecord] {
        guard let url = URL(string: "\(baseURL)/funding/history/\(userId)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(FundingDonationHistoryResponse.self, from: data)
        
        if response.success, let donations = response.data {
            return donations
        }
        throw APIError.custom(response.error ?? "Failed to get history")
    }
    
    // MARK: - Get Transparency Data
    func getTransparencyData() async throws -> TransparencyData {
        guard let url = URL(string: "\(baseURL)/funding/transparency") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TransparencyResponse.self, from: data)
        
        if response.success, let transparencyData = response.data {
            return transparencyData
        }
        throw APIError.custom(response.error ?? "Failed to get data")
    }
}

