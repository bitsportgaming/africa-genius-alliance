//
//  CommentsView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI
import SwiftData

struct CommentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let post: Post
    
    @State private var viewModel: CommentViewModel?
    @State private var showError = false
    
    private let authService = AuthService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Comments List
                if let viewModel {
                    if viewModel.isLoading {
                        ProgressView("Loading comments...")
                            .frame(maxHeight: .infinity)
                    } else if viewModel.comments.isEmpty {
                        emptyCommentsView
                    } else {
                        commentsList(viewModel: viewModel)
                    }
                    
                    // Comment Input
                    if authService.canComment() {
                        commentInputView(viewModel: viewModel)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = CommentViewModel(modelContext: modelContext, post: post)
                }
                Task {
                    await viewModel?.loadComments()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel?.errorMessage ?? "An error occurred")
            }
        }
    }
    
    private var emptyCommentsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No comments yet")
                .font(.headline)
            
            Text("Be the first to comment!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
    
    private func commentsList(viewModel: CommentViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.comments) { comment in
                    CommentRowView(comment: comment, viewModel: viewModel)
                }
            }
            .padding()
        }
    }
    
    private func commentInputView(viewModel: CommentViewModel) -> some View {
        HStack(spacing: 12) {
            TextField("Add a comment...", text: Binding(
                get: { viewModel.newCommentText },
                set: { viewModel.newCommentText = $0 }
            ), axis: .vertical)
            .textFieldStyle(.roundedBorder)
            .lineLimit(1...4)
            
            Button {
                Task {
                    await postComment(viewModel: viewModel)
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
    
    private func postComment(viewModel: CommentViewModel) async {
        guard let user = authService.currentUser else { return }
        
        do {
            try await viewModel.addComment(by: user)
        } catch {
            showError = true
        }
    }
}

struct CommentRowView: View {
    let comment: Comment
    let viewModel: CommentViewModel
    
    @State private var isLiked = false
    
    private let authService = AuthService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(comment.author?.displayName ?? "Unknown")
                            .fontWeight(.semibold)
                            .font(.subheadline)
                        
                        Text(comment.createdAt.formatted(.relative(presentation: .named)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(comment.content)
                        .font(.body)
                }
                
                Spacer()
            }
            
            HStack {
                Button {
                    toggleLike()
                } label: {
                    Label("\(comment.likesCount)", systemImage: isLiked ? "heart.fill" : "heart")
                        .font(.caption)
                        .foregroundColor(isLiked ? .red : .secondary)
                }
                .disabled(!authService.canLike())
            }
        }
    }
    
    private func toggleLike() {
        guard let user = authService.currentUser else { return }
        
        if !isLiked {
            viewModel.likeComment(comment, by: user)
        }
        isLiked.toggle()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Post.self, User.self, Comment.self, configurations: config)
    
    let user = User(username: "testuser", displayName: "Test User", email: "test@test.com")
    let post = Post(content: "Test post", author: user)
    
    return CommentsView(post: post)
        .modelContainer(container)
}

