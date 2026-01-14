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

// MARK: - Blockchain Info
struct APIBlockchainInfo: Codable {
    let transactionHash: String?
    let blockNumber: Int?
    let blockHash: String?
    let gasUsed: String?
    let status: String? // pending, confirmed, failed
    let confirmedAt: String?
    let chainId: Int?
    let explorerUrl: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transactionHash = try container.decodeIfPresent(String.self, forKey: .transactionHash)
        blockNumber = try container.decodeIfPresent(Int.self, forKey: .blockNumber)
        blockHash = try container.decodeIfPresent(String.self, forKey: .blockHash)
        gasUsed = try container.decodeIfPresent(String.self, forKey: .gasUsed)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        confirmedAt = try container.decodeIfPresent(String.self, forKey: .confirmedAt)
        chainId = try container.decodeIfPresent(Int.self, forKey: .chainId)
        explorerUrl = try container.decodeIfPresent(String.self, forKey: .explorerUrl)
    }
}

struct APIElectionBlockchain: Codable {
    let electionIdOnChain: Int?
    let isDeployed: Bool?
    let deployTxHash: String?
    let chainId: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        electionIdOnChain = try container.decodeIfPresent(Int.self, forKey: .electionIdOnChain)
        isDeployed = try container.decodeIfPresent(Bool.self, forKey: .isDeployed)
        deployTxHash = try container.decodeIfPresent(String.self, forKey: .deployTxHash)
        chainId = try container.decodeIfPresent(Int.self, forKey: .chainId)
    }
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
    let totalVoters: Int?
    let blockchain: APIElectionBlockchain?

    var isOnChain: Bool {
        return blockchain?.isDeployed ?? false
    }

    var chainName: String {
        guard let chainId = blockchain?.chainId else { return "BNB Chain" }
        return chainId == 56 ? "BNB Mainnet" : "BNB Testnet"
    }
}

struct APICandidate: Codable {
    let candidateId: String
    let userId: String
    let name: String
    let party: String
    let bio: String?
    let avatarURL: String?
    let manifesto: String?
    let votesReceived: Int
}

struct APIElectionVote: Codable {
    let voteId: String
    let electionId: String
    let userId: String
    let candidateId: String
    let votedAt: String
    let blockchain: APIBlockchainInfo?

    // Computed properties for convenience
    var transactionHash: String? {
        return blockchain?.transactionHash
    }

    var blockNumber: Int? {
        return blockchain?.blockNumber
    }

    var explorerUrl: String? {
        return blockchain?.explorerUrl
    }

    var isConfirmed: Bool {
        return blockchain?.status == "confirmed"
    }
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
    
    // MARK: - Cast Vote (Classic: 1 vote per user per election)
    func castVote(electionId: String, userId: String, candidateId: String) async throws -> VoteResponseData? {
        guard let url = URL(string: "\(baseURL)/\(electionId)/vote") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "userId": userId,
            "candidateId": candidateId
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

    // MARK: - Get Election Results
    func getElectionResults(electionId: String) async throws -> APIElection? {
        guard let url = URL(string: "\(baseURL)/\(electionId)/results") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(SingleElectionResponse.self, from: data)

        return response.data
    }

    // MARK: - Verify Vote on Blockchain
    func verifyVote(electionId: String, transactionHash: String) async throws -> VerifyVoteData? {
        guard let url = URL(string: "\(baseURL)/\(electionId)/verify/\(transactionHash)") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(VerifyVoteResponse.self, from: data)

        return response.data
    }

    // MARK: - Get All Votes (for transparency)
    func getAllVotes(electionId: String) async throws -> [APIElectionVote] {
        guard let url = URL(string: "\(baseURL)/\(electionId)/votes") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AllVotesResponse.self, from: data)

        return response.data ?? []
    }

    // MARK: - Seed Elections (for testing)
    func seedElections() async throws {
        guard let url = URL(string: "\(baseURL)/seed") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: request)
    }
}

// MARK: - Additional Response Types
struct VerifyVoteResponse: Codable {
    let success: Bool
    let data: VerifyVoteData?
}

struct VerifyVoteData: Codable {
    let verified: Bool
    let vote: APIElectionVote?
    let onChainData: OnChainVoteData?
    let message: String?
}

struct OnChainVoteData: Codable {
    let electionId: Int?
    let candidateId: String?
    let timestamp: Int?
    let isValid: Bool?
}

struct AllVotesResponse: Codable {
    let success: Bool
    let data: [APIElectionVote]?
}

