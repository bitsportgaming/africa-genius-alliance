//
//  Comment.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftData

@Model
final class Comment {
    @Attribute(.unique) var id: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var likesCount: Int
    
    // Relationships
    var author: User?
    var post: Post?
    @Relationship(deleteRule: .cascade) var likes: [Like]?
    
    init(
        id: String = UUID().uuidString,
        content: String,
        author: User? = nil,
        post: Post? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        likesCount: Int = 0
    ) {
        self.id = id
        self.content = content
        self.author = author
        self.post = post
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.likesCount = likesCount
    }
}

