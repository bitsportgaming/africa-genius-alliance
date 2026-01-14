//
//  VotingView.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI

struct VotingView: View {
    @Environment(AuthService.self) private var authService

    @State private var elections: [APIElection] = []
    @State private var selectedElection: APIElection?
    @State private var selectedCandidateId: String?
    @State private var isLoading = true
    @State private var isVoting = false
    @State private var hasVoted = false
    @State private var userVote: APIElectionVote?
    @State private var showVoteSuccess = false
    @State private var showVoteError = false
    @State private var errorMessage = ""
    @State private var transactionHash = ""
    @State private var showCandidateDetail = false
    @State private var selectedCandidateForDetail: APICandidate?

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0f172a"), Color(hex: "1e293b")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if isLoading {
                loadingView
            } else if elections.isEmpty {
                emptyStateView
            } else {
                mainContent
            }
        }
        .task {
            await loadElections()
        }
        .alert("Vote Cast Successfully! 🎉", isPresented: $showVoteSuccess) {
            Button("Done", role: .cancel) {}
            if !transactionHash.isEmpty {
                Button("View on Explorer") {
                    openBlockchainExplorer()
                }
            }
        } message: {
            if transactionHash.isEmpty {
                Text("Your vote has been recorded successfully.")
            } else {
                Text("Your vote has been recorded on BNB Chain.\n\nTx: \(String(transactionHash.prefix(16)))...")
            }
        }
        .alert("Vote Failed", isPresented: $showVoteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showCandidateDetail) {
            if let candidate = selectedCandidateForDetail {
                CandidateDetailSheet(candidate: candidate)
            }
        }
    }

    private func openBlockchainExplorer() {
        guard !transactionHash.isEmpty else { return }
        let explorerUrl = "https://testnet.bscscan.com/tx/\(transactionHash)"
        if let url = URL(string: explorerUrl) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
            Text("Loading Elections...")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "f59e0b"))

            Text("No Active Elections")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            Text("Check back soon for upcoming elections in your region.")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: { Task { await loadElections() } }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "f59e0b"))
                .cornerRadius(25)
            }
        }
    }

    // MARK: - Main Content
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection

                // Election Selector (if multiple)
                if elections.count > 1 {
                    electionSelector
                }

                if let election = selectedElection {
                    // Election Info Card
                    electionInfoCard(election)

                    // Candidates Section
                    candidatesSection(election)

                    // Voting Controls
                    if !hasVoted {
                        votingControlsCard
                    } else {
                        votedConfirmationCard
                    }
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "f59e0b"))

                Text("Vote")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                // Refresh button
                Button(action: { Task { await loadElections() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Text("Your vote is recorded on-chain and protected from interference")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Election Selector
    private var electionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(elections, id: \.electionId) { election in
                    Button(action: { selectElection(election) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(election.position)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedElection?.electionId == election.electionId ? .white : .white.opacity(0.7))

                            Text(election.country)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedElection?.electionId == election.electionId
                                    ? Color(hex: "f59e0b")
                                    : Color.white.opacity(0.1))
                        )
                    }
                }
            }
        }
    }

    // MARK: - Election Info Card
    private func electionInfoCard(_ election: APIElection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status badges
            HStack(spacing: 8) {
                Text(election.status.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(election.status == "active" ? Color.green : Color.orange)
                    .cornerRadius(12)

                // Blockchain badge
                if election.isOnChain {
                    HStack(spacing: 4) {
                        Image(systemName: "link.badge.plus")
                            .font(.system(size: 10))
                        Text(election.chainName)
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "F0B90B")) // BNB yellow
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "F0B90B").opacity(0.2))
                    .cornerRadius(12)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(election.totalVotes) votes")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    if let totalVoters = election.totalVoters, totalVoters > 0 {
                        Text("\(totalVoters) voters")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }

            Text(election.position)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(Color(hex: "f59e0b"))
                Text("\(election.country)\(election.region?.isEmpty == false ? " • \(election.region!)" : "")")
                    .foregroundColor(.white.opacity(0.7))
            }
            .font(.system(size: 14))

            if !election.description.isEmpty {
                Text(election.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .lineSpacing(2)
            }

            // Time remaining
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(Color(hex: "f59e0b"))
                Text(timeRemaining(until: election.endDate))
                    .foregroundColor(.white.opacity(0.7))
            }
            .font(.system(size: 13))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }

    // MARK: - Candidates Section
    private func candidatesSection(_ election: APIElection) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CANDIDATES")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            ForEach(election.candidates, id: \.candidateId) { candidate in
                CandidateCard(
                    candidate: candidate,
                    totalVotes: election.totalVotes,
                    isSelected: selectedCandidateId == candidate.candidateId,
                    hasVoted: hasVoted,
                    votedFor: userVote?.candidateId == candidate.candidateId,
                    onSelect: {
                        if !hasVoted {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCandidateId = candidate.candidateId
                            }
                            HapticFeedback.impact(.light)
                        }
                    }
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }

    // MARK: - Voting Controls Card (Classic: 1 vote per election)
    private var votingControlsCard: some View {
        VStack(spacing: 16) {
            // Selected candidate summary
            if let candidateId = selectedCandidateId,
               let election = selectedElection,
               let candidate = election.candidates.first(where: { $0.candidateId == candidateId }) {

                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: "f59e0b").opacity(0.3))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(String(candidate.name.prefix(1)))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your Selection")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Text(candidate.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text(candidate.party)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "f59e0b"))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "f59e0b").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "f59e0b").opacity(0.3), lineWidth: 1)
                        )
                )
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.4))

                    Text("Select a candidate above to cast your vote")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
            }

            // Blockchain info
            if let election = selectedElection, election.isOnChain {
                HStack(spacing: 8) {
                    Image(systemName: "link.badge.plus")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "F0B90B"))
                    Text("Your vote will be recorded on \(election.chainName)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Cast Vote Button
            Button(action: { Task { await castVote() } }) {
                HStack(spacing: 12) {
                    if isVoting {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Image(systemName: "checkmark.shield.fill")
                    }
                    Text(isVoting ? "Recording on blockchain..." : "Cast Vote")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    selectedCandidateId != nil
                        ? Color(hex: "f59e0b")
                        : Color.gray.opacity(0.5)
                )
                .cornerRadius(14)
            }
            .disabled(selectedCandidateId == nil || isVoting)

            Text("One vote per election. Results are public, transparent, and immutable on the blockchain.")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }



    // MARK: - Voted Confirmation Card
    private var votedConfirmationCard: some View {
        VStack(spacing: 16) {
            // Success icon with animation
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }

            Text("Vote Recorded!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            // Show who they voted for
            if let vote = userVote,
               let election = selectedElection,
               let candidate = election.candidates.first(where: { $0.candidateId == vote.candidateId }) {
                HStack(spacing: 8) {
                    Text("You voted for")
                        .foregroundColor(.white.opacity(0.6))
                    Text(candidate.name)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .font(.system(size: 14))
            }

            // Blockchain verification section
            if let vote = userVote, let txHash = vote.transactionHash, !txHash.isEmpty {
                VStack(spacing: 12) {
                    // Transaction info
                    VStack(spacing: 6) {
                        HStack {
                            Image(systemName: "link.badge.plus")
                                .foregroundColor(Color(hex: "F0B90B"))
                            Text("Blockchain Verified")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "F0B90B"))

                            if vote.isConfirmed {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                            }
                        }

                        Text(txHash)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: .infinity)

                        if let blockNumber = vote.blockNumber {
                            Text("Block #\(blockNumber)")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "F0B90B").opacity(0.1))
                    )

                    // View on explorer button
                    Button(action: {
                        if let explorerUrl = vote.explorerUrl, let url = URL(string: explorerUrl) {
                            UIApplication.shared.open(url)
                        } else {
                            let url = URL(string: "https://testnet.bscscan.com/tx/\(txHash)")!
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.right.square")
                            Text("View on BscScan")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "F0B90B"))
                    }
                }
            }

            Text("Your vote is immutably recorded and publicly auditable.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Helper Functions
    private func loadElections() async {
        isLoading = true

        // Seed elections if needed (for testing)
        try? await ElectionAPIService.shared.seedElections()

        do {
            elections = try await ElectionAPIService.shared.getActiveElections()

            // Select first election by default
            if let first = elections.first {
                selectElection(first)
            }
        } catch {
            print("Error loading elections: \(error)")
        }

        isLoading = false
    }

    private func selectElection(_ election: APIElection) {
        selectedElection = election
        selectedCandidateId = nil
        hasVoted = false
        userVote = nil

        // Check if user already voted
        Task {
            let userId = authService.currentUser?.id ?? ""
            let (voted, vote) = try await ElectionAPIService.shared.checkUserVote(
                electionId: election.electionId,
                userId: userId
            )
            await MainActor.run {
                hasVoted = voted
                userVote = vote
                if voted, let v = vote {
                    selectedCandidateId = v.candidateId
                }
            }
        }
    }

    private func castVote() async {
        guard let election = selectedElection,
              let candidateId = selectedCandidateId else { return }

        isVoting = true
        HapticFeedback.impact(.medium)

        let userId = authService.currentUser?.id ?? "anonymous"

        do {
            // Classic voting: 1 vote per user per election
            let result = try await ElectionAPIService.shared.castVote(
                electionId: election.electionId,
                userId: userId,
                candidateId: candidateId
            )

            await MainActor.run {
                hasVoted = true
                userVote = result?.vote
                transactionHash = result?.vote?.transactionHash ?? ""

                // Update local election data
                if let updatedElection = result?.election {
                    selectedElection = updatedElection
                    if let idx = elections.firstIndex(where: { $0.electionId == updatedElection.electionId }) {
                        elections[idx] = updatedElection
                    }
                }

                showVoteSuccess = true
                HapticFeedback.notification(.success)
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showVoteError = true
                HapticFeedback.notification(.error)
            }
        }

        isVoting = false
    }

    private func timeRemaining(until dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: dateString) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: dateString) else {
                return "Unknown"
            }
            return formatTimeRemaining(to: date)
        }
        return formatTimeRemaining(to: date)
    }

    private func formatTimeRemaining(to date: Date) -> String {
        let now = Date()
        let diff = date.timeIntervalSince(now)

        if diff <= 0 {
            return "Voting ended"
        }

        let days = Int(diff / 86400)
        let hours = Int((diff.truncatingRemainder(dividingBy: 86400)) / 3600)

        if days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") \(hours)h remaining"
        } else {
            return "\(hours) hours remaining"
        }
    }
}

// MARK: - Candidate Card
struct CandidateCard: View {
    let candidate: APICandidate
    let totalVotes: Int
    let isSelected: Bool
    let hasVoted: Bool
    let votedFor: Bool
    let onSelect: () -> Void

    private var percentage: Int {
        guard totalVotes > 0 else { return 0 }
        return Int(round(Double(candidate.votesReceived) / Double(totalVotes) * 100))
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Avatar
                    Circle()
                        .fill(Color(hex: "f59e0b").opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(String(candidate.name.prefix(1)))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(candidate.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)

                            if votedFor {
                                Text("YOUR VOTE")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }

                        Text(candidate.party)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    // Selection indicator / percentage
                    VStack(alignment: .trailing, spacing: 2) {
                        if isSelected && !hasVoted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "f59e0b"))
                        } else {
                            Text("\(percentage)%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(votedFor ? .green : .white.opacity(0.8))
                        }

                        Text("\(candidate.votesReceived) votes")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(votedFor ? Color.green : (isSelected ? Color(hex: "f59e0b") : Color.white.opacity(0.3)))
                            .frame(width: geo.size.width * CGFloat(percentage) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "f59e0b").opacity(0.15) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color(hex: "f59e0b") : (votedFor ? Color.green.opacity(0.5) : Color.white.opacity(0.1)),
                                lineWidth: isSelected || votedFor ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(hasVoted)
    }
}

// MARK: - Candidate Detail Sheet
struct CandidateDetailSheet: View {
    let candidate: APICandidate
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar
                    Circle()
                        .fill(Color(hex: "f59e0b").opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(String(candidate.name.prefix(1)))
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))
                        )

                    // Name and party
                    VStack(spacing: 8) {
                        Text(candidate.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        Text(candidate.party)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Bio
                    if let bio = candidate.bio, !bio.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BIOGRAPHY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))
                                .tracking(1)

                            Text(bio)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                    }

                    // Manifesto
                    if let manifesto = candidate.manifesto, !manifesto.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MANIFESTO")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))
                                .tracking(1)

                            Text(manifesto)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                    }

                    // Vote stats
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("\(candidate.votesReceived)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))
                            Text("Votes")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                    }
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "0f172a"), Color(hex: "1e293b")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Candidate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "f59e0b"))
                }
            }
        }
    }
}

#Preview {
    VotingView()
        .environment(AuthService.shared)
}