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
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var searchText = ""
    @State private var searchResults: [TrendingGenius] = []
    @State private var isSearching = false
    @State private var selectedGenius: TrendingGenius?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "9ca3af"))
                    TextField("Search geniuses...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(Color(hex: "1f2937"))
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
                                SearchResultRow(genius: genius) {
                                    HapticFeedback.impact(.light)
                                    selectedGenius = genius
                                }
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
            .sheet(item: $selectedGenius) { genius in
                GeniusDetailSheet(genius: genius, userId: authViewModel.currentUser?.id ?? "")
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

        // Debounce search - wait 0.3 seconds before searching
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)

            // Only search if the query hasn't changed
            guard searchText == query else { return }

            do {
                let results = try await GeniusAPIService.shared.searchGeniuses(query: query, limit: 20)
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                }
            } catch {
                print("Search error: \(error)")
                await MainActor.run {
                    searchResults = []
                    isSearching = false
                }
            }
        }
    }
}

// MARK: - Search Result Row
struct SearchResultRow: View {
    let genius: TrendingGenius
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Genius Detail Sheet
struct GeniusDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthService.self) private var authService
    let genius: TrendingGenius
    var userId: String = ""
    @State private var showUpvoteSuccess = false
    @State private var showUpvoteError = false
    @State private var upvoteErrorMessage = ""
    @State private var isCreatingConversation = false
    @State private var conversationToOpen: APIConversation?
    @State private var currentVoteCount: Int = 0

    // Use stored constant instead of computed property for proper @Observable tracking
    private let followManager = FollowManager.shared
    private let upvoteManager = UpvoteManager.shared

    private var isFollowing: Bool {
        followManager.isFollowing(genius.id)
    }

    private var isLoadingFollow: Bool {
        followManager.isLoadingFollow(genius.id)
    }

    private var hasUpvoted: Bool {
        upvoteManager.hasUpvoted(genius.id)
    }

    private var isLoadingUpvote: Bool {
        upvoteManager.isLoadingUpvote(genius.id)
    }

    var body: some View {
        NavigationStack {
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
            .alert("Upvote Submitted!", isPresented: $showUpvoteSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your upvote for \(genius.name) has been recorded. Thank you for supporting!")
            }
            .alert("Upvote Failed", isPresented: $showUpvoteError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(upvoteErrorMessage)
            }
            .navigationDestination(item: $conversationToOpen) { conversation in
                ChatView(conversation: conversation, currentUserId: userId)
            }
            .onAppear {
                // Use UpvoteManager's cached count if available, otherwise use genius.votes
                currentVoteCount = upvoteManager.getVoteCount(genius.id) ?? genius.votes
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
            GeniusStatItemView(value: "\(currentVoteCount.formatted())", label: "Upvotes")
            Divider().frame(height: 40)
            GeniusStatItemView(value: genius.country, label: "Country")
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
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
                    guard !hasUpvoted else { return }
                    Task {
                        let result = await upvoteManager.upvoteWithResult(userId: userId, geniusId: genius.id)
                        await MainActor.run {
                            switch result {
                            case .success(let newCount):
                                currentVoteCount = newCount
                                showUpvoteSuccess = true
                            case .alreadyUpvoted:
                                upvoteErrorMessage = "You have already upvoted this genius"
                                showUpvoteError = true
                            case .error(let message):
                                upvoteErrorMessage = message
                                showUpvoteError = true
                            }
                        }
                    }
                }) {
                    HStack {
                        if isLoadingUpvote {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(Color(hex: "f59e0b"))
                        } else {
                            Image(systemName: hasUpvoted ? "checkmark.circle.fill" : "hand.thumbsup.fill")
                            Text(hasUpvoted ? "Upvoted" : "Upvote")
                        }
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(hasUpvoted ? .white : Color(hex: "f59e0b"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(hasUpvoted ? Color(hex: "f59e0b") : Color(hex: "f59e0b").opacity(0.15))
                    .cornerRadius(12)
                    .opacity(hasUpvoted ? 0.8 : 1.0)
                }
                .disabled(hasUpvoted || isLoadingUpvote)
            }

            // Message Button
            Button(action: {
                HapticFeedback.impact(.medium)
                isCreatingConversation = true
                Task {
                    do {
                        let currentUserName = authService.currentUser?.displayName ?? "You"
                        let conversation = try await MessagingService.shared.createConversation(
                            participants: [userId, genius.id],
                            participantNames: [currentUserName, genius.name]
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
    @EnvironmentObject var authViewModel: AuthViewModel
    let category: CategoryItem
    @State private var geniuses: [TrendingGenius] = []
    @State private var isLoading = true
    @State private var selectedGenius: TrendingGenius?

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
                                SearchResultRow(genius: genius) {
                                    HapticFeedback.impact(.light)
                                    selectedGenius = genius
                                }
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
            .sheet(item: $selectedGenius) { genius in
                GeniusDetailSheet(genius: genius, userId: authViewModel.currentUser?.id ?? "")
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
    @Environment(AuthService.self) private var authService
    let post: FeedPost
    @State private var newComment = ""
    @State private var comments: [APIComment] = []
    @State private var isLoading = true
    @State private var isSending = false
    @FocusState private var isInputFocused: Bool

    var onCommentAdded: (() -> Void)? = nil

    private var currentUserId: String {
        authService.currentUser?.id ?? ""
    }

    private var currentUserName: String {
        authService.currentUser?.displayName ?? "Anonymous"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading && comments.isEmpty {
                    Spacer()
                    ProgressView("Loading comments...")
                        .foregroundColor(Color(hex: "6b7280"))
                    Spacer()
                } else if comments.isEmpty {
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
                                CommentRow(
                                    comment: comment,
                                    currentUserId: currentUserId,
                                    postId: post.id,
                                    onLikeToggled: { updatedComment in
                                        if let index = comments.firstIndex(where: { $0.id == updatedComment.id }) {
                                            comments[index] = updatedComment
                                        }
                                    }
                                )
                            }
                        }
                        .padding(16)
                    }
                    .refreshable {
                        await loadComments()
                    }
                }

                // Comment Input
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("Add a comment...", text: $newComment, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color(hex: "f3f4f6"))
                            .foregroundColor(Color(hex: "1f2937"))
                            .cornerRadius(20)
                            .focused($isInputFocused)
                            .lineLimit(1...4)

                        Button(action: postComment) {
                            if isSending {
                                ProgressView()
                                    .frame(width: 36, height: 36)
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
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationTitle("Comments (\(comments.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            await loadComments()
        }
    }

    private var canSend: Bool {
        !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func loadComments() async {
        isLoading = true
        do {
            comments = try await CommentService.shared.getComments(postId: post.id)
        } catch {
            print("Error loading comments: \(error)")
        }
        isLoading = false
    }

    private func postComment() {
        guard canSend else { return }

        let content = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        isSending = true
        newComment = ""
        HapticFeedback.impact(.light)

        Task {
            do {
                let comment = try await CommentService.shared.createComment(
                    postId: post.id,
                    authorId: currentUserId,
                    authorName: currentUserName,
                    content: content
                )
                await MainActor.run {
                    comments.insert(comment, at: 0)
                    isSending = false
                    HapticFeedback.notification(.success)
                    onCommentAdded?()
                }
            } catch {
                print("Error posting comment: \(error)")
                await MainActor.run {
                    newComment = content
                    isSending = false
                    HapticFeedback.notification(.error)
                }
            }
        }
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: APIComment
    let currentUserId: String
    let postId: String
    let onLikeToggled: (APIComment) -> Void

    @State private var isLiking = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Gradients.genius)
                    .frame(width: 36, height: 36)
                Text(initials)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(comment.authorName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))
                    Text(timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "9ca3af"))
                }
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
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
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
        HapticFeedback.impact(.light)
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

// MARK: - Share Sheet
struct ShareSheet: View {
    @Environment(\.dismiss) var dismiss
    let post: FeedPost
    @State private var showCopiedFeedback = false
    @State private var showSystemShare = false

    private let shareOptions = [
        ("Copy Link", "link"),
        ("Share to X (Twitter)", "bird"),
        ("Share to WhatsApp", "message.fill"),
        ("Share to Facebook", "person.2.fill"),
        ("More Options", "ellipsis")
    ]

    private var shareURL: String {
        "https://africageniusalliance.com/post/\(post.id)"
    }

    private var shareText: String {
        let truncated = post.content.prefix(100)
        let suffix = post.content.count > 100 ? "..." : ""
        return "Check out this post by \(post.authorName) on Africa Genius Alliance: \(truncated)\(suffix)"
    }

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
                                if option.0 == "Copy Link" && showCopiedFeedback {
                                    Text("Copied!")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(hex: "10b981"))
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "9ca3af"))
                                }
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
            .sheet(isPresented: $showSystemShare) {
                ActivityViewController(activityItems: [shareText, URL(string: shareURL)!])
            }
        }
    }

    private func shareVia(_ method: String) {
        HapticFeedback.impact(.light)

        switch method {
        case "Copy Link":
            UIPasteboard.general.string = shareURL
            showCopiedFeedback = true
            HapticFeedback.notification(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showCopiedFeedback = false
            }

        case "Share to X (Twitter)":
            let encodedText = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let encodedURL = shareURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            // Try Twitter app first, then X app, then web
            if let twitterAppURL = URL(string: "twitter://post?message=\(encodedText)%20\(encodedURL)"),
               UIApplication.shared.canOpenURL(twitterAppURL) {
                UIApplication.shared.open(twitterAppURL)
            } else if let xAppURL = URL(string: "x://post?message=\(encodedText)%20\(encodedURL)"),
                      UIApplication.shared.canOpenURL(xAppURL) {
                UIApplication.shared.open(xAppURL)
            } else if let webURL = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)&url=\(encodedURL)") {
                UIApplication.shared.open(webURL)
            }
            dismiss()

        case "Share to WhatsApp":
            let encodedText = "\(shareText) \(shareURL)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            // Try WhatsApp app first, then web
            if let whatsappURL = URL(string: "whatsapp://send?text=\(encodedText)"),
               UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL)
            } else if let webURL = URL(string: "https://wa.me/?text=\(encodedText)") {
                UIApplication.shared.open(webURL)
            }
            dismiss()

        case "Share to Facebook":
            let encodedURL = shareURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            // Try Facebook app first, then web
            if let fbAppURL = URL(string: "fb://share/?link=\(encodedURL)"),
               UIApplication.shared.canOpenURL(fbAppURL) {
                UIApplication.shared.open(fbAppURL)
            } else if let webURL = URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(encodedURL)") {
                UIApplication.shared.open(webURL)
            }
            dismiss()

        case "More Options":
            showSystemShare = true

        default:
            dismiss()
        }
    }
}

// MARK: - Activity View Controller (System Share Sheet)
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - All Geniuses View
struct AllGeniusesView: View {
    let geniuses: [TrendingGenius]
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedGenius: TrendingGenius?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(geniuses) { genius in
                    SearchResultRow(genius: genius) {
                        HapticFeedback.impact(.light)
                        selectedGenius = genius
                    }
                }
            }
            .padding(16)
        }
        .background(Color(hex: "f9fafb").ignoresSafeArea())
        .navigationTitle("Trending Geniuses")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedGenius) { genius in
            GeniusDetailSheet(genius: genius, userId: authViewModel.currentUser?.id ?? "")
        }
    }
}

