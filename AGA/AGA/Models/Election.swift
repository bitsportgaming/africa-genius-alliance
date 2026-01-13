//
//  Election.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import Foundation
import SwiftData

@Model
final class Election {
    @Attribute(.unique) var id: String
    var title: String
    var position: String
    var country: String
    var electionDescription: String
    var startDate: Date
    var endDate: Date
    var status: ElectionStatus
    
    // Relationships
    @Relationship(deleteRule: .cascade) var candidates: [Candidate]?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        position: String,
        country: String,
        electionDescription: String,
        startDate: Date = Date(),
        endDate: Date,
        status: ElectionStatus = .active
    ) {
        self.id = id
        self.title = title
        self.position = position
        self.country = country
        self.electionDescription = electionDescription
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
    }
}

enum ElectionStatus: String, Codable {
    case upcoming = "Upcoming"
    case active = "Active"
    case completed = "Completed"
}

@Model
final class Candidate {
    @Attribute(.unique) var id: String
    var userId: String
    var electionId: String
    var party: String
    var votesReceived: Int
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        electionId: String,
        party: String,
        votesReceived: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.electionId = electionId
        self.party = party
        self.votesReceived = votesReceived
    }
}

@Model
final class ElectionVote {
    @Attribute(.unique) var id: String
    var userId: String
    var electionId: String
    var candidateId: String
    var voteCount: Int
    var votedAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        electionId: String,
        candidateId: String,
        voteCount: Int = 1,
        votedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.electionId = electionId
        self.candidateId = candidateId
        self.voteCount = voteCount
        self.votedAt = votedAt
    }
}

