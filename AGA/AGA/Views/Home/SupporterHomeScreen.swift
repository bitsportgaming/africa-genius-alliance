//
//  SupporterHomeScreen.swift
//  AGA
//
//  Created by AGA Team on 12/30/25.
//

import SwiftUI

struct SupporterHomeScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var homeData: SupporterHomeData?
    @State private var feedPosts: [FeedPost] = []
    @State private var isLoading = true
    @State private var selectedFilter = "For You"
    @State private var showSearch = false
    @State private var showGeniusDetail: TrendingGenius?
    @State private var showCategoryDetail: CategoryItem?
    @State private var showComments: FeedPost?
    @State private var showShareSheet: FeedPost?
    @State private var bookmarkedPosts: Set<String> = []
    @State private var liveStreams: [APILiveStream] = []
    @State private var selectedLiveStream: APILiveStream?
    @State private var showInbox = false
    @State private var showVoteSuccess = false
    @State private var votedGeniusName: String = ""
    @State private var showProfile = false

    private var followManager: FollowManager { FollowManager.shared }

    private let filters = ["For You", "Following", "Trending", "Live"]

    private var userName: String {
        authViewModel.currentUser?.fullName ?? "Supporter"
    }

    private var userInitials: String {
        let components = userName.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(userName.prefix(2)).uppercased()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "f9fafb").ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                } else {
                    ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Top Bar
                        HomeTopBar(
                            greeting: "Welcome back, \(userName.split(separator: " ").first ?? "Supporter")",
                            subtitle: "Discover and support African Geniuses",
                            avatarURL: authViewModel.currentUser?.profileImageURL,
                            initials: userInitials,
                            onNotificationTap: {
                                HapticFeedback.impact(.light)
                                showInbox = true
                            },
                            onAvatarTap: {
                                HapticFeedback.impact(.light)
                                showProfile = true
                            },
                            onSearchTap: { showSearch = true }
                        )

                        VStack(spacing: 20) {
                            // Live Streams Section (if any active)
                            if !liveStreams.isEmpty {
                                liveStreamsSection
                            }

                            // Quick Stats
                            quickStatsSection

                            // Trending Geniuses Carousel
                            if let geniuses = homeData?.trendingGeniuses, !geniuses.isEmpty {
                                trendingGeniusesSection(geniuses: geniuses)
                            }

                            // Categories Grid
                            if let categories = homeData?.categories, !categories.isEmpty {
                                categoriesSection(categories: categories)
                            }

                            // Feed Filter Pills
                            feedFilterSection

                            // Feed Posts
                            feedSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                    }
                }
            }
            .task {
                await loadData()
            }
            .sheet(isPresented: $showSearch) {
                SearchGeniusesSheet()
            }
            .sheet(item: $showGeniusDetail) { genius in
                GeniusDetailSheet(genius: genius, userId: authViewModel.currentUser?.id ?? "")
            }
            .sheet(item: $showCategoryDetail) { category in
                CategoryDetailSheet(category: category)
            }
            .sheet(item: $showComments) { post in
                CommentsSheet(post: post)
            }
            .sheet(item: $showShareSheet) { post in
                ShareSheet(post: post)
            }
            .fullScreenCover(item: $selectedLiveStream) { stream in
                LiveStreamViewerView(stream: stream)
            }
            .sheet(isPresented: $showInbox) {
                InboxSheet(userId: authViewModel.currentUser?.id ?? "")
            }
            .sheet(isPresented: $showProfile) {
                NavigationStack {
                    ProfileView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") { showProfile = false }
                            }
                        }
                }
            }
            .alert("Vote Submitted!", isPresented: $showVoteSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your vote for \(votedGeniusName) has been recorded. Thank you for supporting!")
            }
        }
    }

    // MARK: - Helper Functions
    private func followGenius(_ genius: TrendingGenius) {
        let userId = authViewModel.currentUser?.id ?? ""
        Task {
            await followManager.toggleFollow(userId: userId, geniusId: genius.id)
        }
    }

    private func voteForGenius(_ genius: TrendingGenius) {
        HapticFeedback.impact(.medium)

        Task {
            do {
                let userId = authViewModel.currentUser?.id ?? ""
                let success = try await HomeAPIService.shared.vote(
                    giverUserId: userId,
                    geniusId: genius.id,
                    positionId: "general"
                )

                if success {
                    await MainActor.run {
                        votedGeniusName = genius.name
                        showVoteSuccess = true
                        HapticFeedback.notification(.success)
                    }
                }
            } catch {
                print("Error voting for genius: \(error)")
                await MainActor.run {
                    HapticFeedback.notification(.error)
                }
            }
        }
    }

    private func toggleBookmark(for post: FeedPost) {
        if bookmarkedPosts.contains(post.id) {
            bookmarkedPosts.remove(post.id)
        } else {
            bookmarkedPosts.insert(post.id)
        }
    }

    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        HStack(spacing: 12) {
            QuickStatPill(label: "Votes Cast", value: "\(homeData?.stats.votesCastTotal ?? 0)", icon: "hand.thumbsup.fill", color: Color(hex: "f59e0b"))
            QuickStatPill(label: "Following", value: "\(homeData?.stats.followsTotal ?? 0)", icon: "person.2.fill", color: Color(hex: "10b981"))
            QuickStatPill(label: "Donated", value: "$\(Int(homeData?.stats.donationsTotal ?? 0))", icon: "dollarsign.circle.fill", color: Color(hex: "3b82f6"))
        }
    }

    // MARK: - Trending Geniuses Section
    private func trendingGeniusesSection(geniuses: [TrendingGenius]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🔥 Trending Geniuses")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1f2937"))
                Spacer()
                NavigationLink(destination: AllGeniusesView(geniuses: geniuses)) {
                    Text("See All")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "10b981"))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(geniuses) { genius in
                        GeniusCardSmall(
                            genius: genius,
                            onTap: { showGeniusDetail = genius },
                            onFollow: { followGenius(genius) },
                            onVote: { voteForGenius(genius) }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Categories Section
    private func categoriesSection(categories: [CategoryItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📂 Browse by Category")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(categories) { category in
                    CategoryGridItem(category: category) {
                        showCategoryDetail = category
                    }
                }
            }
        }
    }

    // MARK: - Feed Filter Section
    private var feedFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📰 Feed")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filters, id: \.self) { filter in
                        QuickActionPill(title: filter, icon: nil, isActive: selectedFilter == filter) {
                            selectedFilter = filter
                        }
                    }
                }
            }
        }
    }

    // MARK: - Feed Section
    private var feedSection: some View {
        VStack(spacing: 12) {
            ForEach(feedPosts) { post in
                FeedPostCard(
                    post: post,
                    onComment: { showComments = post },
                    onShare: { showShareSheet = post },
                    onBookmark: { toggleBookmark(for: post) }
                )
            }

            if feedPosts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "newspaper")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "d1d5db"))
                    Text("No posts yet")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "9ca3af"))
                    Text("Follow some Geniuses to see their posts here")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "9ca3af"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
    }

    // MARK: - Helper Functions
    private func loadData() async {
        isLoading = true
        do {
            let userId = authViewModel.currentUser?.id ?? ""
            async let homeDataTask = HomeAPIService.shared.getHomeSupporter(userId: userId)
            async let feedPostsTask = HomeAPIService.shared.getFeedPosts(userId: userId, role: .supporter)
            async let liveStreamsTask = LiveStreamService.shared.getActiveStreams()

            homeData = try await homeDataTask
            feedPosts = try await feedPostsTask
            liveStreams = (try? await liveStreamsTask) ?? []
        } catch {
            print("Error loading supporter home data: \(error)")
        }
        isLoading = false
    }

    // MARK: - Live Streams Section
    private var liveStreamsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "ef4444"))
                        .frame(width: 8, height: 8)
                    Text("🔴 Live Now")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "1f2937"))
                }

                Spacer()

                Text("\(liveStreams.count) streaming")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6b7280"))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(liveStreams) { stream in
                        LiveStreamMiniCard(stream: stream)
                            .onTapGesture { selectedLiveStream = stream }
                    }
                }
            }
        }
    }
}

// MARK: - Live Stream Mini Card
struct LiveStreamMiniCard: View {
    let stream: APILiveStream

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [Color(hex: "1e293b"), Color(hex: "334155")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 140, height: 100)

                // Live badge
                VStack {
                    HStack {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(Color(hex: "ef4444"))
                                .frame(width: 5, height: 5)
                            Text("LIVE")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())

                        Spacer()
                    }
                    .padding(6)

                    Spacer()

                    // Viewers
                    HStack {
                        Spacer()
                        HStack(spacing: 3) {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 8))
                            Text("\(stream.viewerCount)")
                                .font(.system(size: 8, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    }
                    .padding(6)
                }

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.8))
            }

            // Host info
            VStack(alignment: .leading, spacing: 2) {
                Text(stream.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "1f2937"))
                    .lineLimit(1)

                Text(stream.hostName)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "6b7280"))
                    .lineLimit(1)
            }
            .frame(width: 140, alignment: .leading)
        }
    }
}

// MARK: - Quick Stat Pill
struct QuickStatPill: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1f2937"))
            }
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "6b7280"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Feed Post Card
struct FeedPostCard: View {
    let post: FeedPost
    var onComment: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil
    var onBookmark: (() -> Void)? = nil
    @State private var isLiked: Bool
    @State private var likesCount: Int
    @State private var isBookmarked = false
    @Environment(AuthService.self) private var authService

    init(post: FeedPost, onComment: (() -> Void)? = nil, onShare: (() -> Void)? = nil, onBookmark: (() -> Void)? = nil) {
        self.post = post
        self.onComment = onComment
        self.onShare = onShare
        self.onBookmark = onBookmark
        self._isLiked = State(initialValue: post.isLiked)
        self._likesCount = State(initialValue: post.likesCount)
    }

    private func handleLike() async {
        guard let userId = authService.currentUser?.id else { return }

        // Optimistically update UI
        isLiked.toggle()
        likesCount += isLiked ? 1 : -1
        HapticFeedback.impact(.light)

        do {
            _ = try await PostAPIService.shared.likePost(postId: post.id, userId: userId)
        } catch {
            // Revert on error
            isLiked.toggle()
            likesCount += isLiked ? 1 : -1
            print("Failed to like post: \(error)")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Official Post Badge
            if post.isOfficialPost {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "10b981"))
                    Text("Official AGA Communication")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "10b981"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(hex: "10b981").opacity(0.1))
                .cornerRadius(8)
            }

            // Author Header
            HStack(spacing: 10) {
                if let avatarURL = post.authorAvatar, !avatarURL.isEmpty {
                    Image(avatarURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(post.isOfficialPost ?
                                  LinearGradient(colors: [Color(hex: "10b981"), Color(hex: "059669")], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                  DesignSystem.Gradients.genius)
                            .frame(width: 40, height: 40)
                        if post.isOfficialPost {
                            Image(systemName: "globe.africa.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        } else {
                            Text(String(post.authorName.prefix(2)).uppercased())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.authorName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "1f2937"))
                        if post.isOfficialPost {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "10b981"))
                        }
                    }
                    Text(post.authorPosition)
                        .font(.system(size: 12))
                        .foregroundColor(post.isOfficialPost ? Color(hex: "10b981") : Color(hex: "6b7280"))
                }

                Spacer()

                Text(timeAgo(from: post.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "9ca3af"))
            }

            // Content
            Text(post.content)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "374151"))
                .lineLimit(4)

            // Image if present
            if let imageURL = post.imageURL, !imageURL.isEmpty {
                ZStack {
                    RemoteImage(urlString: imageURL)
                        .frame(height: 450)  // Instagram-size height
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)

                    // AGA Watermark
                    AGAWatermark(opacity: 0.15, fontSize: 24, color: .white)
                }
                .clipped()
            }

            // Action Bar
            HStack(spacing: 24) {
                Button(action: {
                    Task {
                        await handleLike()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? Color(hex: "ef4444") : Color(hex: "6b7280"))
                        Text("\(likesCount)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                }

                Button(action: { onComment?() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(Color(hex: "6b7280"))
                        Text("\(post.commentsCount)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                }

                Button(action: { onShare?() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.2.squarepath")
                            .foregroundColor(Color(hex: "6b7280"))
                        Text("\(post.sharesCount)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                }

                Spacer()

                Button(action: {
                    isBookmarked.toggle()
                    onBookmark?()
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? Color(hex: "f59e0b") : Color(hex: "6b7280"))
                }
            }
            .font(.system(size: 16))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }
}

#Preview {
    SupporterHomeScreen()
        .environmentObject(AuthViewModel())
}

