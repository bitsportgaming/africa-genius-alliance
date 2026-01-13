//
//  GeniusProfileView.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI

struct GeniusProfileView: View {
    @Environment(AuthService.self) private var authService
    let user: User

    @State private var showDonation = false
    @State private var fundingStats: GeniusFundingStats?
    @State private var projects: [ProjectRecord] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            // Background gradient
            Color(hex: "0a4d3c").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Profile Header
                    profileHeader

                    // Stats Row
                    statsRow

                    // Funding Progress Card
                    fundingProgressCard

                    // Vision Statement
                    visionCard

                    // Key Commitments
                    commitmentsCard

                    // Projects Showcase
                    if !projects.isEmpty {
                        projectsShowcase
                    }

                    // Voting Stats
                    votingStatsCard

                    // CTA Buttons
                    ctaButtons

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .task {
            await loadData()
        }
        .sheet(isPresented: $showDonation) {
            DonationFlowView(
                recipientId: user.id,
                recipientName: user.name,
                recipientType: "genius",
                recipientImage: user.profileImageURL
            )
            .environment(authService)
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        HStack(alignment: .top, spacing: 14) {
            ProfileAvatarLarge(initials: user.initials, profileImageURL: user.profileImageURL)

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Text(user.geniusPosition ?? "Genius")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "f59e0b"))

                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 10))
                    Text(user.country ?? "Africa")
                    if let category = user.geniusCategory {
                        Text("•")
                        Text(category)
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))

                HStack(spacing: 6) {
                    verificationBadge
                    if user.isElectoralPosition {
                        electoralBadge
                    }
                }
                .padding(.top, 4)
            }

            Spacer()
        }
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 10) {
            GeniusStatCard(label: "Votes", value: "\(user.votesReceived)")
            GeniusStatCard(label: "Supporters", value: "\(user.supportersCount)")
            GeniusStatCard(label: "Rank", value: "#\(fundingStats?.rank ?? 0)")
        }
    }

    // MARK: - Funding Progress Card
    private var fundingProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("FUNDING RECEIVED")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "f59e0b"))
                    .tracking(1)

                Spacer()

                Text("\(fundingStats?.donorsCount ?? 0) donors")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }

            HStack(alignment: .bottom, spacing: 8) {
                Text("$\(formatNumber(fundingStats?.totalReceived ?? 0))")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                if let change = fundingStats?.monthlyChange, change > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 10))
                        Text("+\(Int(change))%")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.green)
                    .padding(.bottom, 6)
                }
            }

            // Monthly breakdown
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This Month")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    Text("$\(formatNumber(fundingStats?.thisMonth ?? 0))")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Last Month")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    Text("$\(formatNumber(fundingStats?.lastMonth ?? 0))")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }

    // MARK: - Vision Card
    private var visionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("VISION STATEMENT")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            Text(user.bio ?? "Building a better Africa through innovation and collaboration.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    // MARK: - Commitments Card
    private var commitmentsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("KEY COMMITMENTS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            VStack(alignment: .leading, spacing: 8) {
                CommitmentRow(text: "Deliver measurable impact in my sector")
                CommitmentRow(text: "Maintain transparency with supporters")
                CommitmentRow(text: "Collaborate with fellow geniuses")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    // MARK: - Projects Showcase
    private var projectsShowcase: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MY PROJECTS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "f59e0b"))
                    .tracking(1)

                Spacer()

                Text("\(projects.count) active")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }

            ForEach(projects.prefix(3)) { project in
                ProjectMiniCard(project: project)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    // MARK: - Voting Stats Card
    private var votingStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VOTING PERFORMANCE")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            HStack(spacing: 16) {
                VotingStatItem(label: "Total Votes", value: "\(user.votesReceived)", icon: "hand.thumbsup.fill")
                VotingStatItem(label: "This Week", value: "+\(fundingStats?.weeklyVotes ?? 0)", icon: "chart.line.uptrend.xyaxis")
                VotingStatItem(label: "Rank Change", value: fundingStats?.rankChange ?? "+0", icon: "arrow.up.arrow.down")
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    // MARK: - CTA Buttons
    private var ctaButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                HapticFeedback.impact(.medium)
                // Vote action
            }) {
                HStack {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("Vote")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "0a4d3c"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(.white))
            }

            Button(action: {
                HapticFeedback.impact(.medium)
                showDonation = true
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                    Text("Fund")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "f59e0b")))
            }
        }
    }

    // MARK: - Electoral Badge
    private var electoralBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 9))
            Text("Electoral")
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(.green)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.green.opacity(0.15))
        .cornerRadius(8)
    }

    // MARK: - Verification Badge
    private var verificationBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: verificationIcon)
                .font(.system(size: 9))
            Text(verificationText)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(verificationColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(verificationColor.opacity(0.15))
        .cornerRadius(8)
    }

    // MARK: - Admin Badge
    @ViewBuilder
    private var adminBadge: some View {
        if user.role.isAdmin {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 9))
                Text(user.role.isSuperAdmin ? "Super Admin" : "Admin")
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(Color(hex: "FFD700"))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: "FFD700").opacity(0.15))
            .cornerRadius(8)
        }
    }

    private var verificationIcon: String {
        // Admin roles get gold checkmark
        if user.role.isAdmin {
            return "checkmark.seal.fill"
        }
        switch user.verificationStatus {
        case .unverified: return "xmark.circle"
        case .pending: return "clock.fill"
        case .verified: return "checkmark.seal.fill"
        }
    }

    private var verificationText: String {
        // Admin roles show admin status
        if user.role.isAdmin {
            return user.role.isSuperAdmin ? "Super Admin" : "Admin"
        }
        switch user.verificationStatus {
        case .unverified: return "Unverified"
        case .pending: return "Pending"
        case .verified: return "AGA Verified"
        }
    }

    private var verificationColor: Color {
        // Admin roles get gold color
        if user.role.isAdmin {
            return Color(hex: "FFD700")
        }
        switch user.verificationStatus {
        case .unverified: return Color(hex: "6b7280")
        case .pending: return Color(hex: "9ca3af")
        case .verified: return Color(hex: "fbbf24")
        }
    }

    // MARK: - Helper Functions
    private func formatNumber(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.0fK", value / 1_000)
        }
        return String(format: "%.0f", value)
    }

    // MARK: - Load Data
    private func loadData() async {
        isLoading = true

        // Mock funding stats for now
        fundingStats = GeniusFundingStats(
            totalReceived: 84210,
            thisMonth: 12500,
            lastMonth: 9800,
            monthlyChange: 27.5,
            donorsCount: 156,
            rank: 47,
            weeklyVotes: 234,
            rankChange: "+5"
        )

        // Load projects
        do {
            let allProjects = try await ProjectAPIService.shared.getProjects()
            projects = allProjects.filter { $0.creatorId == user.id }
        } catch {
            print("Error loading projects: \(error)")
        }

        isLoading = false
    }
}

// MARK: - Genius Funding Stats Model
struct GeniusFundingStats {
    let totalReceived: Double
    let thisMonth: Double
    let lastMonth: Double
    let monthlyChange: Double
    let donorsCount: Int
    let rank: Int
    let weeklyVotes: Int
    let rankChange: String
}

// MARK: - Project Mini Card
struct ProjectMiniCard: View {
    let project: ProjectRecord

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "f59e0b").opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "flag.fill")
                        .foregroundColor(Color(hex: "f59e0b"))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(project.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text("$\(Int(project.fundingRaised)) raised")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))

                    Text("\(project.fundingPercentage)%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "f59e0b"))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.05)))
    }
}

// MARK: - Voting Stat Item
struct VotingStatItem: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "f59e0b"))

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Genius Stat Card
struct GeniusStatCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(DesignSystem.Colors.textTertiary)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textBright)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(hex: "0f172a").opacity(0.6))
        .cornerRadius(AppConstants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                .stroke(Color(hex: "94a3b8").opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Commitment Row
struct CommitmentRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.accent)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

