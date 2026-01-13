//
//  CommentViewModel.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftData

@Observable
class CommentViewModel {
    var comments: [Comment] = []
    var newCommentText: String = ""
    var isLoading = false
    var errorMessage: String?
    
    private let modelContext: ModelContext
    private let post: Post
    
    init(modelContext: ModelContext, post: Post) {
        self.modelContext = modelContext
        self.post = post
    }
    
    // MARK: - Comment Operations
    
    func loadComments() async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch all comments and filter manually due to SwiftData predicate limitations
            let descriptor = FetchDescriptor<Comment>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )

            let allComments = try modelContext.fetch(descriptor)
            comments = allComments.filter { $0.post?.id == post.id }
            isLoading = false
        } catch {
            errorMessage = "Failed to load comments: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func addComment(by user: User) async throws {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CommentError.emptyContent
        }
        
        let comment = Comment(
            content: newCommentText,
            author: user,
            post: post
        )
        
        modelContext.insert(comment)
        post.commentsCount += 1
        
        do {
            try modelContext.save()
            newCommentText = ""
            await loadComments()
        } catch {
            errorMessage = "Failed to add comment: \(error.localizedDescription)"
            throw error
        }
    }
    
    func deleteComment(_ comment: Comment) {
        modelContext.delete(comment)
        post.commentsCount = max(0, post.commentsCount - 1)
        
        do {
            try modelContext.save()
            Task {
                await loadComments()
            }
        } catch {
            errorMessage = "Failed to delete comment: \(error.localizedDescription)"
        }
    }
    
    func likeComment(_ comment: Comment, by user: User) {
        let like = Like(
            likeableType: .comment,
            user: user,
            comment: comment
        )
        
        modelContext.insert(like)
        comment.likesCount += 1
        
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to like comment: \(error.localizedDescription)"
        }
    }
}

// MARK: - Errors

enum CommentError: LocalizedError {
    case emptyContent
    
    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "Comment cannot be empty"
        }
    }
}

