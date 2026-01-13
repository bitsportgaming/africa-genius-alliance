//
//  ElectionAPIService.swift
//  AGA
//
//  Created by AGA Team on 1/1/26.
//

import Foundation

// MARK: - API Response Models
struct ElectionResponse: Codable {
    let success: Bool
    let data: [APIElection]?
    let error: String?
}

struct SingleElectionResponse: Codable {
    let success: Bool
    let data: APIElection?
    let error: String?
}

struct VoteResponse: Codable {
    let success: Bool
    let data: VoteResponseData?
    let error: String?
}

struct VoteResponseData: Codable {
    let vote: APIElectionVote?
    let election: APIElection?
    let message: String?
}

struct CheckVoteResponse: Codable {
    let success: Bool
    let data: CheckVoteData?
}

struct CheckVoteData: Codable {
    let hasVoted: Bool
    let vote: APIElectionVote?
}

struct APIElection: Codable {
    let electionId: String
    let title: String
    let description: String
    let position: String
    let country: String
    let region: String?
    let startDate: String
    let endDate: String
    let status: String
    let candidates: [APICandidate]
    let totalVotes: Int
}

struct APICandidate: Codable {
    let candidateId: String
    let userId: String
    let name: String
    let party: String
    let bio: String?
    let avatarURL: String?
    let votesReceived: Int
}

struct APIElectionVote: Codable {
    let voteId: String
    let electionId: String
    let userId: String
    let candidateId: String
    let voteCount: Int
    let transactionHash: String?
    let blockNumber: Int?
    let votedAt: String
}

// MARK: - Election API Service
class ElectionAPIService {
    static let shared = ElectionAPIService()
    private let baseURL = Config.apiBaseURL + "/elections"
    
    private init() {}
    
    // MARK: - Get Active Elections
    func getActiveElections() async throws -> [APIElection] {
        guard let url = URL(string: "\(baseURL)/active") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ElectionResponse.self, from: data)
        
        if let error = response.error {
            throw NSError(domain: "ElectionAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
        }
        
        return response.data ?? []
    }
    
    // MARK: - Get Election by ID
    func getElection(id: String) async throws -> APIElection? {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(SingleElectionResponse.self, from: data)
        
        return response.data
    }
    
    // MARK: - Cast Vote
    func castVote(electionId: String, userId: String, candidateId: String, voteCount: Int = 1) async throws -> VoteResponseData? {
        guard let url = URL(string: "\(baseURL)/\(electionId)/vote") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "userId": userId,
            "candidateId": candidateId,
            "voteCount": voteCount
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(VoteResponse.self, from: data)
        
        if let error = response.error {
            throw NSError(domain: "ElectionAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
        }
        
        return response.data
    }
    
    // MARK: - Check if User Voted
    func checkUserVote(electionId: String, userId: String) async throws -> (hasVoted: Bool, vote: APIElectionVote?) {
        guard let url = URL(string: "\(baseURL)/\(electionId)/check-vote/\(userId)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(CheckVoteResponse.self, from: data)
        
        return (response.data?.hasVoted ?? false, response.data?.vote)
    }
    
    // MARK: - Seed Elections (for testing)
    func seedElections() async throws {
        guard let url = URL(string: "\(baseURL)/seed") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: request)
    }
}

