//
//  ProposalAPIService.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import Foundation

// MARK: - Proposal Models
struct ProposalRecord: Codable, Identifiable {
    let id: String
    let proposalId: String
    let title: String
    let description: String
    let category: String
    let proposerId: String
    let proposerName: String
    let status: String
    let votesFor: Int
    let votesAgainst: Int
    let votesAbstain: Int
    let quorumRequired: Int
    let passingThreshold: Int
    let startDate: String
    let endDate: String
    let implementationDetails: String?
    let impact: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case proposalId, title, description, category, proposerId, proposerName
        case status, votesFor, votesAgainst, votesAbstain
        case quorumRequired, passingThreshold, startDate, endDate
        case implementationDetails, impact, createdAt
    }
    
    var totalVotes: Int { votesFor + votesAgainst + votesAbstain }
    
    var forPercentage: Int {
        guard totalVotes > 0 else { return 0 }
        return Int(round(Double(votesFor) / Double(totalVotes) * 100))
    }
    
    var againstPercentage: Int {
        guard totalVotes > 0 else { return 0 }
        return Int(round(Double(votesAgainst) / Double(totalVotes) * 100))
    }
    
    var quorumProgress: Double {
        guard quorumRequired > 0 else { return 0 }
        return min(Double(totalVotes) / Double(quorumRequired), 1.0)
    }
}

struct ProposalsResponse: Codable {
    let success: Bool
    let data: [ProposalRecord]?
    let error: String?
}

struct SingleProposalResponse: Codable {
    let success: Bool
    let data: ProposalRecord?
    let error: String?
}

// MARK: - Proposal API Service
class ProposalAPIService {
    static let shared = ProposalAPIService()
    private let baseURL = Config.apiBaseURL
    
    private init() {}
    
    // MARK: - Get Active Proposals
    func getActiveProposals() async throws -> [ProposalRecord] {
        guard let url = URL(string: "\(baseURL)/proposals/active") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ProposalsResponse.self, from: data)
        
        if response.success, let proposals = response.data {
            return proposals
        }
        throw APIError.custom(response.error ?? "Failed to get proposals")
    }
    
    // MARK: - Get All Proposals
    func getProposals(category: String? = nil, status: String? = nil) async throws -> [ProposalRecord] {
        var components = URLComponents(string: "\(baseURL)/proposals")!
        var queryItems: [URLQueryItem] = []
        if let category = category { queryItems.append(URLQueryItem(name: "category", value: category)) }
        if let status = status { queryItems.append(URLQueryItem(name: "status", value: status)) }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        
        guard let url = components.url else { throw APIError.invalidURL }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ProposalsResponse.self, from: data)
        
        if response.success, let proposals = response.data {
            return proposals
        }
        throw APIError.custom(response.error ?? "Failed to get proposals")
    }
    
    // MARK: - Get Single Proposal
    func getProposal(proposalId: String) async throws -> ProposalRecord {
        guard let url = URL(string: "\(baseURL)/proposals/\(proposalId)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(SingleProposalResponse.self, from: data)
        
        if response.success, let proposal = response.data {
            return proposal
        }
        throw APIError.custom(response.error ?? "Proposal not found")
    }
    
    // MARK: - Create Proposal
    func createProposal(title: String, description: String, category: String, proposerId: String, proposerName: String, endDate: Date) async throws -> ProposalRecord {
        guard let url = URL(string: "\(baseURL)/proposals") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = ISO8601DateFormatter()
        let body: [String: Any] = [
            "title": title,
            "description": description,
            "category": category,
            "proposerId": proposerId,
            "proposerName": proposerName,
            "endDate": formatter.string(from: endDate)
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(SingleProposalResponse.self, from: data)
        
        if response.success, let proposal = response.data {
            return proposal
        }
        throw APIError.custom(response.error ?? "Failed to create proposal")
    }
}

