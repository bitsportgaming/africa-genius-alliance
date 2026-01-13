//
//  FeedViewModel.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftData

@Observable
class FeedViewModel {
    var posts: [Post] = []
    var isLoading = false
    var errorMessage: String?
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Feed Operations
    
    func loadFeed() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch posts from SwiftData
            let descriptor = FetchDescriptor<Post>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            posts = try modelContext.fetch(descriptor)
            isLoading = false
        } catch {
            errorMessage = "Failed to load feed: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func refreshFeed() async {
        await loadFeed()
    }
    
    // MARK: - Post Interactions
    
    func likePost(_ post: Post, by user: User) {
        let like = Like(
            likeableType: .post,
            user: user,
            post: post
        )
        
        modelContext.insert(like)
        post.likesCount += 1
        
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to like post: \(error.localizedDescription)"
        }
    }
    
    func unlikePost(_ post: Post, by user: User) {
        // Find and delete the like
        do {
            let descriptor = FetchDescriptor<Like>()
            let allLikes = try modelContext.fetch(descriptor)

            // Filter manually due to SwiftData predicate limitations with optional relationships
            if let like = allLikes.first(where: { $0.post?.id == post.id && $0.user?.id == user.id }) {
                modelContext.delete(like)
                post.likesCount = max(0, post.likesCount - 1)
                try modelContext.save()
            }
        } catch {
            errorMessage = "Failed to unlike post: \(error.localizedDescription)"
        }
    }
    
    func voteOnPost(_ post: Post, voteType: VoteType, by user: User) {
        let vote = Vote(
            voteType: voteType,
            user: user,
            post: post
        )
        
        modelContext.insert(vote)
        
        if voteType == .upvote {
            post.votesCount += 1
        } else {
            post.votesCount -= 1
        }
        
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to vote on post: \(error.localizedDescription)"
        }
    }
    
    func sharePost(_ post: Post) {
        post.sharesCount += 1
        
        do {
            try modelContext.save()
            // TODO: Implement actual sharing functionality
        } catch {
            errorMessage = "Failed to share post: \(error.localizedDescription)"
        }
    }
}

