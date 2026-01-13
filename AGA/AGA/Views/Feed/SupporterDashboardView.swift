//
//  SupporterDashboardView.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI
import SwiftData

struct SupporterDashboardView: View {
    @Environment(AuthService.self) private var authService
    @State private var geniuses: [APIGenius] = []
    @State private var isLoading = true
    @State private var selectedFilter = "All"
    @State private var searchText = ""
    @State private var showFilterSheet = false

    private let filters = ["All", "Tech", "Education", "Health", "Trade", "Environment"]

    private var currentUserId: String {
        authService.currentUser?.id ?? ""
    }

    private var filteredGeniuses: [APIGenius] {
        var filtered = geniuses

        // Apply category filter
        if selectedFilter != "All" {
            filtered = filtered.filter { genius in
                genius.positionCategory?.localizedCaseInsensitiveContains(selectedFilter) ?? false
            }
        }

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { genius in
                genius.displayName.localizedCaseInsensitiveContains(searchText) ||
                (genius.bio?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (genius.positionTitle?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        return filtered
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Cream/beige background (matching reference)
                Color(hex: "fef9e7")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Browse Geniuses")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "0a4d3c"))

                        Spacer()

                        Button(action: { showFilterSheet = true }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "0a4d3c"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 16)

                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "94a3b8"))

                        TextField("Search geniuses...", text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "0a4d3c"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 20)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(filters, id: \.self) { filter in
                                BrowseFilterChip(text: filter, isSelected: selectedFilter == filter) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }

                    // Genius list
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                        Spacer()
                    } else if filteredGeniuses.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "9ca3af"))
                            Text("No geniuses found")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "6b7280"))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filteredGeniuses) { genius in
                                    NavigationLink(destination: APIGeniusProfileView(genius: genius, currentUserId: currentUserId)) {
                                        APIBrowseGeniusCard(genius: genius)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheet(selectedFilter: $selectedFilter, filters: filters)
            }
            .task {
                await loadGeniuses()
            }
            .refreshable {
                await loadGeniuses()
            }
        }
    }

    private func loadGeniuses() async {
        isLoading = true
        do {
            geniuses = try await GeniusAPIService.shared.getGeniuses(limit: 100)
        } catch {
            print("Error loading geniuses: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedFilter: String
    let filters: [String]

    var body: some View {
        NavigationView {
            List {
                ForEach(filters, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        dismiss()
                    }) {
                        HStack {
                            Text(filter)
                                .foregroundColor(Color(hex: "1f2937"))
                            Spacer()
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "10b981"))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Genius Profile Detail View
struct GeniusProfileDetailView: View {
    let user: User
    var currentUserId: String = ""
    @State private var showVoteSuccess = false

    private var followManager: FollowManager { FollowManager.shared }

    private var isFollowing: Bool {
        followManager.isFollowing(user.id)
    }

    private var isLoadingFollow: Bool {
        followManager.isLoadingFollow(user.id)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    if let imageURL = user.profileImageURL, !imageURL.isEmpty {
                        Image(imageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(DesignSystem.Gradients.genius)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(user.initials)
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }

                    VStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "1f2937"))
                        Text("Candidate • \(user.country ?? "Africa")")
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
                    DetailStatItem(value: "\(user.votesReceived)", label: "Votes")
                    Divider().frame(height: 40)
                    DetailStatItem(value: "\(user.followersCount)", label: "Followers")
                    Divider().frame(height: 40)
                    DetailStatItem(value: "\(user.followingCount)", label: "Following")
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)

                // Bio
                if let bio = user.bio, !bio.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "1f2937"))
                        Text(bio)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "4b5563"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                }

                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await followManager.toggleFollow(userId: currentUserId, geniusId: user.id)
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
                                    giverUserId: currentUserId,
                                    geniusId: user.id,
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
            .padding(16)
        }
        .background(Color(hex: "f9fafb").ignoresSafeArea())
        .navigationTitle(user.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Vote Submitted!", isPresented: $showVoteSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your vote for \(user.displayName) has been recorded. Thank you for supporting!")
        }
    }
}

// MARK: - Detail Stat Item (for light backgrounds)
struct DetailStatItem: View {
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

// MARK: - Browse Filter Chip
struct BrowseFilterChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : Color(hex: "0a4d3c"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "f59e0b") : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(hex: "e5e7eb"), lineWidth: 1)
                )
        }
    }
}

// MARK: - Browse Genius Card (matching reference)
struct BrowseGeniusCard: View {
    let user: User

    var body: some View {
        HStack(spacing: 14) {
            // Avatar with profile image
            if let imageURL = user.profileImageURL, !imageURL.isEmpty {
                Image(imageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
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
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(user.initials)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    )
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "0a4d3c"))

                Text("Candidate • \(user.country ?? "Africa")")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "64748b"))

                Text(user.bio ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "475569"))
                    .lineLimit(2)
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "94a3b8"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - API Browse Genius Card
struct APIBrowseGeniusCard: View {
    let genius: APIGenius

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "fb923c"), Color(hex: "f59e0b")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
                .overlay(
                    Text(genius.initials)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                )

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(genius.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "0a4d3c"))

                    if genius.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "10b981"))
                    }
                }

                Text("\(genius.positionTitle ?? "Candidate") • \(genius.country ?? "Africa")")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "64748b"))

                Text(genius.bio ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "475569"))
                    .lineLimit(2)
            }

            Spacer()

            // Vote count + arrow
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(genius.votesReceived ?? 0)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "f59e0b"))
                Text("votes")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "9ca3af"))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "94a3b8"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - API Genius Profile View
struct APIGeniusProfileView: View {
    let genius: APIGenius
    var currentUserId: String = ""

    @State private var isFollowing = false
    @State private var isLoadingFollow = false
    @State private var showVoteSuccess = false
    @State private var showVoteError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(DesignSystem.Gradients.genius)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(genius.initials)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        )

                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Text(genius.displayName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(hex: "1f2937"))

                            if genius.isVerified == true {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "10b981"))
                            }
                        }

                        Text("\(genius.positionTitle ?? "Candidate") • \(genius.country ?? "Africa")")
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
                    DetailStatItem(value: "\(genius.votesReceived ?? 0)", label: "Votes")
                    Divider().frame(height: 40)
                    DetailStatItem(value: "\(genius.followersCount ?? 0)", label: "Followers")
                    Divider().frame(height: 40)
                    DetailStatItem(value: "\(genius.profileViews ?? 0)", label: "Views")
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)

                // Bio
                if let bio = genius.bio, !bio.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "1f2937"))
                        Text(bio)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "4b5563"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                }

                // Manifesto
                if let manifesto = genius.manifestoShort, !manifesto.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Vision")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "1f2937"))
                        Text(manifesto)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "4b5563"))
                            .italic()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(hex: "fef9e7"))
                    .cornerRadius(16)
                }

                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: { Task { await toggleFollow() } }) {
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

                    Button(action: { Task { await voteForGenius() } }) {
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
            .padding(16)
        }
        .background(Color(hex: "f9fafb").ignoresSafeArea())
        .navigationTitle(genius.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Vote Submitted!", isPresented: $showVoteSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your vote for \(genius.displayName) has been recorded!")
        }
        .alert("Error", isPresented: $showVoteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Could not submit vote. Please try again.")
        }
        .task {
            await checkFollowStatus()
        }
    }

    private func toggleFollow() async {
        isLoadingFollow = true
        HapticFeedback.impact(.light)

        do {
            let newStatus = try await GeniusAPIService.shared.toggleFollow(
                followerId: currentUserId,
                geniusId: genius.userId
            )
            isFollowing = newStatus
            HapticFeedback.notification(.success)
        } catch {
            print("Error toggling follow: \(error)")
            HapticFeedback.notification(.error)
        }

        isLoadingFollow = false
    }

    private func voteForGenius() async {
        HapticFeedback.impact(.medium)

        do {
            let success = try await GeniusAPIService.shared.voteForGenius(
                voterId: currentUserId,
                geniusId: genius.userId
            )
            if success {
                showVoteSuccess = true
                HapticFeedback.notification(.success)
            }
        } catch {
            print("Error voting: \(error)")
            showVoteError = true
            HapticFeedback.notification(.error)
        }
    }

    private func checkFollowStatus() async {
        do {
            let following = try await GeniusAPIService.shared.getFollowingList(userId: currentUserId)
            isFollowing = following.contains(genius.userId)
        } catch {
            print("Error checking follow status: \(error)")
        }
    }
}

#Preview {
    SupporterDashboardView()
        .modelContainer(for: [User.self, Post.self, Comment.self])
        .environment(AuthService.shared)
}
