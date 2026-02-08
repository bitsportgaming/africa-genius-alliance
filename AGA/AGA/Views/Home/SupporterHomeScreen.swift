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
    @State private var showUpvoteSuccess = false
    @State private var upvotedGeniusName: String = ""
    @State private var showProfile = false
    @State private var pollingTimer: Timer?
    @State private var selectedAuthorId: String?
    @State private var unreadNotificationCount = 0

    // Polling interval in seconds
    private let pollingInterval: TimeInterval = 15

    // Use stored constants instead of computed properties for proper @Observable tracking
    private let followManager = FollowManager.shared
    private let upvoteManager = UpvoteManager.shared

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

    // MARK: - Computed Property for Filtered Feed Posts
    private var filteredFeedPosts: [FeedPost] {
        switch selectedFilter {
        case "For You":
            // Show all posts, sorted by recency (official posts first, then by date)
            return feedPosts
        case "Following":
            // This is loaded from API with feedType="following"
            // Return as-is since it's already filtered server-side
            return feedPosts
        case "Trending":
            // Sort by engagement score (likes + comments + shares)
            return feedPosts.sorted { post1, post2 in
                let score1 = post1.likesCount + post1.commentsCount + post1.sharesCount
                let score2 = post2.likesCount + post2.commentsCount + post2.sharesCount
                return score1 > score2
            }
        case "Live":
            // Filter to show only live announcement posts
            return feedPosts.filter { $0.postType == .liveAnnouncement }
        default:
            return feedPosts
        }
    }

    // MARK: - Empty State Properties
    private var emptyStateIcon: String {
        switch selectedFilter {
        case "Following": return "person.2"
        case "Trending": return "flame"
        case "Live": return "dot.radiowaves.left.and.right"
        default: return "newspaper"
        }
    }

    private var emptyStateTitle: String {
        switch selectedFilter {
        case "Following": return "No posts from people you follow"
        case "Trending": return "No trending posts"
        case "Live": return "No live streams right now"
        default: return "No posts yet"
        }
    }

    private var emptyStateSubtitle: String {
        switch selectedFilter {
        case "Following": return "Follow some Geniuses to see their posts here"
        case "Trending": return "Check back later for trending content"
        case "Live": return "Geniuses will announce their live streams here"
        default: return "Follow some Geniuses to see their posts here"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(DesignSystem.Colors.primary)
                        Text("Loading your feed...")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0, pinnedViews: []) {
                        // Top Bar - not lazy, always visible
                        HomeTopBar(
                            greeting: "Welcome back, \(userName.split(separator: " ").first ?? "Supporter")",
                            subtitle: "Discover and support African Geniuses",
                            avatarURL: authViewModel.currentUser?.profileImageURL,
                            initials: userInitials,
                            notificationCount: unreadNotificationCount,
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

                        // Header sections - grouped together
                        VStack(spacing: DesignSystem.Spacing.lg) {
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
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.top, DesignSystem.Spacing.md)

                        // Feed Posts - each post is lazy loaded individually
                        ForEach(filteredFeedPosts) { post in
                            Group {
                                if post.isOfficialPost {
                                    OfficialPostCard(
                                        post: post,
                                        onComment: { showComments = post },
                                        onShare: { showShareSheet = post },
                                        onLikeChanged: { isLiked, count in
                                            if let index = feedPosts.firstIndex(where: { $0.id == post.id }) {
                                                feedPosts[index].isLiked = isLiked
                                                feedPosts[index].likesCount = count
                                            }
                                        }
                                    )
                                } else {
                                    FeedPostCard(
                                        post: post,
                                        onComment: { showComments = post },
                                        onShare: { showShareSheet = post },
                                        onBookmark: { toggleBookmark(for: post) },
                                        onLikeChanged: { isLiked, count in
                                            if let index = feedPosts.firstIndex(where: { $0.id == post.id }) {
                                                feedPosts[index].isLiked = isLiked
                                                feedPosts[index].likesCount = count
                                            }
                                        },
                                        onAuthorTap: {
                                            selectedAuthorId = post.authorId
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        }

                        if filteredFeedPosts.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: emptyStateIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(hex: "d1d5db"))
                                Text(emptyStateTitle)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "9ca3af"))
                                Text(emptyStateSubtitle)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "9ca3af"))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }

                        // Bottom padding
                        Color.clear.frame(height: 100)
                    }
                }
            }
        }
        }
        .task {
            await loadData()
            startPolling()
        }
        .onDisappear {
            stopPolling()
        }
        .onChange(of: selectedFilter) { oldValue, newValue in
            // Reload posts when filter changes
            Task {
                await loadFilteredPosts(filter: newValue)
            }
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
            CommentsSheet(post: post, onCommentAdded: {
                // Update comments count for this post
                if let index = feedPosts.firstIndex(where: { $0.id == post.id }) {
                    feedPosts[index].commentsCount += 1
                }
            })
        }
        .sheet(item: $showShareSheet) { post in
            ShareSheet(post: post)
        }
        .fullScreenCover(item: $selectedLiveStream) { stream in
            LiveStreamViewerView(stream: stream)
        }
        .sheet(isPresented: $showInbox) {
            InboxSheet(userId: authViewModel.currentUser?.id ?? "")
                .onDisappear {
                    // Refresh notification count when inbox closes
                    Task { await loadUnreadCount() }
                }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(item: $selectedAuthorId) { authorId in
            AuthorProfileSheet(authorId: authorId, currentUserId: authViewModel.currentUser?.id ?? "")
        }
        .alert("Upvote Submitted!", isPresented: $showUpvoteSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your upvote for \(upvotedGeniusName) has been recorded. Thank you for supporting!")
        }
    }

    // MARK: - Helper Functions
    private func followGenius(_ genius: TrendingGenius) {
        let userId = authViewModel.currentUser?.id ?? ""
        Task {
            await followManager.toggleFollow(userId: userId, geniusId: genius.id)
        }
    }

    private func upvoteGenius(_ genius: TrendingGenius) {
        // Check if already upvoted - UpvoteManager handles this check but we can skip early
        guard !upvoteManager.hasUpvoted(genius.id) else { return }

        let userId = authViewModel.currentUser?.id ?? ""
        Task {
            let newVoteCount = await upvoteManager.upvote(userId: userId, geniusId: genius.id)
            if newVoteCount != nil {
                await MainActor.run {
                    upvotedGeniusName = genius.name
                    showUpvoteSuccess = true
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
        HStack(spacing: DesignSystem.Spacing.sm) {
            QuickStatPill(label: "Upvotes Cast", value: "\(homeData?.stats.votesCastTotal ?? 0)", icon: "hand.thumbsup.fill", color: DesignSystem.Colors.accent)
            QuickStatPill(label: "Following", value: "\(homeData?.stats.followsTotal ?? 0)", icon: "person.2.fill", color: DesignSystem.Colors.primary)
            QuickStatPill(label: "Donated", value: "$\(Int(homeData?.stats.donationsTotal ?? 0))", icon: "dollarsign.circle.fill", color: DesignSystem.Colors.info)
        }
    }

    // MARK: - Trending Geniuses Section
    private func trendingGeniusesSection(geniuses: [TrendingGenius]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeader(title: "🔥 Trending Geniuses") {
                NavigationLink(destination: AllGeniusesView(geniuses: geniuses)) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(DesignSystem.Typography.captionBold)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(geniuses) { genius in
                        GeniusCardSmall(
                            genius: genius,
                            onTap: { showGeniusDetail = genius },
                            onFollow: { followGenius(genius) },
                            onUpvote: { upvoteGenius(genius) }
                        )
                    }
                }
                .padding(.horizontal, 1) // Prevent edge clipping
            }
        }
    }

    // MARK: - Categories Section
    private func categoriesSection(categories: [CategoryItem]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeader(title: "📂 Browse by Category")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: DesignSystem.Spacing.sm) {
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
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeader(title: "📰 Feed")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(filters, id: \.self) { filter in
                        QuickActionPill(title: filter, icon: filterIcon(for: filter), isActive: selectedFilter == filter) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, 1) // Prevent clipping at edges
            }
        }
    }

    private func filterIcon(for filter: String) -> String? {
        switch filter {
        case "For You": return "sparkles"
        case "Following": return "person.2"
        case "Trending": return "flame"
        case "Live": return "dot.radiowaves.left.and.right"
        default: return nil
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

            // Load unread notification count
            await loadUnreadCount()
        } catch {
            print("Error loading supporter home data: \(error)")
        }
        isLoading = false
    }

    private func loadUnreadCount() async {
        guard let userId = authViewModel.currentUser?.id else { return }
        unreadNotificationCount = await MessagingService.shared.getTotalUnreadCount(userId: userId)
    }

    // MARK: - Load Filtered Posts
    private func loadFilteredPosts(filter: String) async {
        let userId = authViewModel.currentUser?.id ?? ""

        do {
            switch filter {
            case "Following":
                // Load posts from users the current user follows
                feedPosts = try await HomeAPIService.shared.getFeedPosts(userId: userId, role: .supporter, feedType: "following")
            case "For You", "Trending", "Live":
                // For these filters, load all posts (filtering is done client-side)
                feedPosts = try await HomeAPIService.shared.getFeedPosts(userId: userId, role: .supporter)
            default:
                feedPosts = try await HomeAPIService.shared.getFeedPosts(userId: userId, role: .supporter)
            }
        } catch {
            print("Error loading filtered posts: \(error)")
        }
    }

    // MARK: - Polling for Real-time Updates
    private func startPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { _ in
            Task {
                await refreshFeedOnly()
            }
        }
    }

    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    private func refreshFeedOnly() async {
        // Silent refresh - don't show loading indicator
        do {
            let userId = authViewModel.currentUser?.id ?? ""
            let updatedPosts = try await HomeAPIService.shared.getFeedPosts(userId: userId, role: .supporter)

            // Update posts while preserving local state (like status from UI)
            await MainActor.run {
                for i in 0..<feedPosts.count {
                    if let updated = updatedPosts.first(where: { $0.id == feedPosts[i].id }) {
                        // Preserve isLiked if user just liked it locally
                        let wasLikedLocally = feedPosts[i].isLiked
                        feedPosts[i].likesCount = updated.likesCount
                        feedPosts[i].commentsCount = updated.commentsCount
                        feedPosts[i].sharesCount = updated.sharesCount
                        // Only update isLiked from server if not locally changed
                        if !wasLikedLocally && updated.isLiked {
                            feedPosts[i].isLiked = true
                        }
                    }
                }

                // Add any new posts at the top
                for newPost in updatedPosts {
                    if !feedPosts.contains(where: { $0.id == newPost.id }) {
                        // Insert new posts after any official posts
                        let insertIndex = feedPosts.firstIndex(where: { !$0.isOfficialPost }) ?? 0
                        feedPosts.insert(newPost, at: insertIndex)
                    }
                }
            }
        } catch {
            print("Error refreshing feed: \(error)")
        }
    }

    // MARK: - Live Streams Section
    private var liveStreamsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                HStack(spacing: 8) {
                    // Animated live indicator
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.error.opacity(0.3))
                            .frame(width: 16, height: 16)
                        Circle()
                            .fill(DesignSystem.Colors.error)
                            .frame(width: 8, height: 8)
                    }
                    Text("Live Now")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }

                Spacer()

                AGAPill(text: "\(liveStreams.count) streaming", variant: .error)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(liveStreams) { stream in
                        LiveStreamMiniCard(stream: stream)
                            .onTapGesture {
                                HapticFeedback.impact(.medium)
                                selectedLiveStream = stream
                            }
                    }
                }
                .padding(.horizontal, 1) // Prevent edge clipping
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader<TrailingContent: View>: View {
    let title: String
    let trailing: TrailingContent?

    init(title: String, @ViewBuilder trailing: () -> TrailingContent) {
        self.title = title
        self.trailing = trailing()
    }

    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            Spacer()
            trailing
        }
    }
}

extension SectionHeader where TrailingContent == EmptyView {
    init(title: String) {
        self.title = title
        self.trailing = nil
    }
}

// MARK: - Live Stream Mini Card (Enhanced)
struct LiveStreamMiniCard: View {
    let stream: APILiveStream
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1e293b"), Color(hex: "334155")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 105)

                // Overlays
                VStack {
                    HStack {
                        // Live badge with glow
                        HStack(spacing: 4) {
                            Circle()
                                .fill(DesignSystem.Colors.error)
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                        Spacer()
                    }
                    .padding(8)

                    Spacer()

                    // Viewers
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 9))
                            Text("\(stream.viewerCount)")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .padding(8)
                }

                // Play button
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }

            // Host info
            VStack(alignment: .leading, spacing: 2) {
                Text(stream.title)
                    .font(DesignSystem.Typography.captionBold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)

                Text(stream.hostName)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .lineLimit(1)
            }
            .frame(width: 150, alignment: .leading)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Quick Stat Pill (Enhanced)
struct QuickStatPill: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    @State private var isAnimated = false

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(value)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .scaleEffect(isAnimated ? 1.0 : 0.8)
                    .opacity(isAnimated ? 1.0 : 0)
            }
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                isAnimated = true
            }
        }
    }
}

// MARK: - Official AGA Post Card
/// A distinctive card template for official AGA communications
struct OfficialPostCard: View {
    let post: FeedPost
    var onComment: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil
    var onLikeChanged: ((Bool, Int) -> Void)? = nil

    @State private var isLiked: Bool
    @State private var likesCount: Int
    @State private var likeScale: CGFloat = 1.0
    @Environment(AuthService.self) private var authService

    init(post: FeedPost, onComment: (() -> Void)? = nil, onShare: (() -> Void)? = nil, onLikeChanged: ((Bool, Int) -> Void)? = nil) {
        self.post = post
        self.onComment = onComment
        self.onShare = onShare
        self.onLikeChanged = onLikeChanged
        self._isLiked = State(initialValue: post.isLiked)
        self._likesCount = State(initialValue: post.likesCount)
    }

    private func handleLike() async {
        guard let userId = authService.currentUser?.id else { return }
        withAnimation(FluidAnimation.bouncy) { likeScale = 1.3 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(FluidAnimation.smooth) { likeScale = 1.0 }
        }
        isLiked.toggle()
        likesCount += isLiked ? 1 : -1
        HapticFeedback.impact(.light)
        onLikeChanged?(isLiked, likesCount)

        do {
            let result = try await PostAPIService.shared.likePost(postId: post.id, userId: userId)
            await MainActor.run {
                isLiked = result.liked
                likesCount = result.post.likesCount
                onLikeChanged?(result.liked, result.post.likesCount)
            }
        } catch {
            isLiked.toggle()
            likesCount += isLiked ? 1 : -1
            onLikeChanged?(isLiked, likesCount)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Premium Header with gradient
            HStack(spacing: 12) {
                // AGA Logo/Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "10b981"), Color(hex: "059669"), Color(hex: "047857")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 48, height: 48)
                        .shadow(color: Color(hex: "10b981").opacity(0.4), radius: 8, x: 0, y: 4)

                    Image(systemName: "globe.africa.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Africa Genius Alliance")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "1f2937"))

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "10b981"))
                    }

                    Text("Official Communication")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "10b981"))
                }

                Spacer()

                Text(timeAgo(from: post.createdAt))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "10b981").opacity(0.08), Color(hex: "10b981").opacity(0.03)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Accent line
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color(hex: "10b981"), Color(hex: "059669")],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(height: 3)

            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text(post.content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "374151"))
                    .lineSpacing(4)

                // Image if present
                if let imageURL = post.imageURL, !imageURL.isEmpty {
                    ZStack {
                        RemoteImage(urlString: imageURL)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)

                        AGAWatermark(opacity: 0.15, fontSize: 24, color: .white)
                    }
                }
            }
            .padding(16)

            // Action bar
            HStack(spacing: 0) {
                // Like
                Button(action: { Task { await handleLike() } }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? Color(hex: "ef4444") : Color(hex: "6b7280"))
                            .scaleEffect(likeScale)
                        Text("\(likesCount)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }

                Divider().frame(height: 20)

                // Comment
                Button(action: { onComment?() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(Color(hex: "6b7280"))
                        Text("\(post.commentsCount)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }

                Divider().frame(height: 20)

                // Share
                Button(action: { onShare?() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color(hex: "6b7280"))
                        Text("Share")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
            .font(.system(size: 16))
            .background(Color(hex: "f9fafb"))
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "10b981").opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color(hex: "10b981").opacity(0.15), radius: 12, x: 0, y: 4)
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

// MARK: - Feed Post Card
struct FeedPostCard: View {
    let post: FeedPost
    var onComment: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil
    var onBookmark: (() -> Void)? = nil
    var onLikeChanged: ((Bool, Int) -> Void)? = nil
    var onAuthorTap: (() -> Void)? = nil
    @State private var isLiked: Bool
    @State private var likesCount: Int
    @State private var isBookmarked = false
    @State private var likeScale: CGFloat = 1.0
    @State private var bookmarkScale: CGFloat = 1.0
    @State private var commentScale: CGFloat = 1.0
    @State private var shareScale: CGFloat = 1.0
    @State private var avatarScale: CGFloat = 1.0
    @State private var showSavedToast: Bool = false
    @Environment(AuthService.self) private var authService

    init(post: FeedPost, onComment: (() -> Void)? = nil, onShare: (() -> Void)? = nil, onBookmark: (() -> Void)? = nil, onLikeChanged: ((Bool, Int) -> Void)? = nil, onAuthorTap: (() -> Void)? = nil) {
        self.post = post
        self.onComment = onComment
        self.onShare = onShare
        self.onBookmark = onBookmark
        self.onLikeChanged = onLikeChanged
        self.onAuthorTap = onAuthorTap
        self._isLiked = State(initialValue: post.isLiked)
        self._likesCount = State(initialValue: post.likesCount)
    }

    @ViewBuilder
    private var avatarView: some View {
        if let avatarURL = post.authorAvatar, !avatarURL.isEmpty {
            RemoteImage(urlString: avatarURL)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else {
            ZStack {
                Circle()
                    .fill(DesignSystem.Gradients.genius)
                    .frame(width: 40, height: 40)
                Text(String(post.authorName.prefix(2)).uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }

    private func handleLike() async {
        guard let userId = authService.currentUser?.id else { return }

        // Animate the heart
        withAnimation(FluidAnimation.bouncy) {
            likeScale = 1.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(FluidAnimation.smooth) {
                likeScale = 1.0
            }
        }

        // Optimistically update UI
        isLiked.toggle()
        likesCount += isLiked ? 1 : -1
        HapticFeedback.impact(.light)

        // Notify parent of the change
        onLikeChanged?(isLiked, likesCount)

        do {
            let result = try await PostAPIService.shared.likePost(postId: post.id, userId: userId)
            // Update with server response
            await MainActor.run {
                isLiked = result.liked
                likesCount = result.post.likesCount
                onLikeChanged?(result.liked, result.post.likesCount)
            }
        } catch {
            // Revert on error
            isLiked.toggle()
            likesCount += isLiked ? 1 : -1
            onLikeChanged?(isLiked, likesCount)
            print("Failed to like post: \(error)")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            HStack(spacing: 10) {
                // Clickable avatar and name (skip for admin posts)
                if post.isAdminPost {
                    avatarView
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.authorName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "1f2937"))
                        Text(post.positionAndLocation)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                } else {
                    Button(action: {
                        HapticFeedback.impact(.light)
                        withAnimation(FluidAnimation.bouncy) {
                            avatarScale = 0.9
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(FluidAnimation.smooth) {
                                avatarScale = 1.0
                            }
                        }
                        onAuthorTap?()
                    }) {
                        HStack(spacing: 10) {
                            avatarView
                                .scaleEffect(avatarScale)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(post.authorName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "1f2937"))
                                Text(post.positionAndLocation)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "6b7280"))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
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

            // Media if present (image or video)
            if let mediaURL = post.imageURL, !mediaURL.isEmpty {
                ZStack {
                    if post.postType == .video {
                        VideoPlayerView(urlString: mediaURL)
                            .frame(height: 450)  // Match image height
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                    } else {
                        RemoteImage(urlString: mediaURL)
                            .frame(height: 450)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                    }

                    // AGA Watermark
                    AGAWatermark(opacity: 0.15, fontSize: 24, color: .white)
                }
                .clipped()
            }

            // Action Bar with fluid animations
            HStack(spacing: 24) {
                Button(action: {
                    Task {
                        await handleLike()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? Color(hex: "ef4444") : Color(hex: "6b7280"))
                            .scaleEffect(likeScale)
                            .animation(FluidAnimation.bouncy, value: isLiked)
                        Text("\(likesCount)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                }

                Button(action: {
                    withAnimation(FluidAnimation.snappy) {
                        commentScale = 0.85
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(FluidAnimation.smooth) {
                            commentScale = 1.0
                        }
                    }
                    HapticFeedback.impact(.light)
                    onComment?()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(Color(hex: "6b7280"))
                        Text("\(post.commentsCount)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                    .scaleEffect(commentScale)
                }

                Button(action: {
                    withAnimation(FluidAnimation.snappy) {
                        shareScale = 0.85
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(FluidAnimation.smooth) {
                            shareScale = 1.0
                        }
                    }
                    HapticFeedback.impact(.light)
                    onShare?()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.2.squarepath")
                            .foregroundColor(Color(hex: "6b7280"))
                        Text("\(post.sharesCount)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                    .scaleEffect(shareScale)
                }

                Spacer()

                Button(action: {
                    withAnimation(FluidAnimation.bouncy) {
                        bookmarkScale = 1.3
                        isBookmarked.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(FluidAnimation.smooth) {
                            bookmarkScale = 1.0
                        }
                    }
                    HapticFeedback.notification(isBookmarked ? .success : .warning)
                    onBookmark?()

                    // Show toast when saving
                    if isBookmarked {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showSavedToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showSavedToast = false
                            }
                        }
                    }
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? Color(hex: "f59e0b") : Color(hex: "6b7280"))
                        .scaleEffect(bookmarkScale)
                }
            }
            .font(.system(size: 16))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(alignment: .bottom) {
            if showSavedToast {
                HStack(spacing: 8) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Saved")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color(hex: "f59e0b"))
                        .shadow(color: Color(hex: "f59e0b").opacity(0.4), radius: 8, x: 0, y: 4)
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 8)
            }
        }
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

// MARK: - Author Profile Sheet
struct AuthorProfileSheet: View {
    @Environment(AuthService.self) private var authService
    let authorId: String
    var currentUserId: String = ""

    @State private var user: APIUser?
    @State private var isLoading = true
    @State private var error: String?
    @State private var isFollowing = false
    @State private var isLoadingFollow = false
    @State private var isCreatingConversation = false
    @State private var conversationToOpen: APIConversation?
    @State private var currentVoteCount: Int = 0
    @State private var showUpvoteSuccess = false

    // Use let constants to properly observe @Observable objects
    private let upvoteManager = UpvoteManager.shared
    private let followManager = FollowManager.shared

    private var hasUpvoted: Bool {
        upvoteManager.hasUpvoted(authorId)
    }

    private var isLoadingUpvote: Bool {
        upvoteManager.isLoadingUpvote(authorId)
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading profile...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let user = user {
                    profileContent(user: user)
                }
            }
            .background(Color(hex: "f9fafb"))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $conversationToOpen) { conversation in
                ChatView(conversation: conversation, currentUserId: currentUserId)
            }
        }
        .task {
            await loadProfile()
        }
        .alert("Upvote Submitted!", isPresented: $showUpvoteSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your upvote for \(user?.displayName ?? "this genius") has been recorded. Thank you for supporting!")
        }
    }

    @ViewBuilder
    private func profileContent(user: APIUser) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    if let imageURL = user.profileImageURL, !imageURL.isEmpty {
                        RemoteImage(urlString: imageURL)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(DesignSystem.Gradients.genius)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(initials(for: user.displayName))
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }

                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Text(user.displayName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(hex: "1f2937"))

                            if user.isVerified == true {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "10b981"))
                            }
                        }

                        Text("\(user.positionTitle ?? "Member") • \(user.country ?? "Africa")")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.white)
                .cornerRadius(20)

                // Stats
                HStack(spacing: 0) {
                    statItem(value: "\(currentVoteCount)", label: "Upvotes")
                    Divider().frame(height: 40)
                    statItem(value: "\(user.followersCount ?? 0)", label: "Followers")
                    Divider().frame(height: 40)
                    statItem(value: "\(user.followingCount ?? 0)", label: "Following")
                }
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(16)

                // Bio
                if let bio = user.bio, !bio.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "6b7280"))
                        Text(bio)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "374151"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                }

                // Action Buttons (for all users)
                actionButtons(user: user)

                Spacer(minLength: 50)
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "6b7280"))
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func actionButtons(user: APIUser) -> some View {
        VStack(spacing: 12) {
            // Follow and Message buttons in a row
            HStack(spacing: 12) {
                // Follow Button
                Button(action: {
                    Task {
                        isLoadingFollow = true
                        let newFollowState = await followManager.toggleFollow(userId: currentUserId, geniusId: authorId)
                        isFollowing = newFollowState
                        isLoadingFollow = false
                    }
                }) {
                    HStack {
                        if isLoadingFollow {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: followManager.isFollowing(authorId) ? "checkmark" : "plus")
                            Text(followManager.isFollowing(authorId) ? "Following" : "Follow")
                        }
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(followManager.isFollowing(authorId) ? Color(hex: "374151") : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        followManager.isFollowing(authorId) ? Color(hex: "e5e7eb") : DesignSystem.Colors.accent
                    )
                    .cornerRadius(12)
                }
                .disabled(isLoadingFollow)

                // Message Button
                Button(action: {
                    HapticFeedback.impact(.medium)
                    isCreatingConversation = true
                    Task {
                        do {
                            let currentUserName = authService.currentUser?.displayName ?? "You"
                            let conversation = try await MessagingService.shared.createConversation(
                                participants: [currentUserId, authorId],
                                participantNames: [currentUserName, user.displayName]
                            )
                            await MainActor.run {
                                conversationToOpen = conversation
                                isCreatingConversation = false
                            }
                        } catch {
                            print("Error creating conversation: \(error)")
                            await MainActor.run {
                                isCreatingConversation = false
                                HapticFeedback.notification(.error)
                            }
                        }
                    }
                }) {
                    HStack {
                        if isCreatingConversation {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else {
                            Image(systemName: "message.fill")
                            Text("Message")
                        }
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "3b82f6"))
                    .cornerRadius(12)
                }
                .disabled(isCreatingConversation)
            }

            // Upvote Button (full width)
            Button(action: {
                guard !hasUpvoted else { return }
                Task {
                    if let newCount = await upvoteManager.upvote(userId: currentUserId, geniusId: authorId) {
                        await MainActor.run {
                            currentVoteCount = newCount
                            showUpvoteSuccess = true
                        }
                    }
                }
            }) {
                HStack {
                    if isLoadingUpvote {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: hasUpvoted ? "checkmark.circle.fill" : "arrow.up.circle.fill")
                        Text(hasUpvoted ? "Upvoted" : "Upvote")
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(hasUpvoted ? .white : DesignSystem.Colors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    hasUpvoted ? Color.green.opacity(0.8) : DesignSystem.Colors.accentSoft
                )
                .cornerRadius(12)
                .opacity(hasUpvoted ? 0.7 : 1.0)
            }
            .disabled(hasUpvoted || isLoadingUpvote)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }

    private func initials(for name: String) -> String {
        let names = name.split(separator: " ")
        if names.count >= 2 {
            return "\(names[0].prefix(1))\(names[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private func loadProfile() async {
        isLoading = true
        error = nil

        do {
            let loadedUser = try await UserAPIService.shared.getProfile(userId: authorId)
            await MainActor.run {
                user = loadedUser
                currentVoteCount = loadedUser.votesReceived ?? 0
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load profile"
            }
            print("Error loading author profile: \(error)")
        }

        await MainActor.run {
            isLoading = false
        }
    }
}

#Preview {
    SupporterHomeScreen()
        .environmentObject(AuthViewModel())
}

