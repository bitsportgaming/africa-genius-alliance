//
//  SupporterImpactView.swift
//  AGA
//
//  Impact view for Supporters - Discovery and trust-building
//

import SwiftUI
import SwiftData

struct SupporterImpactView: View {
    @Environment(AuthService.self) private var authService
    @State private var geniuses: [APIGenius] = []
    @State private var isLoading = true
    @State private var selectedFilter = "Overall"
    @State private var selectedCountry = "All Countries"
    @State private var selectedCategory = "All Categories"

    private let filters = ["Overall", "Rising 24h", "Rising 7d", "By Country"]
    private let countries = ["All Countries", "Nigeria", "Kenya", "South Africa", "Ghana", "Ethiopia", "Egypt"]
    private let categories = ["All Categories", "Education", "Health", "Technology", "Trade", "Environment", "Agriculture"]

    private var currentUserId: String {
        authService.currentUser?.id ?? ""
    }

    private var filteredGeniuses: [APIGenius] {
        var filtered = geniuses

        // Apply country filter
        if selectedCountry != "All Countries" {
            filtered = filtered.filter { genius in
                genius.country?.localizedCaseInsensitiveContains(selectedCountry) ?? false
            }
        }

        // Apply category filter
        if selectedCategory != "All Categories" {
            filtered = filtered.filter { genius in
                genius.positionCategory?.localizedCaseInsensitiveContains(selectedCategory) ?? false
            }
        }

        return filtered
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(hex: "fef9e7")
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Header
                            headerSection

                            // Filter Chips
                            filterSection

                            // Country & Category Filters
                            advancedFiltersSection

                            // Leaderboard
                            leaderboardSection

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
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

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Impact")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "0a4d3c"))

            Text("See who is shaping the future")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "6b7280"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Filter Section
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    ImpactFilterChip(text: filter, isSelected: selectedFilter == filter) {
                        selectedFilter = filter
                    }
                }
            }
        }
    }

    // MARK: - Advanced Filters Section
    private var advancedFiltersSection: some View {
        HStack(spacing: 12) {
            // Country Picker
            Menu {
                ForEach(countries, id: \.self) { country in
                    Button(country) {
                        selectedCountry = country
                    }
                }
            } label: {
                HStack {
                    Text(selectedCountry)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "374151"))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "9ca3af"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }

            // Category Picker
            Menu {
                ForEach(categories, id: \.self) { category in
                    Button(category) {
                        selectedCategory = category
                    }
                }
            } label: {
                HStack {
                    Text(selectedCategory)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "374151"))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "9ca3af"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }

            Spacer()
        }
    }

    // MARK: - Leaderboard Section
    private var leaderboardSection: some View {
        VStack(spacing: 12) {
            if filteredGeniuses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "9ca3af"))
                    Text("No geniuses match your filters")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6b7280"))
                }
                .padding(.vertical, 40)
            } else {
                ForEach(Array(filteredGeniuses.enumerated()), id: \.element.id) { index, genius in
                    NavigationLink(destination: APIGeniusProfileView(genius: genius, currentUserId: currentUserId)) {
                        APIImpactGeniusCard(
                            rank: index + 1,
                            genius: genius,
                            currentUserId: currentUserId
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - Impact Filter Chip
struct ImpactFilterChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : Color(hex: "374151"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "0a4d3c") : Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - Impact Genius Card
struct ImpactGeniusCard: View {
    let rank: Int
    let user: User
    var currentUserId: String = ""
    var onFollow: (() -> Void)? = nil

    private var followManager: FollowManager { FollowManager.shared }

    private var isFollowing: Bool {
        followManager.isFollowing(user.id)
    }

    private var isLoadingFollow: Bool {
        followManager.isLoadingFollow(user.id)
    }

    private var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "f59e0b") // Gold
        case 2: return Color(hex: "9ca3af") // Silver
        case 3: return Color(hex: "cd7f32") // Bronze
        default: return Color(hex: "6b7280")
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rank <= 3 ? rankColor.opacity(0.15) : Color(hex: "f3f4f6"))
                    .frame(width: 36, height: 36)

                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(rank <= 3 ? rankColor : Color(hex: "6b7280"))
            }

            // Avatar
            if let imageURL = user.profileImageURL, !imageURL.isEmpty {
                Image(imageURL)
                    .resizable()
                    .scaledToFill()
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
                        Text(user.initials)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "1f2937"))

                Text("\(user.country ?? "Africa") • \(user.votesReceived) votes")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6b7280"))
            }

            Spacer()

            // Actions
            HStack(spacing: 8) {
                Button(action: {
                    Task {
                        await followManager.toggleFollow(userId: currentUserId, geniusId: user.id)
                    }
                    onFollow?()
                }) {
                    if isLoadingFollow {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 70, height: 24)
                    } else {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(isFollowing ? Color(hex: "10b981") : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isFollowing ? Color(hex: "10b981").opacity(0.15) : Color(hex: "10b981"))
                            .cornerRadius(16)
                    }
                }
                .disabled(isLoadingFollow)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - API Impact Genius Card
struct APIImpactGeniusCard: View {
    let rank: Int
    let genius: APIGenius
    var currentUserId: String = ""

    @State private var isFollowing = false
    @State private var isLoadingFollow = false

    private var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "f59e0b") // Gold
        case 2: return Color(hex: "9ca3af") // Silver
        case 3: return Color(hex: "cd7f32") // Bronze
        default: return Color(hex: "6b7280")
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rank <= 3 ? rankColor.opacity(0.15) : Color(hex: "f3f4f6"))
                    .frame(width: 36, height: 36)

                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(rank <= 3 ? rankColor : Color(hex: "6b7280"))
            }

            // Avatar
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
                    Text(genius.initials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(genius.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))

                    if genius.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "10b981"))
                    }
                }

                Text("\(genius.country ?? "Africa") • \(genius.votesReceived ?? 0) votes")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6b7280"))
            }

            Spacer()

            // Actions
            HStack(spacing: 8) {
                Button(action: {
                    Task { await toggleFollow() }
                }) {
                    if isLoadingFollow {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 70, height: 24)
                    } else {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(isFollowing ? Color(hex: "10b981") : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isFollowing ? Color(hex: "10b981").opacity(0.15) : Color(hex: "10b981"))
                            .cornerRadius(16)
                    }
                }
                .disabled(isLoadingFollow)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
    SupporterImpactView()
        .modelContainer(for: [User.self])
        .environment(AuthService.shared)
}
