//
//  Vote.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftData

enum VoteType: String, Codable {
    case upvote
    case downvote
}

@Model
final class Vote {
    @Attribute(.unique) var id: String
    var voteType: VoteType
    var createdAt: Date
    
    // Relationships
    var user: User?
    var post: Post?
    
    init(
        id: String = UUID().uuidString,
        voteType: VoteType,
        createdAt: Date = Date(),
        user: User? = nil,
        post: Post? = nil
    ) {
        self.id = id
        self.voteType = voteType
        self.createdAt = createdAt
        self.user = user
        self.post = post
    }
}

