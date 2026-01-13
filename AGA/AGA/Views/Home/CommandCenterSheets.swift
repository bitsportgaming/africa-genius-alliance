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
    let userId: String

    @State private var selectedPeriod = "7 Days"
    @State private var analyticsData: AnalyticsData?
    @State private var isLoading = true

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

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(analyticsData?.dailyVotes ?? [12, 18, 25, 20, 30, 28, 35], id: \.self) { value in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DesignSystem.Gradients.primary)
                            .frame(width: 30, height: CGFloat(value) * 3)
                        Text("\(value)")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "9ca3af"))
                    }
                }
            }
            .frame(maxWidth: .infinity)
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
        try? await Task.sleep(nanoseconds: 500_000_000)
        analyticsData = AnalyticsData(
            totalViews: 12450, viewsChange: 12,
            newFollowers: 234, followersChange: 8,
            votesReceived: 1567, votesChange: 15,
            donations: 2340, donationsChange: 5,
            impressions: 8500, profileVisits: 3200, linkClicks: 890, shares: 456,
            dailyVotes: [12, 18, 25, 20, 30, 28, 35],
            topPosts: [
                TopPost(id: "1", title: "My vision for Africa's future", views: 3240, likes: 567, date: "2 days ago"),
                TopPost(id: "2", title: "Education initiative update", views: 2100, likes: 234, date: "5 days ago"),
                TopPost(id: "3", title: "Thank you for 1000 supporters!", views: 1890, likes: 189, date: "1 week ago")
            ]
        )
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
    let isRead: Bool
    let type: MessageType

    enum MessageType: String {
        case message = "envelope"
        case notification = "bell"
        case donation = "dollarsign.circle"
        case vote = "hand.thumbsup"
    }
}

// MARK: - Inbox Sheet
struct InboxSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthService.self) private var authService
    let userId: String

    @State private var selectedTab = "Messages"
    @State private var conversations: [APIConversation] = []
    @State private var notifications: [InboxMessage] = []
    @State private var isLoading = true
    @State private var selectedConversation: APIConversation?

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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color(hex: "10b981"))
                    }
                }
            }
            .navigationDestination(item: $selectedConversation) { conversation in
                ChatView(conversation: conversation, currentUserId: currentUserId)
            }
        }
        .task { await loadData() }
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
                    Divider().padding(.leading, 70)
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(16)
        }
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

        // Load mock notifications (can be replaced with backend later)
        notifications = [
            InboxMessage(id: "1", senderName: "System", senderAvatar: nil, subject: "New vote received!", preview: "Someone just voted for you. Keep up the great work!", date: "4h ago", isRead: false, type: .vote),
            InboxMessage(id: "2", senderName: "Donation", senderAvatar: nil, subject: "$25 donation received", preview: "Anonymous supporter donated $25 to your campaign", date: "Yesterday", isRead: true, type: .donation),
            InboxMessage(id: "3", senderName: "System", senderAvatar: nil, subject: "Weekly summary", preview: "Your posts reached 2,340 people this week!", date: "3 days ago", isRead: true, type: .notification)
        ]

        isLoading = false
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
    let userId: String

    @State private var campaigns: [Campaign] = []
    @State private var isLoading = true
    @State private var showCreateCampaign = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView().frame(height: 200)
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
                CreateCampaignSheet()
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
        try? await Task.sleep(nanoseconds: 500_000_000)
        campaigns = [
            Campaign(id: "1", title: "Education Fund 2025", description: "Help us build schools in rural areas", goalAmount: 10000, raisedAmount: 7500, endDate: Date().addingTimeInterval(86400 * 30), supporters: 156, isActive: true),
            Campaign(id: "2", title: "Tech Skills Workshop", description: "Empowering youth with coding skills", goalAmount: 5000, raisedAmount: 5000, endDate: Date().addingTimeInterval(-86400 * 10), supporters: 89, isActive: false)
        ]
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

    @State private var title = ""
    @State private var description = ""
    @State private var goalAmount = ""
    @State private var duration = "30 days"
    @State private var isCreating = false

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
        }
    }

    private func createCampaign() {
        isCreating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isCreating = false
            dismiss()
        }
    }
}

// MARK: - Settings Sheet
struct GeniusSettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    let userId: String

    @State private var notificationsEnabled = true
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    @State private var publicProfile = true
    @State private var showDonationButton = true
    @State private var allowMessages = true

    var body: some View {
        NavigationView {
            Form {
                notificationsSection
                privacySection
                profileSection
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

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle(isOn: $notificationsEnabled) {
                Label("Enable Notifications", systemImage: "bell.fill")
            }
            if notificationsEnabled {
                Toggle(isOn: $emailNotifications) {
                    Label("Email Notifications", systemImage: "envelope.fill")
                }
                Toggle(isOn: $pushNotifications) {
                    Label("Push Notifications", systemImage: "iphone")
                }
            }
        }
    }

    private var privacySection: some View {
        Section("Privacy") {
            Toggle(isOn: $publicProfile) {
                Label("Public Profile", systemImage: "eye.fill")
            }
            Toggle(isOn: $allowMessages) {
                Label("Allow Messages", systemImage: "message.fill")
            }
        }
    }

    private var profileSection: some View {
        Section("Profile Settings") {
            Toggle(isOn: $showDonationButton) {
                Label("Show Donation Button", systemImage: "dollarsign.circle.fill")
            }
            NavigationLink {
                EditProfileSection()
            } label: {
                Label("Edit Profile", systemImage: "person.fill")
            }
            NavigationLink {
                Text("Social Links Settings")
            } label: {
                Label("Social Links", systemImage: "link")
            }
        }
    }

    private var accountSection: some View {
        Section("Account") {
            NavigationLink {
                Text("Change Password")
            } label: {
                Label("Change Password", systemImage: "lock.fill")
            }
            NavigationLink {
                Text("Export Data")
            } label: {
                Label("Export My Data", systemImage: "square.and.arrow.up")
            }
            Button(role: .destructive) {
                // Handle logout
            } label: {
                Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }
}

// MARK: - Edit Profile Section
struct EditProfileSection: View {
    @State private var displayName = ""
    @State private var bio = ""
    @State private var country = ""

    var body: some View {
        Form {
            Section("Basic Info") {
                TextField("Display Name", text: $displayName)
                TextField("Bio", text: $bio, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Country", text: $country)
            }

            Section {
                Button("Save Changes") {
                    // Save profile
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
}