//
//  VotingHubView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

struct VotingHubView: View {
    @Environment(AuthService.self) private var authService
    @State private var selectedSection: VotingSection? = nil

    enum VotingSection: String, CaseIterable, Identifiable {
        case geniuses = "Vote for Geniuses"
        case elections = "Elections"
        case proposals = "Governance Proposals"
        case projects = "Projects"
        case funding = "Fund Geniuses"
        case history = "Voting History"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .geniuses: return "person.3.fill"
            case .elections: return "checkmark.shield.fill"
            case .proposals: return "doc.text.fill"
            case .projects: return "building.2.fill"
            case .funding: return "dollarsign.circle.fill"
            case .history: return "clock.arrow.circlepath"
            }
        }

        var description: String {
            switch self {
            case .geniuses: return "Support talented individuals by voting for them"
            case .elections: return "Cast your vote in active elections"
            case .proposals: return "Vote on governance and policy proposals"
            case .projects: return "Explore and support community projects"
            case .funding: return "Contribute funds to support geniuses"
            case .history: return "View your past votes and contributions"
            }
        }

        var color: String {
            switch self {
            case .geniuses: return "f59e0b"
            case .elections: return "10b981"
            case .proposals: return "6366f1"
            case .projects: return "0ea5e9"
            case .funding: return "f97316"
            case .history: return "8b5cf6"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "0f172a"), Color(hex: "1e293b")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        quickActionsSection
                        allSectionsGrid
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationDestination(item: $selectedSection) { section in
                destinationView(for: section)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "f59e0b"))

                Text("Vote & Support")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }

            Text("Make your voice heard and support the geniuses shaping Africa's future")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK ACTIONS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            HStack(spacing: 12) {
                quickActionButton(section: .geniuses)
                quickActionButton(section: .elections)
            }
        }
    }

    private func quickActionButton(section: VotingSection) -> some View {
        Button(action: { selectedSection = section }) {
            HStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: section.color))

                VStack(alignment: .leading, spacing: 2) {
                    Text(section.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Tap to start")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: section.color).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: section.color).opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - All Sections Grid
    private var allSectionsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ALL OPTIONS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(VotingSection.allCases) { section in
                    sectionCard(section)
                }
            }
        }
    }

    private func sectionCard(_ section: VotingSection) -> some View {
        Button(action: { selectedSection = section }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: section.color).opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: section.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: section.color))
                }

                Text(section.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(section.description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
        }
    }

    // MARK: - Destination Views
    @ViewBuilder
    private func destinationView(for section: VotingSection) -> some View {
        switch section {
        case .geniuses:
            VoteForGeniusesView()
        case .elections:
            VotingView()
        case .proposals:
            GovernanceProposalsView()
        case .projects:
            ProjectsListView()
        case .funding:
            FundingView()
        case .history:
            VotingHistoryView()
        }
    }
}

// MARK: - Vote for Geniuses View
struct VoteForGeniusesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: String = "All"
    @State private var geniuses: [APIGenius] = []
    @State private var isLoading = true

    let categories = ["All", "Education", "Health", "Technology", "Trade", "Infrastructure", "Security"]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0f172a"), Color(hex: "1e293b")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                Task { await loadGeniuses() }
                            }) {
                                Text(category)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(selectedCategory == category ? .black : .white.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedCategory == category ? Color(hex: "f59e0b") : Color.white.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)

                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                    Spacer()
                } else if geniuses.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.3")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.4))
                        Text("No geniuses found")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(geniuses, id: \.userId) { genius in
                                GeniusVoteRow(genius: genius)
                            }
                        }
                        .padding(16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationTitle("Vote for Geniuses")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadGeniuses()
        }
    }

    private func loadGeniuses() async {
        isLoading = true

        do {
            let allGeniuses = try await GeniusAPIService.shared.getGeniuses(limit: 50)

            if selectedCategory == "All" {
                geniuses = allGeniuses
            } else {
                geniuses = allGeniuses.filter { genius in
                    let category = genius.positionCategory?.lowercased() ?? ""
                    let title = genius.positionTitle?.lowercased() ?? ""
                    let bio = genius.bio?.lowercased() ?? ""
                    let searchTerm = selectedCategory.lowercased()

                    return category.contains(searchTerm) ||
                           title.contains(searchTerm) ||
                           bio.contains(searchTerm)
                }
            }
        } catch {
            print("Error loading geniuses: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Genius Vote Row
struct GeniusVoteRow: View {
    @Environment(AuthService.self) private var authService
    let genius: APIGenius
    @State private var isVoting = false
    @State private var showSuccess = false

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AsyncImage(url: URL(string: genius.profileImageURL ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle()
                    .fill(Color(hex: "f59e0b").opacity(0.2))
                    .overlay(
                        Text(String(genius.displayName.prefix(1)))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "f59e0b"))
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(genius.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text(genius.positionTitle ?? "Genius")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))

                HStack(spacing: 8) {
                    Label("\(genius.votesReceived ?? 0)", systemImage: "hand.thumbsup.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "f59e0b"))
                }
            }

            Spacer()

            Button(action: { Task { await vote() } }) {
                if isVoting {
                    ProgressView()
                        .tint(Color(hex: "f59e0b"))
                        .frame(width: 70, height: 36)
                } else if showSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                        .frame(width: 70, height: 36)
                } else {
                    Text("Vote")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "f59e0b"))
                        .frame(width: 70, height: 36)
                        .background(Color(hex: "f59e0b").opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .disabled(isVoting || showSuccess)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
        )
    }

    private func vote() async {
        isVoting = true
        HapticFeedback.impact(.medium)

        do {
            let userId = authService.currentUser?.id ?? ""
            let success = try await HomeAPIService.shared.vote(
                giverUserId: userId,
                geniusId: genius.userId,
                positionId: "general"
            )

            await MainActor.run {
                if success {
                    showSuccess = true
                    HapticFeedback.notification(.success)
                }
            }
        } catch {
            print("Error voting: \(error)")
            HapticFeedback.notification(.error)
        }

        isVoting = false
    }
}

#Preview {
    VotingHubView()
        .environment(AuthService.shared)
}

