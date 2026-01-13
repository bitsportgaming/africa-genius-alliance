//
//  VotingAPIService.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import Foundation

// MARK: - Vote Models
struct VoteRecord: Codable, Identifiable {
    let id: String
    let voterId: String
    let targetId: String
    let targetType: String
    let category: String?
    let outcome: String
    let createdAt: String
    var targetName: String?
    var targetDetails: VoteTargetDetails?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case voterId, targetId, targetType, category, outcome, createdAt, targetName, targetDetails
    }
}

struct VoteTargetDetails: Codable {
    let position: String?
    let country: String?
    let category: String?
    let status: String?
}

struct VotingResponse: Codable {
    let success: Bool
    let data: VoteRecord?
    let error: String?
}

struct VotingHistoryResponse: Codable {
    let success: Bool
    let data: [VoteRecord]?
    let error: String?
}

// MARK: - Voting API Service
class VotingAPIService {
    static let shared = VotingAPIService()
    private let baseURL = Config.apiBaseURL
    
    private init() {}
    
    // MARK: - Vote for Genius
    func voteForGenius(voterId: String, geniusId: String, category: String?) async throws -> VoteRecord {
        guard let url = URL(string: "\(baseURL)/voting/genius") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "voterId": voterId,
            "geniusId": geniusId,
            "category": category ?? ""
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(VotingResponse.self, from: data)

        if response.success, let vote = response.data {
            return vote
        }
        throw APIError.custom(response.error ?? "Failed to vote")
    }

    // MARK: - Vote for Project
    func voteForProject(voterId: String, projectId: String) async throws -> VoteRecord {
        guard let url = URL(string: "\(baseURL)/voting/project") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["voterId": voterId, "projectId": projectId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(VotingResponse.self, from: data)

        if response.success, let vote = response.data {
            return vote
        }
        throw APIError.custom(response.error ?? "Failed to vote")
    }

    // MARK: - Vote on Proposal
    func voteOnProposal(voterId: String, proposalId: String, voteType: String) async throws -> VoteRecord {
        guard let url = URL(string: "\(baseURL)/voting/proposal") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["voterId": voterId, "proposalId": proposalId, "voteType": voteType]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(VotingResponse.self, from: data)

        if response.success, let vote = response.data {
            return vote
        }
        throw APIError.custom(response.error ?? "Failed to vote")
    }

    // MARK: - Get Voting History
    func getVotingHistory(userId: String) async throws -> [VoteRecord] {
        guard let url = URL(string: "\(baseURL)/voting/history/\(userId)") else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(VotingHistoryResponse.self, from: data)
        
        if response.success, let votes = response.data {
            return votes
        }
        throw APIError.custom(response.error ?? "Failed to get history")
    }
}

