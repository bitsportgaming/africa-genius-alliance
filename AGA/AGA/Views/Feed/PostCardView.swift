//
//  PostCardView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI

struct PostCardView: View {
    let post: Post
    let viewModel: FeedViewModel
    
    @State private var showComments = false
    @State private var isLiked = false
    @State private var currentVote: VoteType?
    
    private let authService = AuthService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(post.author?.displayName ?? "Unknown")
                            .fontWeight(.semibold)

                        // Gold checkmark for admin posts
                        if post.shouldShowAdminBadge {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(Color(hex: "FFD700"))
                        } else if post.author?.role == .genius {
                            // Star for genius
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(post.createdAt.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Content
            Text(post.content)
                .font(.body)
            
            // Images (if any) with AGA watermark
            if let imageURLs = post.imageURLs, !imageURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(imageURLs, id: \.self) { imageURL in
                            ZStack {
                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 350)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 200, height: 200)
                                }

                                // AGA Watermark overlay
                                AGAWatermark(opacity: 0.10, fontSize: 20, color: .white)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            
            // Interaction Buttons
            HStack(spacing: 20) {
                // Like Button
                Button {
                    toggleLike()
                } label: {
                    Label("\(post.likesCount)", systemImage: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .primary)
                }
                .disabled(!authService.canLike())
                
                // Comment Button
                Button {
                    showComments = true
                } label: {
                    Label("\(post.commentsCount)", systemImage: "bubble.right")
                }
                .disabled(!authService.canComment())
                
                // Vote Buttons
                HStack(spacing: 8) {
                    Button {
                        vote(.upvote)
                    } label: {
                        Image(systemName: currentVote == .upvote ? "arrow.up.circle.fill" : "arrow.up.circle")
                            .foregroundColor(currentVote == .upvote ? .green : .primary)
                    }
                    .disabled(!authService.canVote())
                    
                    Text("\(post.votesCount)")
                        .font(.subheadline)
                        .monospacedDigit()
                    
                    Button {
                        vote(.downvote)
                    } label: {
                        Image(systemName: currentVote == .downvote ? "arrow.down.circle.fill" : "arrow.down.circle")
                            .foregroundColor(currentVote == .downvote ? .red : .primary)
                    }
                    .disabled(!authService.canVote())
                }
                
                Spacer()
                
                // Share Button
                Button {
                    sharePost()
                } label: {
                    Label("\(post.sharesCount)", systemImage: "square.and.arrow.up")
                }
                .disabled(!authService.canShare())
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showComments) {
            CommentsView(post: post)
        }
    }
    
    private func toggleLike() {
        guard let user = authService.currentUser else { return }
        
        if isLiked {
            viewModel.unlikePost(post, by: user)
        } else {
            viewModel.likePost(post, by: user)
        }
        isLiked.toggle()
    }
    
    private func vote(_ voteType: VoteType) {
        guard let user = authService.currentUser else { return }
        
        if currentVote == voteType {
            currentVote = nil
        } else {
            viewModel.voteOnPost(post, voteType: voteType, by: user)
            currentVote = voteType
        }
    }
    
    private func sharePost() {
        viewModel.sharePost(post)
        // TODO: Implement actual share sheet
    }
}

