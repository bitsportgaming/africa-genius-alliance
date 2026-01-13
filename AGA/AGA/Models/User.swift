//
//  User.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: String
    var username: String
    var displayName: String
    var email: String
    var bio: String?
    var profileImageURL: String?
    var role: UserRole
    var createdAt: Date
    var followersCount: Int
    var followingCount: Int

    // Additional properties for new UI
    var country: String?
    var age: Int?
    var votesReceived: Int

    // Genius-specific properties
    var verificationStatus: VerificationStatus
    var geniusCategory: String?
    var geniusPosition: String?
    var sector: String?
    var isElectoralPosition: Bool

    // Relationships
    @Relationship(deleteRule: .cascade) var posts: [Post]?
    @Relationship(deleteRule: .cascade) var comments: [Comment]?
    @Relationship(deleteRule: .cascade) var likes: [Like]?
    @Relationship(deleteRule: .cascade) var votes: [Vote]?

    init(
        id: String = UUID().uuidString,
        username: String,
        displayName: String,
        email: String,
        bio: String? = nil,
        profileImageURL: String? = nil,
        role: UserRole = .regular,
        createdAt: Date = Date(),
        followersCount: Int = 0,
        followingCount: Int = 0,
        country: String? = nil,
        age: Int? = nil,
        votesReceived: Int = 0,
        verificationStatus: VerificationStatus = .pending,
        geniusCategory: String? = nil,
        geniusPosition: String? = nil,
        sector: String? = nil,
        isElectoralPosition: Bool = false
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.email = email
        self.bio = bio
        self.profileImageURL = profileImageURL
        self.role = role
        self.createdAt = createdAt
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.country = country
        self.age = age
        self.votesReceived = votesReceived
        self.verificationStatus = verificationStatus
        self.geniusCategory = geniusCategory
        self.geniusPosition = geniusPosition
        self.sector = sector
        self.isElectoralPosition = isElectoralPosition
    }

    var isGenius: Bool {
        return role == .genius
    }

    // Computed properties
    var name: String {
        return displayName
    }

    var initials: String {
        let components = displayName.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "??"
    }

    var supportersCount: Int {
        return followersCount
    }
}

