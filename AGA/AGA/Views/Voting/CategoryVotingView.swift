//
//  CategoryVotingView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

// MARK: - Voting Category
enum VotingCategory: String, CaseIterable, Identifiable {
    case technology = "Technology"
    case education = "Education"
    case health = "Health"
    case trade = "Trade"
    case environment = "Environment"
    case governance = "Governance"
    case arts = "Arts"
    case agriculture = "Agriculture"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .technology: return "cpu"
        case .education: return "book.fill"
        case .health: return "heart.fill"
        case .trade: return "chart.line.uptrend.xyaxis"
        case .environment: return "leaf.fill"
        case .governance: return "building.columns.fill"
        case .arts: return "paintpalette.fill"
        case .agriculture: return "tree.fill"
        }
    }

    var color: Color {
        switch self {
        case .technology: return Color(hex: "3b82f6")
        case .education: return Color(hex: "8b5cf6")
        case .health: return Color(hex: "ef4444")
        case .trade: return Color(hex: "f59e0b")
        case .environment: return Color(hex: "22c55e")
        case .governance: return Color(hex: "6366f1")
        case .arts: return Color(hex: "ec4899")
        case .agriculture: return Color(hex: "84cc16")
        }
    }
}

struct CategoryVotingView: View {
    @Environment(AuthService.self) private var authService
    @State private var selectedCategory: VotingCategory = .technology
    @State private var geniuses: [APIUser] = []
    @State private var isLoading = true
    @State private var votedGeniusIds: Set<String> = []
    @State private var showVoteSuccess = false
    @State private var votedGeniusName = ""

    var body: some View {
        ZStack {
            Color(hex: "0a4d3c").ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                // Category Pills
                categorySelector

                // Geniuses List
                if isLoading {
                    loadingView
                } else if geniuses.isEmpty {
                    emptyStateView
                } else {
                    geniusList
                }
            }
        }
        .task {
            await loadGeniuses()
        }
        .alert("Vote Cast! 🎉", isPresented: $showVoteSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your vote for \(votedGeniusName) has been recorded.")
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vote for Geniuses")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("Support African innovators by category")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Button(action: { Task { await loadGeniuses() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }

    // MARK: - Category Selector
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(VotingCategory.allCases) { category in
                    CategoryPill(
                        category: category,
                        isSelected: selectedCategory == category,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = category
                            }
                            Task { await loadGeniuses() }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
            Text("Loading geniuses...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 12)
            Spacer()
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: selectedCategory.icon)
                .font(.system(size: 50))
                .foregroundColor(selectedCategory.color.opacity(0.5))

            Text("No geniuses in \(selectedCategory.rawValue) yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Text("Check back soon or explore other categories")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Genius List
    private var geniusList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(geniuses, id: \.userId) { genius in
                    GeniusVoteCard(
                        genius: genius,
                        category: selectedCategory,
                        hasVoted: votedGeniusIds.contains(genius.userId),
                        onVote: {
                            Task { await voteForGenius(genius) }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Actions
    private func loadGeniuses() async {
        isLoading = true

        do {
            // Load geniuses filtered by category
            geniuses = try await UserAPIService.shared.getGeniusesByCategory(category: selectedCategory.rawValue.lowercased())
        } catch {
            print("Error loading geniuses: \(error)")
            geniuses = []
        }

        isLoading = false
    }

    private func voteForGenius(_ genius: APIUser) async {
        guard let userId = authService.currentUser?.id else { return }

        do {
            _ = try await VotingAPIService.shared.voteForGenius(
                voterId: userId,
                geniusId: genius.userId,
                category: selectedCategory.rawValue.lowercased()
            )

            await MainActor.run {
                votedGeniusIds.insert(genius.userId)
                votedGeniusName = genius.displayName
                showVoteSuccess = true
                HapticFeedback.notification(.success)
            }
        } catch {
            print("Vote error: \(error)")
            HapticFeedback.notification(.error)
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let category: VotingCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))

                Text(category.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? category.color : Color.white.opacity(0.15))
            )
        }
    }
}

// MARK: - Genius Vote Card
struct GeniusVoteCard: View {
    let genius: APIUser
    let category: VotingCategory
    let hasVoted: Bool
    let onVote: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(category.color.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay(
                    Text(String(genius.displayName.prefix(1)))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(category.color)
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(genius.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(genius.positionTitle ?? "Genius")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))

                HStack(spacing: 12) {
                    Label("\(genius.votesReceived ?? 0)", systemImage: "hand.thumbsup.fill")
                    Label("\(genius.followersCount ?? 0)", systemImage: "person.2.fill")
                }
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Vote Button
            Button(action: onVote) {
                HStack(spacing: 6) {
                    Image(systemName: hasVoted ? "checkmark" : "hand.thumbsup.fill")
                    Text(hasVoted ? "Voted" : "Vote")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(hasVoted ? .white : category.color)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(hasVoted ? Color.green : Color.white)
                )
            }
            .disabled(hasVoted)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }
}

#Preview {
    CategoryVotingView()
        .environment(AuthService.shared)
}

