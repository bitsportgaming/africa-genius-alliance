//
//  GovernanceProposalsView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

struct GovernanceProposalsView: View {
    @Environment(AuthService.self) private var authService

    @State private var proposals: [ProposalRecord] = []
    @State private var isLoading = true
    @State private var selectedCategory: String = "All"
    @State private var selectedStatus: String = "All"
    @State private var selectedProposal: ProposalRecord? = nil

    let categories = ["All", "Policy", "Budget", "Constitutional", "Community", "Technical"]
    let statuses = ["All", "Active", "Passed", "Rejected", "Pending"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a4d3c").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Category Filter
                    categoryFilter

                    // Content
                    if isLoading {
                        loadingView
                    } else if proposals.isEmpty {
                        emptyStateView
                    } else {
                        proposalsList
                    }
                }
            }
            .navigationTitle("Governance")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadProposals()
            }
            .sheet(item: $selectedProposal) { proposal in
                ProposalDetailView(proposal: proposal)
                    .environment(authService)
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GOVERNANCE PROPOSALS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            Text("Vote on community proposals")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        HapticFeedback.selection()
                        selectedCategory = category
                        Task { await loadProposals() }
                    }) {
                        Text(category)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isSelected(category) ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected(category) ? Color(hex: "f59e0b") : Color.white.opacity(0.15))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }

    private func isSelected(_ category: String) -> Bool {
        return selectedCategory == category
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color(hex: "f59e0b"))
            Text("Loading proposals...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
            Text("No proposals found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text("Check back later for new governance proposals")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Proposals List
    private var proposalsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(proposals) { proposal in
                    ProposalCard(proposal: proposal) {
                        selectedProposal = proposal
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Load Proposals
    private func loadProposals() async {
        isLoading = true

        do {
            proposals = try await ProposalAPIService.shared.getProposals(
                category: selectedCategory == "All" ? nil : selectedCategory.lowercased(),
                status: selectedStatus == "All" ? nil : selectedStatus.lowercased()
            )
        } catch {
            print("Error loading proposals: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Proposal Card
struct ProposalCard: View {
    let proposal: ProposalRecord
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(proposal.category.capitalized)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "f59e0b"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "f59e0b").opacity(0.2))
                        .cornerRadius(6)

                    Spacer()

                    statusBadge
                }

                // Title
                Text(proposal.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Description
                Text(proposal.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)

                // Voting Progress
                VStack(alignment: .leading, spacing: 8) {
                    // For/Against bars
                    HStack(spacing: 4) {
                        // For bar
                        GeometryReader { geo in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: geo.size.width * CGFloat(proposal.forPercentage) / 100)

                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: geo.size.width * CGFloat(proposal.againstPercentage) / 100)

                                Spacer()
                            }
                        }
                        .frame(height: 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(3)
                    }

                    // Vote counts
                    HStack {
                        HStack(spacing: 4) {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                            Text("\(proposal.votesFor) For")
                        }

                        HStack(spacing: 4) {
                            Circle().fill(Color.red).frame(width: 8, height: 8)
                            Text("\(proposal.votesAgainst) Against")
                        }

                        Spacer()

                        Text("\(proposal.totalVotes) total")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                }

                // Quorum Progress
                HStack {
                    Text("Quorum:")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.2))

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "f59e0b"))
                                .frame(width: geo.size.width * proposal.quorumProgress)
                        }
                    }
                    .frame(height: 4)

                    Text("\(Int(proposal.quorumProgress * 100))%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "f59e0b"))
                }

                // Proposer
                HStack {
                    Text("by \(proposal.proposerName)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var statusBadge: some View {
        Text(proposal.status.capitalized)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .cornerRadius(6)
    }

    private var statusColor: Color {
        switch proposal.status.lowercased() {
        case "active": return .green
        case "passed": return .blue
        case "rejected": return .red
        case "pending": return .orange
        default: return .gray
        }
    }
}

#Preview {
    GovernanceProposalsView()
        .environment(AuthService.shared)
}
