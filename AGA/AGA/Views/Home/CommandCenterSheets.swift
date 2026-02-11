//
//  CommandCenterSheets.swift
//  AGA
//
//  Created by AGA Team on 12/30/25.
//

import SwiftUI

// MARK: - Analytics Data Models
struct AnalyticsData {
    let totalViews: Int
    let viewsChange: Int
    let newFollowers: Int
    let followersChange: Int
    let votesReceived: Int
    let votesChange: Int
    let donations: Double
    let donationsChange: Int
    let impressions: Int
    let profileVisits: Int
    let linkClicks: Int
    let shares: Int
    let dailyVotes: [Int]
    let topPosts: [TopPost]?
}

struct TopPost: Identifiable {
    let id: String
    let title: String
    let views: Int
    let likes: Int
    let date: String
}

// MARK: - Analytics Sheet
struct AnalyticsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthService.self) private var authService
    let userId: String

    @State private var selectedPeriod = "7 Days"
    @State private var analyticsData: AnalyticsData?
    @State private var isLoading = true

    // Use UpvoteManager for consistent vote counts across the app
    private let upvoteManager = UpvoteManager.shared

    private let periods = ["24 Hours", "7 Days", "30 Days", "All Time"]

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    periodSelector
                    if isLoading {
                        ProgressView().frame(height: 200)
                    } else {
                        overviewSection
                        engagementSection
                        growthSection
                        topPostsSection
                    }
                }
                .padding(16)
            }
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task { await loadAnalytics() }
    }

    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(periods, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                        Task { await loadAnalytics() }
                    }) {
                        Text(period)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedPeriod == period ? .white : Color(hex: "6b7280"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedPeriod == period ? Color(hex: "3b82f6") : Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AnalyticsStatCard(title: "Total Views", value: "\(analyticsData?.totalViews ?? 0)", change: analyticsData?.viewsChange ?? 0, icon: "eye.fill", color: Color(hex: "3b82f6"))
                AnalyticsStatCard(title: "New Followers", value: "\(analyticsData?.newFollowers ?? 0)", change: analyticsData?.followersChange ?? 0, icon: "person.badge.plus", color: Color(hex: "10b981"))
                AnalyticsStatCard(title: "Votes Received", value: "\(analyticsData?.votesReceived ?? 0)", change: analyticsData?.votesChange ?? 0, icon: "hand.thumbsup.fill", color: Color(hex: "f59e0b"))
                AnalyticsStatCard(title: "Donations", value: "$\(Int(analyticsData?.donations ?? 0))", change: analyticsData?.donationsChange ?? 0, icon: "dollarsign.circle.fill", color: Color(hex: "8b5cf6"))
            }
        }
    }

    private var engagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Engagement")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            VStack(spacing: 12) {
                EngagementRow(label: "Post Impressions", value: analyticsData?.impressions ?? 0, total: analyticsData?.totalViews ?? 1)
                EngagementRow(label: "Profile Visits", value: analyticsData?.profileVisits ?? 0, total: analyticsData?.totalViews ?? 1)
                EngagementRow(label: "Link Clicks", value: analyticsData?.linkClicks ?? 0, total: analyticsData?.totalViews ?? 1)
                EngagementRow(label: "Share Rate", value: analyticsData?.shares ?? 0, total: analyticsData?.impressions ?? 1)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    private var growthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Growth Trend")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            GeometryReader { geometry in
                let votes = analyticsData?.dailyVotes ?? [12, 18, 25, 20, 30, 28, 35]
                let maxValue = CGFloat(votes.max() ?? 1)
                let barCount = CGFloat(votes.count)
                let spacing: CGFloat = barCount > 14 ? 2 : 6
                let totalSpacing = spacing * (barCount - 1)
                let barWidth = max(4, (geometry.size.width - totalSpacing) / barCount)
                let chartHeight: CGFloat = 100

                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(Array(votes.enumerated()), id: \.offset) { index, value in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: barWidth > 8 ? 4 : 2)
                                .fill(DesignSystem.Gradients.primary)
                                .frame(width: barWidth, height: max(4, (CGFloat(value) / maxValue) * chartHeight))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(height: 120)
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    private var topPostsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Posts")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            VStack(spacing: 8) {
                ForEach(analyticsData?.topPosts ?? []) { post in
                    TopPostRow(post: post)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    private func loadAnalytics() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 200_000_000)

        let userId = authService.currentUser?.id ?? ""
        if userId.isEmpty {
            analyticsData = AnalyticsData(
                totalViews: 0, viewsChange: 0,
                newFollowers: 0, followersChange: 0,
                votesReceived: 0, votesChange: 0,
                donations: 0, donationsChange: 0,
                impressions: 0, profileVisits: 0, linkClicks: 0, shares: 0,
                dailyVotes: [0],
                topPosts: []
            )
            isLoading = false
            return
        }

        do {
            // Source of truth: same stats endpoint used by Impact
            let home = try await HomeAPIService.shared.getHomeGenius(userId: userId)
            let p = home.profile

            // Keep votes consistent with UpvoteManager if available
            let votesTotal = upvoteManager.getVoteCount(userId) ?? p.votesTotal

            let votes24h = p.stats24h.votesDelta
            let followers24h = p.stats24h.followersDelta
            let views24h = p.stats24h.profileViewsDelta

            let multiplier: Int
            let dailyVotesCount: Int
            switch selectedPeriod {
            case "24 Hours":
                multiplier = 1
                dailyVotesCount = 1
            case "7 Days":
                multiplier = 7
                dailyVotesCount = 7
            case "30 Days":
                multiplier = 30
                dailyVotesCount = 30
            case "All Time":
                multiplier = 0
                dailyVotesCount = max(1, min(votesTotal, 30))
            default:
                multiplier = 7
                dailyVotesCount = 7
            }

            if selectedPeriod == "All Time" {
                analyticsData = AnalyticsData(
                    totalViews: max(0, views24h) * 30, viewsChange: 0, // no total views field yet
                    newFollowers: p.followersTotal, followersChange: 0,
                    votesReceived: votesTotal, votesChange: 0,
                    donations: 0, donationsChange: 0,
                    impressions: 0,
                    profileVisits: max(0, views24h) * 30,
                    linkClicks: 0,
                    shares: 0,
                    dailyVotes: Array(repeating: 0, count: dailyVotesCount),
                    topPosts: []
                )
            } else {
                let votesPeriod = votes24h * multiplier
                let followersPeriod = followers24h * multiplier
                let viewsPeriod = views24h * multiplier

                analyticsData = AnalyticsData(
                    totalViews: max(0, viewsPeriod), viewsChange: 0,
                    newFollowers: max(0, followersPeriod), followersChange: followers24h,
                    votesReceived: max(0, votesPeriod), votesChange: votes24h,
                    donations: 0, donationsChange: 0,
                    impressions: 0,
                    profileVisits: max(0, viewsPeriod),
                    linkClicks: 0,
                    shares: 0,
                    dailyVotes: Array(repeating: 0, count: dailyVotesCount),
                    topPosts: []
                )
            }
        } catch {
            print("Error loading analytics: \(error)")
            // Fallback (old behavior)
            let user = authService.currentUser
            let totalVotes = upvoteManager.getVoteCount(user?.id ?? "") ?? user?.votesReceived ?? 0
            let totalFollowers = user?.followersCount ?? 0
            analyticsData = AnalyticsData(
                totalViews: 0, viewsChange: 0,
                newFollowers: totalFollowers, followersChange: 0,
                votesReceived: totalVotes, votesChange: 0,
                donations: 0, donationsChange: 0,
                impressions: 0, profileVisits: 0, linkClicks: 0, shares: 0,
                dailyVotes: [0],
                topPosts: []
            )
        }

        isLoading = false
    }
}

// MARK: - Analytics Stat Card
struct AnalyticsStatCard: View {
    let title: String
    let value: String
    let change: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
                Spacer()
                if change != 0 {
                    HStack(spacing: 2) {
                        Image(systemName: change > 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 10))
                        Text("\(abs(change))%")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(change > 0 ? Color(hex: "10b981") : Color(hex: "ef4444"))
                }
            }
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "6b7280"))
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Engagement Row
struct EngagementRow: View {
    let label: String
    let value: Int
    let total: Int

    private var percentage: Double {
        guard total > 0 else { return 0 }
        return min(Double(value) / Double(total), 1.0)
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "4b5563"))
                Spacer()
                Text("\(value)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "1f2937"))
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "e5e7eb"))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(DesignSystem.Gradients.primary)
                        .frame(width: geometry.size.width * percentage, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Top Post Row
struct TopPostRow: View {
    let post: TopPost

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "f3f4f6"))
                .frame(width: 50, height: 50)
                .overlay(Image(systemName: "doc.text").foregroundColor(Color(hex: "9ca3af")))
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "1f2937"))
                    .lineLimit(1)
                HStack(spacing: 12) {
                    Label("\(post.views)", systemImage: "eye")
                    Label("\(post.likes)", systemImage: "heart.fill")
                }
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "6b7280"))
            }
            Spacer()
            Text(post.date)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "9ca3af"))
        }
    }
}

// MARK: - Inbox Data Models
struct InboxMessage: Identifiable {
    let id: String
    let senderName: String
    let senderAvatar: String?
    let subject: String
    let preview: String
    let date: String
    var isRead: Bool
    let type: MessageType
    let postId: String?  // Optional post ID for post-related notifications

    enum MessageType: String {
        case message = "envelope"
        case notification = "bell"
        case donation = "dollarsign.circle"
        case vote = "hand.thumbsup"
    }

    init(id: String, senderName: String, senderAvatar: String?, subject: String, preview: String, date: String, isRead: Bool, type: MessageType, postId: String? = nil) {
        self.id = id
        self.senderName = senderName
        self.senderAvatar = senderAvatar
        self.subject = subject
        self.preview = preview
        self.date = date
        self.isRead = isRead
        self.type = type
        self.postId = postId
    }
}

// MARK: - Inbox Sheet
struct InboxSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthService.self) private var authService
    let userId: String
    var onNavigateToPost: ((String) -> Void)?  // Callback to navigate to a post

    @State private var selectedTab = "Messages"
    @State private var conversations: [APIConversation] = []
    @State private var notifications: [InboxMessage] = []
    @State private var apiNotifications: [APINotification] = []
    @State private var isLoading = true
    @State private var selectedConversation: APIConversation?
    @State private var selectedNotification: InboxMessage?
    @State private var selectedAPINotification: APINotification?
    @State private var showPostDetail = false
    @State private var showComposeMessage = false
    @State private var composeIconRotation: Double = 0
    @State private var composeIconScale: CGFloat = 1.0

    private let tabs = ["Messages", "Notifications"]

    private var currentUserId: String {
        authService.currentUser?.id ?? (userId.isEmpty ? "currentUser" : userId)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabSelector
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if selectedTab == "Messages" {
                    if conversations.isEmpty {
                        emptyMessagesState
                    } else {
                        conversationsList
                    }
                } else {
                    if notifications.isEmpty {
                        emptyNotificationsState
                    } else {
                        notificationsList
                    }
                }
            }
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Read All button - only show when on Notifications tab with unread items
                    if selectedTab == "Notifications" && notifications.contains(where: { !$0.isRead }) {
                        Button(action: markAllNotificationsAsRead) {
                            Text("Read All")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "3b82f6"))
                        }
                    }
                    // Animated Compose Button
                    Button(action: {
                        HapticFeedback.impact(.medium)
                        // Animate the icon
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            composeIconScale = 0.8
                            composeIconRotation = -15
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                composeIconScale = 1.1
                                composeIconRotation = 10
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                composeIconScale = 1.0
                                composeIconRotation = 0
                            }
                            showComposeMessage = true
                        }
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "10b981"))
                            .scaleEffect(composeIconScale)
                            .rotationEffect(.degrees(composeIconRotation))
                    }
                }
            }
            .navigationDestination(item: $selectedConversation) { conversation in
                ChatView(conversation: conversation, currentUserId: currentUserId)
            }
            .sheet(isPresented: $showComposeMessage) {
                ComposeMessageView { newConversation in
                    // Add the new conversation to the list and select it
                    if !conversations.contains(where: { $0.id == newConversation.id }) {
                        conversations.insert(newConversation, at: 0)
                    }
                    showComposeMessage = false
                    selectedConversation = newConversation
                }
                .environment(authService)
            }
        }
        .task { await loadData() }
        .onAppear {
            // Subtle pulse animation on appear to draw attention
            withAnimation(.easeInOut(duration: 0.6).repeatCount(2, autoreverses: true)) {
                composeIconScale = 1.15
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    composeIconScale = 1.0
                }
            }
        }
    }

    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .white : Color(hex: "6b7280"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedTab == tab ? Color(hex: "8b5cf6") : Color.white)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
    }

    private var conversationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(conversations) { conversation in
                    InboxConversationRow(
                        conversation: conversation,
                        currentUserId: currentUserId
                    )
                    .onTapGesture {
                        selectedConversation = conversation
                    }
                    Divider().padding(.leading, 70)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(16)
        }
    }

    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(notifications) { notification in
                    InboxMessageRow(message: notification)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleNotificationTap(notification)
                        }
                    Divider().padding(.leading, 70)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(16)
        }
        .sheet(isPresented: $showPostDetail) {
            if let notification = selectedNotification, let postId = notification.postId {
                NotificationPostDetailSheet(postId: postId)
                    .environment(authService)
            }
        }
    }

    private func handleNotificationTap(_ notification: InboxMessage) {
        // Mark as read locally
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }

        // Mark as read on backend
        Task {
            do {
                try await NotificationService.shared.markAsRead(notificationId: notification.id)
            } catch {
                print("Error marking notification as read: \(error)")
            }
        }

        // Handle navigation based on notification type
        if let postId = notification.postId {
            // If there's a postId, show the post detail
            selectedNotification = notification
            showPostDetail = true
        }
        // Other notification types can be handled here in the future (votes, follows, etc.)
    }

    private var emptyMessagesState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "d1d5db"))
            Text("No conversations yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "6b7280"))
            Text("Start messaging other Geniuses")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "9ca3af"))
            Spacer()
        }
    }

    private var emptyNotificationsState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bell")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "d1d5db"))
            Text("No notifications")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "6b7280"))
            Spacer()
        }
    }

    private func loadData() async {
        isLoading = true

        // Load conversations from backend
        do {
            conversations = try await MessagingService.shared.getConversations(userId: currentUserId)
        } catch {
            print("Error loading conversations: \(error)")
        }

        // Load notifications from backend
        do {
            apiNotifications = try await NotificationService.shared.getNotifications(userId: currentUserId)
            // Convert APINotification to InboxMessage for display
            notifications = apiNotifications.map { notif in
                let type: InboxMessage.MessageType = {
                    switch notif.type {
                    case "vote": return .vote
                    case "donation": return .donation
                    default: return .notification
                    }
                }()
                return InboxMessage(
                    id: notif.id,
                    senderName: notif.relatedUserName ?? "AGA",
                    senderAvatar: nil,
                    subject: notif.title,
                    preview: notif.message,
                    date: formatNotificationDate(notif.createdAt),
                    isRead: notif.isRead,
                    type: type,
                    postId: notif.relatedPostId
                )
            }
        } catch {
            print("Error loading notifications: \(error)")
            notifications = []
        }

        isLoading = false
    }

    private func formatNotificationDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: dateString) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: dateString) else {
                return dateString
            }
            return relativeTime(from: date)
        }
        return relativeTime(from: date)
    }

    private func relativeTime(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }

    private func markAllNotificationsAsRead() {
        // Update local state
        for i in notifications.indices {
            notifications[i].isRead = true
        }

        // Call API to mark all as read
        Task {
            do {
                try await NotificationService.shared.markAllAsRead(userId: currentUserId)
            } catch {
                print("Error marking all notifications as read: \(error)")
            }
        }
    }
}

// MARK: - Inbox Conversation Row
struct InboxConversationRow: View {
    let conversation: APIConversation
    let currentUserId: String

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(DesignSystem.Gradients.genius)
                .frame(width: 48, height: 48)
                .overlay(
                    Text(initials)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))
                    Spacer()
                    Text(timeAgo)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "9ca3af"))
                }

                Text(lastMessageText)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6b7280"))
                    .lineLimit(1)
            }

            if unreadCount > 0 {
                Text("\(unreadCount)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "10b981"))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var otherName: String {
        conversation.getOtherParticipantName(currentUserId: currentUserId)
    }

    private var initials: String {
        let parts = otherName.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (first + last).uppercased()
    }

    private var lastMessageText: String {
        conversation.lastMessage?.content ?? "No messages yet"
    }

    private var unreadCount: Int {
        conversation.getUnreadCount(for: currentUserId)
    }

    private var timeAgo: String {
        guard let timestampStr = conversation.lastMessage?.timestamp else { return "" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: timestampStr) else { return "" }

        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        return "\(Int(interval / 86400))d"
    }
}

// MARK: - Inbox Message Row
struct InboxMessageRow: View {
    let message: InboxMessage

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: message.type.rawValue)
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.senderName)
                        .font(.system(size: 14, weight: message.isRead ? .medium : .bold))
                        .foregroundColor(Color(hex: "1f2937"))
                    Spacer()
                    Text(message.date)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "9ca3af"))
                }
                Text(message.subject)
                    .font(.system(size: 13, weight: message.isRead ? .regular : .semibold))
                    .foregroundColor(Color(hex: "374151"))
                    .lineLimit(1)
                Text(message.preview)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6b7280"))
                    .lineLimit(1)
            }

            if !message.isRead {
                Circle()
                    .fill(Color(hex: "3b82f6"))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var iconColor: Color {
        switch message.type {
        case .message: return Color(hex: "3b82f6")
        case .notification: return Color(hex: "8b5cf6")
        case .donation: return Color(hex: "10b981")
        case .vote: return Color(hex: "f59e0b")
        }
    }
}

// MARK: - Campaign Data Models
struct Campaign: Identifiable {
    let id: String
    let title: String
    let description: String
    let goalAmount: Double
    let raisedAmount: Double
    let endDate: Date
    let supporters: Int
    let isActive: Bool
}

// MARK: - Campaign Sheet
struct CampaignSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthService.self) private var authService
    let userId: String

    @State private var campaigns: [Campaign] = []
    @State private var isLoading = true
    @State private var showCreateCampaign = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView().frame(height: 200)
                    } else if let error = errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 32))
                                .foregroundColor(Color(hex: "f59e0b"))
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "6b7280"))
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                Task { await loadCampaigns() }
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "3b82f6"))
                        }
                        .frame(height: 200)
                    } else {
                        activeCampaignSection
                        pastCampaignsSection
                        createCampaignButton
                    }
                }
                .padding(16)
            }
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationTitle("Campaigns")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showCreateCampaign) {
                CreateCampaignSheet(
                    userId: userId,
                    creatorName: authService.currentUser?.displayName ?? "Unknown",
                    onSuccess: {
                        Task { await loadCampaigns() }
                    }
                )
            }
        }
        .task { await loadCampaigns() }
    }

    private var activeCampaignSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Campaigns")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            let active = campaigns.filter { $0.isActive }
            if active.isEmpty {
                emptyActiveState
            } else {
                ForEach(active) { campaign in
                    CampaignCard(campaign: campaign)
                }
            }
        }
    }

    private var emptyActiveState: some View {
        VStack(spacing: 12) {
            Image(systemName: "megaphone")
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "d1d5db"))
            Text("No active campaigns")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6b7280"))
            Text("Create a campaign to start fundraising")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "9ca3af"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color.white)
        .cornerRadius(12)
    }

    private var pastCampaignsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Past Campaigns")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            let past = campaigns.filter { !$0.isActive }
            ForEach(past) { campaign in
                CampaignCard(campaign: campaign, isPast: true)
            }
        }
    }

    private var createCampaignButton: some View {
        Button(action: { showCreateCampaign = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Create New Campaign")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(DesignSystem.Gradients.primary)
            .cornerRadius(12)
        }
    }

    private func loadCampaigns() async {
        isLoading = true
        errorMessage = nil

        do {
            let apiCampaigns = try await CampaignAPIService.shared.getUserCampaigns(userId: userId)

            // Convert API campaigns to local Campaign model
            campaigns = apiCampaigns.map { apiCampaign in
                Campaign(
                    id: apiCampaign.projectId,
                    title: apiCampaign.title,
                    description: apiCampaign.description,
                    goalAmount: apiCampaign.fundingGoal,
                    raisedAmount: apiCampaign.fundingRaised,
                    endDate: apiCampaign.endDateParsed ?? Date().addingTimeInterval(86400 * 30),
                    supporters: apiCampaign.supportersCount,
                    isActive: apiCampaign.isActive
                )
            }
        } catch let urlError as URLError {
            print("Failed to load campaigns: \(urlError)")
            campaigns = []
            switch urlError.code {
            case .notConnectedToInternet:
                errorMessage = "No internet connection"
            case .cannotFindHost, .dnsLookupFailed:
                errorMessage = "Unable to reach server"
            case .timedOut:
                errorMessage = "Request timed out"
            default:
                errorMessage = nil
            }
        } catch {
            print("Failed to load campaigns: \(error)")
            campaigns = []
            errorMessage = nil
        }

        isLoading = false
    }
}

// MARK: - Campaign Card
struct CampaignCard: View {
    let campaign: Campaign
    var isPast: Bool = false

    private var progress: Double {
        min(campaign.raisedAmount / campaign.goalAmount, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(campaign.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "1f2937"))
                Spacer()
                if isPast {
                    Text("Completed")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "10b981"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "10b981").opacity(0.1))
                        .cornerRadius(12)
                }
            }

            Text(campaign.description)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "6b7280"))
                .lineLimit(2)

            VStack(spacing: 6) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "e5e7eb"))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DesignSystem.Gradients.primary)
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("$\(Int(campaign.raisedAmount)) raised")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "10b981"))
                    Spacer()
                    Text("of $\(Int(campaign.goalAmount))")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6b7280"))
                }
            }

            HStack {
                Label("\(campaign.supporters) supporters", systemImage: "person.2.fill")
                Spacer()
                if !isPast {
                    Text(daysRemaining)
                        .foregroundColor(Color(hex: "f59e0b"))
                }
            }
            .font(.system(size: 12))
            .foregroundColor(Color(hex: "6b7280"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var daysRemaining: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: campaign.endDate).day ?? 0
        return "\(max(0, days)) days left"
    }
}

// MARK: - Create Campaign Sheet
struct CreateCampaignSheet: View {
    @Environment(\.dismiss) var dismiss

    let userId: String
    let creatorName: String
    var onSuccess: (() -> Void)?

    @State private var title = ""
    @State private var description = ""
    @State private var goalAmount = ""
    @State private var duration = "30 days"
    @State private var isCreating = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let durations = ["7 days", "14 days", "30 days", "60 days", "90 days"]

    var body: some View {
        NavigationView {
            Form {
                Section("Campaign Details") {
                    TextField("Campaign Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Funding Goal") {
                    HStack {
                        Text("$")
                        TextField("Amount", text: $goalAmount)
                            .keyboardType(.numberPad)
                    }
                }

                Section("Duration") {
                    Picker("Duration", selection: $duration) {
                        ForEach(durations, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button(action: createCampaign) {
                        if isCreating {
                            ProgressView()
                        } else {
                            Text("Launch Campaign")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(title.isEmpty || goalAmount.isEmpty || isCreating)
                }
            }
            .navigationTitle("New Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Campaign Launched! 🎉", isPresented: $showSuccess) {
                Button("OK") {
                    onSuccess?()
                    dismiss()
                }
            } message: {
                Text("Your campaign \"\(title)\" has been created successfully. Start sharing it with your supporters!")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func createCampaign() {
        guard let goal = Double(goalAmount), goal > 0 else {
            errorMessage = "Please enter a valid funding goal amount"
            showError = true
            return
        }

        // Parse duration string to get number of days
        let durationDays = parseDuration(duration)

        isCreating = true

        Task {
            do {
                _ = try await CampaignAPIService.shared.createCampaign(
                    title: title,
                    description: description,
                    fundingGoal: goal,
                    durationDays: durationDays,
                    creatorId: userId,
                    creatorName: creatorName
                )

                await MainActor.run {
                    isCreating = false
                    showSuccess = true
                    HapticFeedback.notification(.success)
                }
            } catch let urlError as URLError {
                await MainActor.run {
                    isCreating = false
                    switch urlError.code {
                    case .notConnectedToInternet:
                        errorMessage = "No internet connection. Please check your network and try again."
                    case .cannotFindHost, .dnsLookupFailed:
                        errorMessage = "Unable to reach the server. Please check your internet connection and try again later."
                    case .timedOut:
                        errorMessage = "Request timed out. Please try again."
                    default:
                        errorMessage = "Network error. Please check your connection and try again."
                    }
                    showError = true
                    HapticFeedback.notification(.error)
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                    errorMessage = "Failed to create campaign. Please try again later."
                    showError = true
                    HapticFeedback.notification(.error)
                }
            }
        }
    }

    private func parseDuration(_ duration: String) -> Int {
        // Parse strings like "30 days" to get the number
        let components = duration.split(separator: " ")
        if let first = components.first, let days = Int(first) {
            return days
        }
        return 30 // Default to 30 days
    }
}

// MARK: - Settings Sheet
struct GeniusSettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthService.self) private var authService
    let userId: String

    @StateObject private var settings: UserSettingsStore

    init(userId: String) {
        self.userId = userId
        _settings = StateObject(wrappedValue: UserSettingsStore(userId: userId))
    }

    var body: some View {
        NavigationView {
            Form {
                notificationsSection
                privacySection
                profileSection
                volunteerSection
                accountSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var volunteerSection: some View {
        Section {
            Button(action: {
                HapticFeedback.impact(.medium)
                if let url = URL(string: "https://africageniusalliance.com/volunteer") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "f97316").opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "f97316"))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Volunteer With Us")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "1f2937"))
                        Text("Join our mission to build Africa's future")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6b7280"))
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "f97316"))
                }
            }
        } header: {
            Text("Get Involved")
        } footer: {
            Text("Help shape the future of Africa by volunteering your time and skills.")
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle(isOn: $settings.notificationsEnabled) {
                Label("Enable Notifications", systemImage: "bell.fill")
            }
            .onChange(of: settings.notificationsEnabled) { _, _ in
                // Ensure dependent toggles sync immediately.
                settings.enforceDependencies()
            }

            Toggle(isOn: $settings.emailNotifications) {
                Label("Email Notifications", systemImage: "envelope.fill")
            }
            .disabled(!settings.notificationsEnabled)

            Toggle(isOn: $settings.pushNotifications) {
                Label("Push Notifications", systemImage: "iphone")
            }
            .disabled(!settings.notificationsEnabled)
        }
    }

    private var privacySection: some View {
        Section("Privacy") {
            Toggle(isOn: $settings.publicProfile) {
                Label("Public Profile", systemImage: "eye.fill")
            }
            Toggle(isOn: $settings.allowMessages) {
                Label("Allow Messages", systemImage: "message.fill")
            }
        }
    }

    private var profileSection: some View {
        Section("Profile Settings") {
            Toggle(isOn: $settings.showDonationButton) {
                Label("Show Donation Button", systemImage: "dollarsign.circle.fill")
            }
            NavigationLink {
                EditProfileSection()
                    .environment(authService)
            } label: {
                Label("Edit Profile", systemImage: "person.fill")
            }
            NavigationLink {
                SocialLinksSection()
                    .environment(authService)
            } label: {
                Label("Social Links", systemImage: "link")
            }
        }
    }

    private var accountSection: some View {
        Section("Account") {
            NavigationLink {
                ChangePasswordSection()
                    .environment(authService)
            } label: {
                Label("Change Password", systemImage: "lock.fill")
            }
            NavigationLink {
                ExportDataSection()
            } label: {
                Label("Export My Data", systemImage: "square.and.arrow.up")
            }
            Button(role: .destructive) {
                authService.signOut()
                dismiss()
            } label: {
                Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }
}

// MARK: - Edit Profile Section
struct EditProfileSection: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = ""
    @State private var bio = ""
    @State private var country = ""
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Basic Info") {
                TextField("Display Name", text: $displayName)
                TextField("Bio", text: $bio, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Country", text: $country)
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            if showSuccess {
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Profile updated successfully!")
                            .foregroundColor(.green)
                    }
                }
            }

            Section {
                Button(action: saveProfile) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isSaving ? "Saving..." : "Save Changes")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(isSaving || displayName.isEmpty)
            }
        }
        .navigationTitle("Edit Profile")
        .onAppear(perform: loadCurrentData)
    }

    private func loadCurrentData() {
        if let user = authService.currentUser {
            displayName = user.displayName
            bio = user.bio ?? ""
            country = user.country ?? ""
        }
    }

    private func saveProfile() {
        isSaving = true
        errorMessage = nil
        showSuccess = false

        Task {
            do {
                try await authService.updateProfile(
                    displayName: displayName.isEmpty ? nil : displayName,
                    bio: bio.isEmpty ? nil : bio,
                    country: country.isEmpty ? nil : country
                )
                await MainActor.run {
                    isSaving = false
                    showSuccess = true
                    HapticFeedback.notification(.success)

                    // Auto dismiss after success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    HapticFeedback.notification(.error)
                }
            }
        }
    }
}

// MARK: - Change Password Section
struct ChangePasswordSection: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false

    // Password validation rules
    private var hasMinLength: Bool { newPassword.count >= 8 }
    private var hasUppercase: Bool { newPassword.range(of: "[A-Z]", options: .regularExpression) != nil }
    private var hasLowercase: Bool { newPassword.range(of: "[a-z]", options: .regularExpression) != nil }
    private var hasNumber: Bool { newPassword.range(of: "[0-9]", options: .regularExpression) != nil }
    private var hasSpecialChar: Bool { newPassword.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil }
    private var passwordsMatch: Bool { !confirmPassword.isEmpty && newPassword == confirmPassword }

    private var passwordStrength: Int {
        var strength = 0
        if hasMinLength { strength += 1 }
        if hasUppercase { strength += 1 }
        if hasLowercase { strength += 1 }
        if hasNumber { strength += 1 }
        if hasSpecialChar { strength += 1 }
        return strength
    }

    private var strengthLabel: String {
        switch passwordStrength {
        case 0...1: return "Weak"
        case 2...3: return "Medium"
        case 4: return "Strong"
        case 5: return "Very Strong"
        default: return ""
        }
    }

    private var strengthColor: Color {
        switch passwordStrength {
        case 0...1: return .red
        case 2...3: return .orange
        case 4: return .green
        case 5: return Color(hex: "0a4d3c")
        default: return .gray
        }
    }

    private var isValid: Bool {
        !currentPassword.isEmpty &&
        hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumber &&
        passwordsMatch
    }

    var body: some View {
        Form {
            Section("Current Password") {
                HStack {
                    if showCurrentPassword {
                        TextField("Enter current password", text: $currentPassword)
                    } else {
                        SecureField("Enter current password", text: $currentPassword)
                    }
                    Button(action: { showCurrentPassword.toggle() }) {
                        Image(systemName: showCurrentPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
            }

            Section {
                HStack {
                    if showNewPassword {
                        TextField("Enter new password", text: $newPassword)
                    } else {
                        SecureField("Enter new password", text: $newPassword)
                    }
                    Button(action: { showNewPassword.toggle() }) {
                        Image(systemName: showNewPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    if showConfirmPassword {
                        TextField("Confirm new password", text: $confirmPassword)
                    } else {
                        SecureField("Confirm new password", text: $confirmPassword)
                    }
                    Button(action: { showConfirmPassword.toggle() }) {
                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("New Password")
            } footer: {
                if !confirmPassword.isEmpty && !passwordsMatch {
                    Text("Passwords do not match")
                        .foregroundColor(.red)
                }
            }

            // Password strength indicator
            if !newPassword.isEmpty {
                Section("Password Strength") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Strength bar
                        HStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(index < passwordStrength ? strengthColor : Color.gray.opacity(0.3))
                                    .frame(height: 4)
                            }
                        }

                        HStack {
                            Text(strengthLabel)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(strengthColor)
                            Spacer()
                        }

                        // Validation rules checklist
                        VStack(alignment: .leading, spacing: 6) {
                            PasswordRuleRow(label: "At least 8 characters", isMet: hasMinLength)
                            PasswordRuleRow(label: "One uppercase letter (A-Z)", isMet: hasUppercase)
                            PasswordRuleRow(label: "One lowercase letter (a-z)", isMet: hasLowercase)
                            PasswordRuleRow(label: "One number (0-9)", isMet: hasNumber)
                            PasswordRuleRow(label: "One special character (!@#$%...)", isMet: hasSpecialChar)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            if showSuccess {
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Password changed successfully!")
                            .foregroundColor(.green)
                    }
                }
            }

            Section {
                Button(action: changePassword) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isSaving ? "Changing..." : "Change Password")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(!isValid || isSaving)
            }

            Section {
                Text("Password changes will take effect immediately. You will remain logged in on this device.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Change Password")
    }

    private func changePassword() {
        isSaving = true
        errorMessage = nil
        showSuccess = false

        Task {
            do {
                try await UserAPIService.shared.changePassword(
                    userId: authService.currentUser?.id ?? "",
                    currentPassword: currentPassword,
                    newPassword: newPassword
                )
                await MainActor.run {
                    isSaving = false
                    showSuccess = true
                    currentPassword = ""
                    newPassword = ""
                    confirmPassword = ""
                    HapticFeedback.notification(.success)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    HapticFeedback.notification(.error)
                }
            }
        }
    }
}

// MARK: - Password Rule Row
struct PasswordRuleRow: View {
    let label: String
    let isMet: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundColor(isMet ? .green : .gray.opacity(0.5))
            Text(label)
                .font(.caption)
                .foregroundColor(isMet ? .primary : .secondary)
        }
    }
}

// MARK: - Social Links Section
struct SocialLinksSection: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    @State private var twitter = ""
    @State private var instagram = ""
    @State private var linkedin = ""
    @State private var website = ""

    // Track original values to detect changes
    @State private var originalTwitter = ""
    @State private var originalInstagram = ""
    @State private var originalLinkedin = ""
    @State private var originalWebsite = ""

    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private var hasChanges: Bool {
        twitter != originalTwitter ||
        instagram != originalInstagram ||
        linkedin != originalLinkedin ||
        website != originalWebsite
    }

    var body: some View {
        Form {
            Section("Social Media") {
                HStack {
                    Image(systemName: "at")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("Twitter/X URL", text: $twitter)
                        .foregroundColor(.primary)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                HStack {
                    Image(systemName: "camera")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    TextField("Instagram URL", text: $instagram)
                        .foregroundColor(.primary)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                HStack {
                    Image(systemName: "briefcase")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("LinkedIn URL", text: $linkedin)
                        .foregroundColor(.primary)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }

            Section("Website") {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.green)
                        .frame(width: 24)
                    TextField("Personal Website URL", text: $website)
                        .foregroundColor(.primary)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }

            Section {
                Button(action: saveLinks) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isSaving ? "Saving..." : "Save Links")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(hasChanges && !isSaving ? .white : Color(hex: "9ca3af"))
                }
                .listRowBackground(hasChanges && !isSaving ? Color(hex: "10b981") : Color(hex: "e5e7eb"))
                .disabled(isSaving || !hasChanges)
            }

            if showSuccess {
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Links saved successfully!")
                            .foregroundColor(.green)
                    }
                }
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            Section {
                Text("Social links will be displayed on your public profile.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Social Links")
        .onAppear(perform: loadCurrentLinks)
    }

    private var userDefaultsPrefix: String {
        let userId = authService.currentUser?.id ?? "default"
        return "socialLinks_\(userId)_"
    }

    private func loadCurrentLinks() {
        // Load from UserDefaults where social links are stored (user-specific keys)
        let defaults = UserDefaults.standard
        twitter = defaults.string(forKey: "\(userDefaultsPrefix)twitter") ?? ""
        instagram = defaults.string(forKey: "\(userDefaultsPrefix)instagram") ?? ""
        linkedin = defaults.string(forKey: "\(userDefaultsPrefix)linkedin") ?? ""
        website = defaults.string(forKey: "\(userDefaultsPrefix)website") ?? ""

        // Set original values
        originalTwitter = twitter
        originalInstagram = instagram
        originalLinkedin = linkedin
        originalWebsite = website
    }

    private func saveLinks() {
        isSaving = true
        errorMessage = nil
        showSuccess = false

        Task {
            do {
                try await authService.updateSocialLinks(
                    twitter: twitter,
                    instagram: instagram,
                    linkedin: linkedin,
                    website: website
                )

                // Save to UserDefaults for local persistence (user-specific keys)
                let defaults = UserDefaults.standard
                defaults.set(twitter, forKey: "\(userDefaultsPrefix)twitter")
                defaults.set(instagram, forKey: "\(userDefaultsPrefix)instagram")
                defaults.set(linkedin, forKey: "\(userDefaultsPrefix)linkedin")
                defaults.set(website, forKey: "\(userDefaultsPrefix)website")

                await MainActor.run {
                    isSaving = false
                    showSuccess = true
                    HapticFeedback.notification(.success)

                    // Update original values to reflect saved state
                    originalTwitter = twitter
                    originalInstagram = instagram
                    originalLinkedin = linkedin
                    originalWebsite = website

                    // Auto dismiss after success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    HapticFeedback.notification(.error)
                }
            }
        }
    }
}

// MARK: - Export Data Section
struct ExportDataSection: View {
    @State private var isExporting = false
    @State private var exportComplete = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export Your Data")
                        .font(.headline)

                    Text("Download a copy of all your data including your profile, posts, and activity history.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("What's Included") {
                Label("Profile Information", systemImage: "person.fill")
                Label("Posts & Content", systemImage: "doc.text.fill")
                Label("Comments & Interactions", systemImage: "bubble.left.and.bubble.right.fill")
                Label("Voting History", systemImage: "hand.thumbsup.fill")
                Label("Donation Records", systemImage: "heart.fill")
            }

            if exportComplete {
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Export request submitted! You'll receive an email with your data.")
                            .foregroundColor(.green)
                    }
                }
            }

            Section {
                Button(action: requestExport) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isExporting ? "Requesting..." : "Request Data Export")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(isExporting || exportComplete)
            }

            Section {
                Text("Data exports are processed within 24-48 hours. You will receive an email with a download link.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Export Data")
    }

    private func requestExport() {
        isExporting = true

        // Simulate export request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isExporting = false
            exportComplete = true
            HapticFeedback.notification(.success)
        }
    }
}

// MARK: - Notification Post Detail Sheet
struct NotificationPostDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthService.self) private var authService
    let postId: String

    @State private var post: APIPost?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading post...")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6b7280"))
                            .padding(.top, 16)
                        Spacer()
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "f59e0b"))
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6b7280"))
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task { await loadPost() }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "3b82f6"))
                        Spacer()
                    }
                    .padding()
                } else if let post = post {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Author Header
                            HStack(spacing: 12) {
                                if let imageURL = post.authorProfileImageURL, !imageURL.isEmpty {
                                    RemoteImage(urlString: imageURL)
                                        .frame(width: 48, height: 48)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "fb923c"), Color(hex: "f59e0b")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Text(String(post.authorName.prefix(2)).uppercased())
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(post.authorName)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(hex: "1f2937"))

                                    Text(formatDate(post.createdAt))
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "6b7280"))
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 16)

                            // Post Content
                            Text(post.content)
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: "374151"))
                                .lineSpacing(4)
                                .padding(.horizontal, 16)

                            // Post Image if available
                            if let imageURLs = post.imageURLs, let firstImage = imageURLs.first, !firstImage.isEmpty {
                                RemoteImage(urlString: firstImage)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .clipped()
                            }

                            // Stats Row
                            HStack(spacing: 24) {
                                Label("\(post.likesCount)", systemImage: "heart.fill")
                                    .foregroundColor(Color(hex: "ef4444"))
                                Label("\(post.commentsCount)", systemImage: "bubble.right.fill")
                                    .foregroundColor(Color(hex: "6b7280"))
                            }
                            .font(.system(size: 14))
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 16)
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("Post not found")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "6b7280"))
                        Spacer()
                    }
                }
            }
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task { await loadPost() }
    }

    private func loadPost() async {
        isLoading = true
        errorMessage = nil

        do {
            post = try await PostAPIService.shared.getPost(postId: postId)
        } catch {
            errorMessage = "Unable to load post. Please try again."
            print("Error loading post: \(error)")
        }

        isLoading = false
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) else { return dateString }

        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
}