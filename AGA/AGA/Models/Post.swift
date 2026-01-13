//
//  Post.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftData

@Model
final class Post {
    @Attribute(.unique) var id: String
    var content: String
    var imageURLs: [String]?
    var createdAt: Date
    var updatedAt: Date
    var likesCount: Int
    var commentsCount: Int
    var votesCount: Int
    var sharesCount: Int
    var isAdminPost: Bool
    var authorRole: String?

    // Relationships
    var author: User?
    @Relationship(deleteRule: .cascade) var comments: [Comment]?
    @Relationship(deleteRule: .cascade) var likes: [Like]?
    @Relationship(deleteRule: .cascade) var votes: [Vote]?

    init(
        id: String = UUID().uuidString,
        content: String,
        author: User? = nil,
        imageURLs: [String]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        likesCount: Int = 0,
        commentsCount: Int = 0,
        votesCount: Int = 0,
        sharesCount: Int = 0,
        isAdminPost: Bool = false,
        authorRole: String? = nil
    ) {
        self.id = id
        self.content = content
        self.author = author
        self.imageURLs = imageURLs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.votesCount = votesCount
        self.sharesCount = sharesCount
        self.isAdminPost = isAdminPost
        self.authorRole = authorRole
    }

    /// Returns true if this post should show a gold admin checkmark
    var shouldShowAdminBadge: Bool {
        return isAdminPost || author?.role.isAdmin == true
    }
}

