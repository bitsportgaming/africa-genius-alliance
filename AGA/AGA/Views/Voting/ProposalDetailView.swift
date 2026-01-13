//
//  ProposalDetailView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

struct ProposalDetailView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    let proposal: ProposalRecord

    @State private var hasVoted = false
    @State private var userVote: String? = nil
    @State private var isVoting = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a4d3c").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Status Header
                        statusHeader

                        // Title & Description
                        proposalInfo

                        // Voting Results
                        votingResults

                        // Vote Buttons
                        if !hasVoted && proposal.status.lowercased() == "active" {
                            voteButtons
                        }

                        // Implementation Details
                        if let details = proposal.implementationDetails, !details.isEmpty {
                            implementationSection(details)
                        }

                        // Impact
                        if let impact = proposal.impact, !impact.isEmpty {
                            impactSection(impact)
                        }

                        // Proposer Info
                        proposerSection
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Proposal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
    }

    // MARK: - Status Header
    private var statusHeader: some View {
        HStack {
            Text(proposal.category.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            Spacer()

            Text(proposal.status.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.2))
                .cornerRadius(8)
        }
    }

    private var statusColor: Color {
        switch proposal.status.lowercased() {
        case "active": return .green
        case "passed": return .blue
        case "rejected": return .red
        default: return .gray
        }
    }

    // MARK: - Proposal Info
    private var proposalInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(proposal.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            Text(proposal.description)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Voting Results
    private var votingResults: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("VOTING RESULTS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            // Progress bars
            VStack(spacing: 12) {
                voteBar(label: "For", count: proposal.votesFor, color: .green, percentage: proposal.forPercentage)
                voteBar(label: "Against", count: proposal.votesAgainst, color: .red, percentage: proposal.againstPercentage)
            }

            // Quorum
            HStack {
                Text("Quorum Progress:")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                Text("\(proposal.totalVotes) / \(proposal.quorumRequired) votes")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(proposal.quorumProgress >= 1 ? .green : Color(hex: "f59e0b"))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(proposal.quorumProgress >= 1 ? Color.green : Color(hex: "f59e0b"))
                        .frame(width: geo.size.width * proposal.quorumProgress)
                }
            }
            .frame(height: 10)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func voteBar(label: String, count: Int, color: Color, percentage: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                Text("\(count) votes (\(percentage)%)")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(percentage) / 100)
                }
            }
            .frame(height: 10)
        }
    }

    // MARK: - Vote Buttons
    private var voteButtons: some View {
        VStack(spacing: 12) {
            Text("CAST YOUR VOTE")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            HStack(spacing: 12) {
                // For Button
                Button(action: { Task { await castVote("for") } }) {
                    HStack {
                        if isVoting && userVote == "for" {
                            ProgressView().scaleEffect(0.8).tint(.white)
                        } else {
                            Image(systemName: "hand.thumbsup.fill")
                        }
                        Text("Vote For")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.green))
                }
                .disabled(isVoting)

                // Against Button
                Button(action: { Task { await castVote("against") } }) {
                    HStack {
                        if isVoting && userVote == "against" {
                            ProgressView().scaleEffect(0.8).tint(.white)
                        } else {
                            Image(systemName: "hand.thumbsdown.fill")
                        }
                        Text("Vote Against")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.red))
                }
                .disabled(isVoting)
            }

            // Abstain Button
            Button(action: { Task { await castVote("abstain") } }) {
                HStack {
                    if isVoting && userVote == "abstain" {
                        ProgressView().scaleEffect(0.8).tint(.white)
                    } else {
                        Image(systemName: "minus.circle.fill")
                    }
                    Text("Abstain")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray))
            }
            .disabled(isVoting)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    // MARK: - Implementation Section
    private func implementationSection(_ details: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IMPLEMENTATION DETAILS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            Text(details)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    // MARK: - Impact Section
    private func impactSection(_ impact: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXPECTED IMPACT")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            Text(impact)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    // MARK: - Proposer Section
    private var proposerSection: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "f59e0b").opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(proposal.proposerName.prefix(1)))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "f59e0b"))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Proposed by")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))

                Text(proposal.proposerName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    // MARK: - Cast Vote
    private func castVote(_ vote: String) async {
        guard let userId = authService.currentUser?.id else { return }

        isVoting = true
        userVote = vote

        do {
            _ = try await VotingAPIService.shared.voteOnProposal(
                voterId: userId,
                proposalId: proposal.proposalId,
                voteType: vote
            )

            await MainActor.run {
                hasVoted = true
                HapticFeedback.notification(.success)
            }
        } catch {
            print("Vote error: \(error)")
            HapticFeedback.notification(.error)
        }

        isVoting = false
    }
}

#Preview {
    ProposalDetailView(proposal: ProposalRecord(
        id: "1",
        proposalId: "prop123",
        title: "Increase Education Budget by 15%",
        description: "This proposal aims to increase the national education budget by 15% to improve school infrastructure and teacher salaries.",
        category: "budget",
        proposerId: "user1",
        proposerName: "Kwame Asante",
        status: "active",
        votesFor: 1250,
        votesAgainst: 340,
        votesAbstain: 89,
        quorumRequired: 2000,
        passingThreshold: 60,
        startDate: "2025-12-01",
        endDate: "2026-01-15",
        implementationDetails: "The budget increase will be phased over 3 years, with immediate focus on rural schools.",
        impact: "Expected to benefit 2 million students and 50,000 teachers nationwide.",
        createdAt: "2025-12-01"
    ))
    .environment(AuthService.shared)
}
