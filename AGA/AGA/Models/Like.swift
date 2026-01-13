//
//  Like.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftData

enum LikeableType: String, Codable {
    case post
    case comment
}

@Model
final class Like {
    @Attribute(.unique) var id: String
    var createdAt: Date
    var likeableType: LikeableType
    
    // Relationships
    var user: User?
    var post: Post?
    var comment: Comment?
    
    init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        likeableType: LikeableType,
        user: User? = nil,
        post: Post? = nil,
        comment: Comment? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.likeableType = likeableType
        self.user = user
        self.post = post
        self.comment = comment
    }
}

