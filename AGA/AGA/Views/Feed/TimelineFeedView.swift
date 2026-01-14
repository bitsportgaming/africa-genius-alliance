//
//  TimelineFeedView.swift
//  AGA
//
//  Created by AGA Team on 01/01/26.
//

import SwiftUI

struct TimelineFeedView: View {
    @Environment(AuthService.self) private var authService
    @State private var posts: [APIPost] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showCreatePost = false
    @State private var feedFilter: FeedFilter = .all

    enum FeedFilter: String, CaseIterable, Identifiable {
        case all = "All Posts"
        case own = "My Posts"
        case following = "Following"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Feed Filter Picker
                if authService.currentUser != nil {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(FeedFilter.allCases) { filter in
                                Button(action: {
                                    feedFilter = filter
                                    Task { await loadPosts() }
                                }) {
                                    Text(filter.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(feedFilter == filter ? Color(hex: "10b981") : Color(hex: "e5e7eb"))
                                        .foregroundColor(feedFilter == filter ? .white : Color(hex: "6b7280"))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                ZStack {
                    Color(hex: "f9fafb").ignoresSafeArea()

                    if isLoading && posts.isEmpty {
                        ProgressView("Loading posts...")
                            .foregroundColor(Color(hex: "6b7280"))
                    } else if let error = errorMessage, posts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "9ca3af"))
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6b7280"))
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task { await loadPosts() }
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "10b981"))
                        .cornerRadius(20)
                    }
                    .padding()
                } else if posts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "9ca3af"))
                        Text("No posts yet")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "6b7280"))
                        Text("Be the first to share something!")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "9ca3af"))
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(posts) { post in
                                TimelinePostCard(post: post, currentUserId: authService.currentUser?.id ?? "")
                            }
                        }
                        .padding(16)
                    }
                        .refreshable {
                            await loadPosts()
                        }
                    }
                }
                .navigationTitle("Timeline")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showCreatePost = true }) {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(Color(hex: "10b981"))
                        }
                    }
                }
                .sheet(isPresented: $showCreatePost) {
                    CreatePostSheet()
                        .onDisappear {
                            Task { await loadPosts() }
                        }
                }
            }
        }
        .task {
            await loadPosts()
        }
    }

    private func loadPosts() async {
        isLoading = true
        errorMessage = nil

        do {
            // Apply feed filter
            let userId = authService.currentUser?.id
            switch feedFilter {
            case .all:
                posts = try await PostAPIService.shared.getPosts()
            case .own:
                if let userId = userId {
                    posts = try await PostAPIService.shared.getPosts(userId: userId, feedType: "own")
                } else {
                    posts = []
                }
            case .following:
                if let userId = userId {
                    posts = try await PostAPIService.shared.getPosts(userId: userId, feedType: "following")
                } else {
                    posts = []
                }
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

// MARK: - Timeline Post Card
struct TimelinePostCard: View {
    let post: APIPost
    let currentUserId: String
    @State private var isLiked: Bool = false
    @State private var likesCount: Int = 0
    @State private var showComments: Bool = false
    @State private var commentsCount: Int = 0

    init(post: APIPost, currentUserId: String) {
        self.post = post
        self.currentUserId = currentUserId
        _isLiked = State(initialValue: post.isLikedBy(userId: currentUserId))
        _likesCount = State(initialValue: post.likesCount)
        _commentsCount = State(initialValue: post.commentsCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            HStack(spacing: 12) {
                Circle()
                    .fill(DesignSystem.Gradients.genius)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(initials(from: post.authorName))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(post.authorName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "1f2937"))

                        // Gold checkmark for admin posts
                        if post.shouldShowAdminBadge {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "FFD700"))
                        }
                    }
                    Text(post.authorPosition ?? "Member")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6b7280"))
                }
                
                Spacer()
                
                Text(timeAgo(from: post.createdDate))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
            
            // Content
            Text(post.content)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "374151"))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Media
            if let mediaURLs = post.mediaURLs, !mediaURLs.isEmpty {
                mediaSection(urls: mediaURLs, type: post.mediaType ?? "image")
            }

            // Declaration footer for official posts
            if post.hasDeclaration, let declaration = post.declaration {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .background(Color(hex: "e5e7eb"))

                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "3b82f6"))

                        Text(declaration)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6b7280"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(hex: "eff6ff"))
                    .cornerRadius(8)
                }
                .padding(.top, 8)
            }

            // Actions
            HStack(spacing: 24) {
                actionButton(icon: isLiked ? "heart.fill" : "heart", count: likesCount, color: isLiked ? Color(hex: "ef4444") : Color(hex: "6b7280")) {
                    toggleLike()
                }

                actionButton(icon: "bubble.right", count: commentsCount, color: Color(hex: "6b7280")) {
                    showComments = true
                }
                actionButton(icon: "square.and.arrow.up", count: post.sharesCount, color: Color(hex: "6b7280")) { }

                Spacer()
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showComments) {
            APICommentsView(postId: post.id, postAuthorName: post.authorName)
                .onDisappear {
                    // Refresh comments count after closing
                    Task {
                        do {
                            let comments = try await CommentService.shared.getComments(postId: post.id)
                            await MainActor.run {
                                commentsCount = comments.count
                            }
                        } catch { }
                    }
                }
        }
    }

    // MARK: - Media Section
    @ViewBuilder
    private func mediaSection(urls: [String], type: String) -> some View {
        if type == "video" {
            // Video placeholder with watermark
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "1f2937"))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.8))
                    )

                AGAWatermark(opacity: 0.15, fontSize: 20, color: .white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            // Images
            if urls.count == 1 {
                AsyncImage(url: PostAPIService.shared.getFullMediaURL(urls[0])) { phase in
                    switch phase {
                    case .success(let image):
                        ZStack {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 200, maxHeight: 450)

                            // Watermark overlay
                            AGAWatermark(opacity: 0.12, fontSize: 24, color: .white)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "e5e7eb"))
                            .frame(height: 200)
                            .overlay(Image(systemName: "photo").foregroundColor(Color(hex: "9ca3af")))
                    case .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "f3f4f6"))
                            .frame(height: 200)
                            .overlay(ProgressView())
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Grid for multiple images with watermark
                ZStack {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(urls.prefix(4), id: \.self) { urlString in
                            AsyncImage(url: PostAPIService.shared.getFullMediaURL(urlString)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                default:
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "e5e7eb"))
                                        .frame(height: 150)
                                }
                            }
                        }
                    }

                    // Watermark overlay for grid
                    AGAWatermark(opacity: 0.12, fontSize: 18, color: .white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Action Button
    private func actionButton(icon: String, count: Int, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 13))
                }
            }
            .foregroundColor(color)
        }
    }

    // MARK: - Helpers
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let firstInitial = parts.first?.first.map(String.init) ?? ""
        let lastInitial = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (firstInitial + lastInitial).uppercased()
    }

    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        if interval < 604800 { return "\(Int(interval / 86400))d ago" }
        return "\(Int(interval / 604800))w ago"
    }

    private func toggleLike() {
        Task {
            do {
                let result = try await PostAPIService.shared.likePost(postId: post.id, userId: currentUserId)
                await MainActor.run {
                    isLiked = result.liked
                    likesCount = result.post.likesCount
                }
            } catch {
                print("Error toggling like: \(error)")
            }
        }
    }
}

