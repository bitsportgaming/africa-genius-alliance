//
//  Proposal.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import Foundation
import SwiftData

@Model
final class Proposal {
    @Attribute(.unique) var id: String
    var title: String
    var proposalDescription: String
    var createdAt: Date
    var closesAt: Date
    var yesVotes: Int
    var noVotes: Int
    var quorumRequired: Int
    var status: ProposalStatus
    
    // Relationships
    @Relationship(deleteRule: .cascade) var proposalVotes: [ProposalVote]?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        proposalDescription: String,
        createdAt: Date = Date(),
        closesAt: Date,
        yesVotes: Int = 0,
        noVotes: Int = 0,
        quorumRequired: Int = 50,
        status: ProposalStatus = .active
    ) {
        self.id = id
        self.title = title
        self.proposalDescription = proposalDescription
        self.createdAt = createdAt
        self.closesAt = closesAt
        self.yesVotes = yesVotes
        self.noVotes = noVotes
        self.quorumRequired = quorumRequired
        self.status = status
    }
    
    var totalVotes: Int {
        return yesVotes + noVotes
    }
    
    var yesPercentage: Int {
        guard totalVotes > 0 else { return 0 }
        return Int((Double(yesVotes) / Double(totalVotes)) * 100)
    }
    
    var noPercentage: Int {
        guard totalVotes > 0 else { return 0 }
        return Int((Double(noVotes) / Double(totalVotes)) * 100)
    }
    
    var quorumPercentage: Int {
        return yesPercentage
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: closesAt)
        return max(0, components.day ?? 0)
    }
}

enum ProposalStatus: String, Codable {
    case active = "Active"
    case passed = "Passed"
    case rejected = "Rejected"
    case expired = "Expired"
}

@Model
final class ProposalVote {
    @Attribute(.unique) var id: String
    var userId: String
    var proposalId: String
    var vote: Bool // true = yes, false = no
    var votedAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        proposalId: String,
        vote: Bool,
        votedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.proposalId = proposalId
        self.vote = vote
        self.votedAt = votedAt
    }
}

