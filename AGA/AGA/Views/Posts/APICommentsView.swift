//
//  APICommentsView.swift
//  AGA
//
//  Created by AGA Team on 01/01/26.
//

import SwiftUI

struct APICommentsView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    
    let postId: String
    let postAuthorName: String
    
    @State private var comments: [APIComment] = []
    @State private var newComment = ""
    @State private var isLoading = true
    @State private var isSending = false
    @FocusState private var isInputFocused: Bool
    
    private var currentUserId: String {
        authService.currentUser?.id ?? "currentUser"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Comments List
                if isLoading && comments.isEmpty {
                    Spacer()
                    ProgressView("Loading comments...")
                    Spacer()
                } else if comments.isEmpty {
                    Spacer()
                    emptyView
                    Spacer()
                } else {
                    commentsList
                }
                
                // Input Bar
                commentInputBar
            }
            .background(Color(hex: "f9fafb"))
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .task {
            await loadComments()
        }
    }
    
    // MARK: - Comments List
    private var commentsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(comments) { comment in
                    APICommentRow(
                        comment: comment,
                        currentUserId: currentUserId,
                        postId: postId,
                        onLikeToggled: { updatedComment in
                            if let index = comments.firstIndex(where: { $0.id == updatedComment.id }) {
                                comments[index] = updatedComment
                            }
                        }
                    )
                    Divider().padding(.leading, 60)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(16)
        }
        .refreshable {
            await loadComments()
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "9ca3af"))
            Text("No comments yet")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "6b7280"))
            Text("Be the first to comment!")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "9ca3af"))
        }
    }
    
    // MARK: - Input Bar
    private var commentInputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                TextField("Add a comment...", text: $newComment, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(hex: "f3f4f6"))
                    .cornerRadius(20)
                    .focused($isInputFocused)
                    .lineLimit(1...4)
                
                Button(action: sendComment) {
                    if isSending {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(canSend ? Color(hex: "10b981") : Color(hex: "d1d5db"))
                    }
                }
                .disabled(!canSend || isSending)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
        }
    }
    
    private var canSend: Bool {
        !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func loadComments() async {
        isLoading = true
        do {
            comments = try await CommentService.shared.getComments(postId: postId)
        } catch {
            print("Error loading comments: \(error)")
        }
        isLoading = false
    }
    
    private func sendComment() {
        guard canSend else { return }
        
        let content = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        let authorName = authService.currentUser?.displayName ?? "Anonymous"
        
        isSending = true
        newComment = ""
        
        Task {
            do {
                let comment = try await CommentService.shared.createComment(
                    postId: postId,
                    authorId: currentUserId,
                    authorName: authorName,
                    content: content
                )
                await MainActor.run {
                    comments.insert(comment, at: 0)
                    isSending = false
                }
            } catch {
                print("Error posting comment: \(error)")
                await MainActor.run {
                    newComment = content
                    isSending = false
                }
            }
        }
    }
}

// MARK: - API Comment Row
struct APICommentRow: View {
    let comment: APIComment
    let currentUserId: String
    let postId: String
    let onLikeToggled: (APIComment) -> Void
    
    @State private var isLiking = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            Circle()
                .fill(DesignSystem.Gradients.genius)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(initials)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                // Author & Time
                HStack {
                    Text(comment.authorName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))
                    Text(timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "9ca3af"))
                }
                
                // Content
                Text(comment.content)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "374151"))
                
                // Like button
                Button(action: toggleLike) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 12))
                        Text("\(comment.likesCount)")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(isLiked ? Color(hex: "ef4444") : Color(hex: "9ca3af"))
                }
                .disabled(isLiking)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var initials: String {
        let parts = comment.authorName.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (first + last).uppercased()
    }
    
    private var isLiked: Bool {
        comment.isLiked(by: currentUserId)
    }
    
    private var timeAgo: String {
        let interval = Date().timeIntervalSince(comment.createdDate)
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        return "\(Int(interval / 86400))d"
    }
    
    private func toggleLike() {
        isLiking = true
        Task {
            do {
                let result = try await CommentService.shared.toggleLike(
                    postId: postId,
                    commentId: comment.id,
                    userId: currentUserId
                )
                await MainActor.run {
                    onLikeToggled(result.comment)
                    isLiking = false
                }
            } catch {
                isLiking = false
            }
        }
    }
}

