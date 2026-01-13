//
//  SupporterSheets.swift
//  AGA
//
//  Sheet views for Supporter Home Screen
//

import SwiftUI

// MARK: - Search Geniuses Sheet
struct SearchGeniusesSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var searchResults: [TrendingGenius] = []
    @State private var isSearching = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "9ca3af"))
                    TextField("Search geniuses...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "9ca3af"))
                        }
                    }
                }
                .padding(12)
                .background(Color(hex: "f3f4f6"))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                if isSearching {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "d1d5db"))
                        Text("No results found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(searchResults) { genius in
                                SearchResultRow(genius: genius)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onChange(of: searchText) { _, newValue in
            performSearch(query: newValue)
        }
    }

    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        isSearching = true
        // Simulate search delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Mock results - in production, call API
            searchResults = []
            isSearching = false
        }
    }
}

// MARK: - Search Result Row
struct SearchResultRow: View {
    let genius: TrendingGenius

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Gradients.genius)
                    .frame(width: 48, height: 48)
                Text(genius.initials)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(genius.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "1f2937"))
                Text(genius.positionTitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6b7280"))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "9ca3af"))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Genius Detail Sheet
struct GeniusDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let genius: TrendingGenius
    var userId: String = ""
    @State private var showVoteSuccess = false

    private var followManager: FollowManager { FollowManager.shared }

    private var isFollowing: Bool {
        followManager.isFollowing(genius.id)
    }

    private var isLoadingFollow: Bool {
        followManager.isLoadingFollow(genius.id)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader
                    // Stats
                    statsSection
                    // Action Buttons
                    actionButtons
                }
                .padding(16)
            }
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationTitle(genius.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Vote Submitted!", isPresented: $showVoteSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your vote for \(genius.name) has been recorded. Thank you for supporting!")
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Gradients.genius)
                    .frame(width: 80, height: 80)
                Text(genius.initials)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text(genius.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "1f2937"))
                    if genius.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(hex: "10b981"))
                    }
                }
                Text(genius.positionTitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "6b7280"))
                Text(genius.country)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            GeniusStatItemView(value: "#\(genius.rank)", label: "Rank")
            Divider().frame(height: 40)
            GeniusStatItemView(value: "\(genius.votes.formatted())", label: "Votes")
            Divider().frame(height: 40)
            GeniusStatItemView(value: genius.country, label: "Country")
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                Task {
                    await followManager.toggleFollow(userId: userId, geniusId: genius.id)
                }
            }) {
                HStack {
                    if isLoadingFollow {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(isFollowing ? Color(hex: "10b981") : .white)
                    } else {
                        Image(systemName: isFollowing ? "person.badge.minus" : "person.badge.plus")
                        Text(isFollowing ? "Following" : "Follow")
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isFollowing ? Color(hex: "10b981") : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isFollowing ? Color(hex: "10b981").opacity(0.15) : Color(hex: "10b981"))
                .cornerRadius(12)
            }
            .disabled(isLoadingFollow)

            Button(action: {
                HapticFeedback.impact(.medium)
                Task {
                    do {
                        let success = try await HomeAPIService.shared.vote(
                            giverUserId: userId,
                            geniusId: genius.id,
                            positionId: "general"
                        )
                        if success {
                            await MainActor.run {
                                showVoteSuccess = true
                                HapticFeedback.notification(.success)
                            }
                        }
                    } catch {
                        print("Error voting: \(error)")
                        await MainActor.run {
                            HapticFeedback.notification(.error)
                        }
                    }
                }
            }) {
                HStack {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("Vote")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "f59e0b"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "f59e0b").opacity(0.15))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Genius Stat Item View
struct GeniusStatItemView: View {
    let value: String
    let label: String

    var body: some View {
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
}

// MARK: - Category Detail Sheet
struct CategoryDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let category: CategoryItem
    @State private var geniuses: [TrendingGenius] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if geniuses.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: category.color))
                        Text("No geniuses in this category yet")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6b7280"))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(geniuses) { genius in
                                SearchResultRow(genius: genius)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            await loadGeniusesByCategory()
        }
    }

    private func loadGeniusesByCategory() async {
        isLoading = true

        do {
            // Map category name to API category parameter
            let categoryParam = mapCategoryToAPIParam(category.name)

            // Fetch geniuses by category from API
            let apiGeniuses = try await GeniusAPIService.shared.getGeniuses(limit: 50)

            // Filter by category (positionCategory or positionTitle contains category name)
            let filtered = apiGeniuses.filter { genius in
                let positionCategory = genius.positionCategory?.lowercased() ?? ""
                let positionTitle = genius.positionTitle?.lowercased() ?? ""
                let categoryLower = categoryParam.lowercased()

                return positionCategory.contains(categoryLower) ||
                       positionTitle.contains(categoryLower) ||
                       matchesCategoryKeywords(genius: genius, category: categoryLower)
            }

            // Convert to TrendingGenius format
            geniuses = filtered.map { apiGenius in
                TrendingGenius(
                    id: apiGenius.userId,
                    name: apiGenius.displayName,
                    positionTitle: apiGenius.positionTitle ?? "Genius",
                    country: apiGenius.country ?? "Africa",
                    avatarURL: apiGenius.profileImageURL,
                    isVerified: apiGenius.isVerified ?? false,
                    rank: 0,
                    votes: apiGenius.votesReceived ?? 0
                )
            }
        } catch {
            print("Error loading geniuses by category: \(error)")
        }

        isLoading = false
    }

    private func mapCategoryToAPIParam(_ name: String) -> String {
        switch name.lowercased() {
        case "education": return "education"
        case "health": return "health"
        case "infrastructure": return "infrastructure"
        case "trade": return "trade"
        case "security": return "security"
        case "tech", "technology": return "technology"
        default: return name.lowercased()
        }
    }

    private func matchesCategoryKeywords(genius: APIGenius, category: String) -> Bool {
        let bio = genius.bio?.lowercased() ?? ""

        switch category {
        case "education":
            return bio.contains("education") || bio.contains("school") || bio.contains("university") || bio.contains("teacher") || bio.contains("learning")
        case "health":
            return bio.contains("health") || bio.contains("medical") || bio.contains("doctor") || bio.contains("hospital") || bio.contains("healthcare")
        case "infrastructure":
            return bio.contains("infrastructure") || bio.contains("roads") || bio.contains("building") || bio.contains("construction") || bio.contains("energy")
        case "trade":
            return bio.contains("trade") || bio.contains("commerce") || bio.contains("business") || bio.contains("economy") || bio.contains("market")
        case "security":
            return bio.contains("security") || bio.contains("defense") || bio.contains("police") || bio.contains("military") || bio.contains("safety")
        case "technology":
            return bio.contains("tech") || bio.contains("digital") || bio.contains("software") || bio.contains("ai") || bio.contains("innovation")
        default:
            return false
        }
    }
}

// MARK: - Comments Sheet
struct CommentsSheet: View {
    @Environment(\.dismiss) var dismiss
    let post: FeedPost
    @State private var newComment = ""
    @State private var comments: [CommentItem] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if comments.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "d1d5db"))
                        Text("No comments yet")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6b7280"))
                        Text("Be the first to comment!")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "9ca3af"))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(comments) { comment in
                                CommentRow(comment: comment)
                            }
                        }
                        .padding(16)
                    }
                }

                // Comment Input
                HStack(spacing: 12) {
                    TextField("Add a comment...", text: $newComment)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(12)
                        .background(Color(hex: "f3f4f6"))
                        .cornerRadius(20)

                    Button(action: postComment) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(newComment.isEmpty ? Color(hex: "9ca3af") : Color(hex: "10b981"))
                    }
                    .disabled(newComment.isEmpty)
                }
                .padding(16)
                .background(Color.white)
            }
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func postComment() {
        guard !newComment.isEmpty else { return }
        let comment = CommentItem(
            id: UUID().uuidString,
            authorName: "You",
            content: newComment,
            timeAgo: "Just now"
        )
        comments.insert(comment, at: 0)
        newComment = ""
    }
}

// MARK: - Comment Item
struct CommentItem: Identifiable {
    let id: String
    let authorName: String
    let content: String
    let timeAgo: String
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: CommentItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "e5e7eb"))
                    .frame(width: 36, height: 36)
                Text(String(comment.authorName.prefix(2)).uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "6b7280"))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.authorName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))
                    Text(comment.timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "9ca3af"))
                }
                Text(comment.content)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "374151"))
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Share Sheet
struct ShareSheet: View {
    @Environment(\.dismiss) var dismiss
    let post: FeedPost

    private let shareOptions = [
        ("Copy Link", "link"),
        ("Share to Twitter", "bird"),
        ("Share to WhatsApp", "message.fill"),
        ("Share to Facebook", "person.2.fill"),
        ("More Options", "ellipsis")
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Post Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.authorName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))
                    Text(post.content)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6b7280"))
                        .lineLimit(3)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "f3f4f6"))
                .cornerRadius(12)

                // Share Options
                VStack(spacing: 0) {
                    ForEach(shareOptions, id: \.0) { option in
                        Button(action: { shareVia(option.0) }) {
                            HStack {
                                Image(systemName: option.1)
                                    .frame(width: 24)
                                    .foregroundColor(Color(hex: "4b5563"))
                                Text(option.0)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "1f2937"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "9ca3af"))
                            }
                            .padding(16)
                        }
                        if option.0 != shareOptions.last?.0 {
                            Divider()
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(12)

                Spacer()
            }
            .padding(16)
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func shareVia(_ method: String) {
        print("Sharing via: \(method)")
        dismiss()
    }
}

// MARK: - All Geniuses View
struct AllGeniusesView: View {
    let geniuses: [TrendingGenius]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(geniuses) { genius in
                    SearchResultRow(genius: genius)
                }
            }
            .padding(16)
        }
        .background(Color(hex: "f9fafb").ignoresSafeArea())
        .navigationTitle("Trending Geniuses")
        .navigationBarTitleDisplayMode(.inline)
    }
}

