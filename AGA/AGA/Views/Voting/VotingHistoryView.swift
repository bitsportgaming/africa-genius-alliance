//
//  VotingHistoryView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

struct VotingHistoryView: View {
    @Environment(AuthService.self) private var authService

    @State private var votes: [VoteRecord] = []
    @State private var isLoading = true
    @State private var selectedFilter: String = "All"

    let filters = ["All", "Genius", "Project", "Proposal"]

    var filteredVotes: [VoteRecord] {
        if selectedFilter == "All" { return votes }
        return votes.filter { $0.targetType.lowercased() == selectedFilter.lowercased() }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a4d3c").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header Stats
                    statsHeader

                    // Filter Chips
                    filterChips

                    // Content
                    if isLoading {
                        loadingView
                    } else if filteredVotes.isEmpty {
                        emptyStateView
                    } else {
                        votesList
                    }
                }
            }
            .navigationTitle("Voting History")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadVotingHistory()
            }
        }
    }

    // MARK: - Stats Header
    private var statsHeader: some View {
        HStack(spacing: 16) {
            statCard(title: "Total Votes", value: "\(votes.count)", icon: "checkmark.circle.fill", color: Color(hex: "f59e0b"))
            statCard(title: "Geniuses", value: "\(votes.filter { $0.targetType == "genius" }.count)", icon: "person.fill", color: .blue)
            statCard(title: "Projects", value: "\(votes.filter { $0.targetType == "project" }.count)", icon: "folder.fill", color: .green)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
        )
    }

    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    Button(action: {
                        HapticFeedback.selection()
                        selectedFilter = filter
                    }) {
                        Text(filter)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selectedFilter == filter ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter ? Color(hex: "f59e0b") : Color.white.opacity(0.15))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color(hex: "f59e0b"))
            Text("Loading history...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
            Text("No votes yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text("Your voting history will appear here")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Votes List
    private var votesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredVotes) { vote in
                    VoteHistoryCard(vote: vote)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Load History
    private func loadVotingHistory() async {
        guard let userId = authService.currentUser?.id else { return }

        isLoading = true

        do {
            votes = try await VotingAPIService.shared.getVotingHistory(userId: userId)
        } catch {
            print("Error loading voting history: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Vote History Card
struct VoteHistoryCard: View {
    let vote: VoteRecord

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            Circle()
                .fill(typeColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: typeIcon)
                        .font(.system(size: 20))
                        .foregroundColor(typeColor)
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(vote.targetName ?? "Unknown")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(vote.targetType.capitalized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(typeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(typeColor.opacity(0.2))
                        .cornerRadius(4)

                    if let category = vote.category {
                        Text(category.capitalized)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                Text(formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            // Outcome Badge
            outcomeBadge
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
        )
    }

    private var typeIcon: String {
        switch vote.targetType.lowercased() {
        case "genius": return "person.fill"
        case "project": return "folder.fill"
        case "proposal": return "doc.text.fill"
        default: return "checkmark.circle.fill"
        }
    }

    private var typeColor: Color {
        switch vote.targetType.lowercased() {
        case "genius": return .blue
        case "project": return .green
        case "proposal": return .purple
        default: return Color(hex: "f59e0b")
        }
    }

    private var outcomeBadge: some View {
        Text(vote.outcome.capitalized)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(outcomeColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(outcomeColor.opacity(0.2))
            .cornerRadius(8)
    }

    private var outcomeColor: Color {
        switch vote.outcome.lowercased() {
        case "for", "voted", "supported": return .green
        case "against": return .red
        case "abstain": return .gray
        default: return Color(hex: "f59e0b")
        }
    }

    private var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: vote.createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return vote.createdAt
    }
}

#Preview {
    VotingHistoryView()
        .environment(AuthService.shared)
}
