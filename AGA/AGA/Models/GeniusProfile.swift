//
//  GeniusProfile.swift
//  AGA
//
//  Created by AGA Team on 12/30/25.
//

import Foundation

// MARK: - Verification Status
enum VerificationStatus: String, Codable {
    case unverified = "UNVERIFIED"
    case pending = "PENDING"
    case verified = "VERIFIED"
    
    var displayName: String {
        switch self {
        case .unverified: return "Unverified"
        case .pending: return "Pending Verification"
        case .verified: return "Verified"
        }
    }
    
    var icon: String {
        switch self {
        case .unverified: return "xmark.circle"
        case .pending: return "clock"
        case .verified: return "checkmark.seal.fill"
        }
    }
}

// MARK: - Live Status
enum LiveStatus: String, Codable {
    case offline = "OFFLINE"
    case live = "LIVE"
}

// MARK: - 24h Stats Delta
struct Stats24h: Codable {
    var votesDelta: Int
    var followersDelta: Int
    var rankDelta: Int
    var profileViewsDelta: Int
    
    init(votesDelta: Int = 0, followersDelta: Int = 0, rankDelta: Int = 0, profileViewsDelta: Int = 0) {
        self.votesDelta = votesDelta
        self.followersDelta = followersDelta
        self.rankDelta = rankDelta
        self.profileViewsDelta = profileViewsDelta
    }
}

// MARK: - Genius Profile
struct GeniusProfile: Codable, Identifiable {
    var id: String { userId }
    var userId: String
    var positionCategory: String
    var positionTitle: String
    var manifestoShort: String
    var verifiedStatus: VerificationStatus
    var rank: Int
    var votesTotal: Int
    var followersTotal: Int
    var likesTotal: Int
    var donationsTotal: Double
    var liveStatus: LiveStatus
    var stats24h: Stats24h
    var lastPostDate: Date?
    var weeklyVotes: [Int] // Last 7 days of votes for sparkline
    
    init(
        userId: String,
        positionCategory: String = "Government",
        positionTitle: String = "Minister",
        manifestoShort: String = "",
        verifiedStatus: VerificationStatus = .unverified,
        rank: Int = 0,
        votesTotal: Int = 0,
        followersTotal: Int = 0,
        likesTotal: Int = 0,
        donationsTotal: Double = 0,
        liveStatus: LiveStatus = .offline,
        stats24h: Stats24h = Stats24h(),
        lastPostDate: Date? = nil,
        weeklyVotes: [Int] = []
    ) {
        self.userId = userId
        self.positionCategory = positionCategory
        self.positionTitle = positionTitle
        self.manifestoShort = manifestoShort
        self.verifiedStatus = verifiedStatus
        self.rank = rank
        self.votesTotal = votesTotal
        self.followersTotal = followersTotal
        self.likesTotal = likesTotal
        self.donationsTotal = donationsTotal
        self.liveStatus = liveStatus
        self.stats24h = stats24h
        self.lastPostDate = lastPostDate
        self.weeklyVotes = weeklyVotes
    }
}

// MARK: - Supporter Stats
struct SupporterStats: Codable {
    var votesCastTotal: Int
    var followsTotal: Int
    var donationsTotal: Double
    
    init(votesCastTotal: Int = 0, followsTotal: Int = 0, donationsTotal: Double = 0) {
        self.votesCastTotal = votesCastTotal
        self.followsTotal = followsTotal
        self.donationsTotal = donationsTotal
    }
}

// MARK: - Alert/Opportunity Item
struct AlertItem: Identifiable {
    var id = UUID()
    var icon: String
    var message: String
    var actionLabel: String
    var destination: String
    var priority: Int // 1 = high, 2 = medium, 3 = low
}

// MARK: - Category Item
struct CategoryItem: Identifiable {
    var id = UUID()
    var name: String
    var icon: String
    var color: String
}

