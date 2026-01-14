//
//  GeniusImpactView.swift
//  AGA
//
//  Impact view for Geniuses - Summary + Motivation screen
//

import SwiftUI

struct GeniusImpactView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var impactData: GeniusImpactData?
    @State private var isLoading = true
    @State private var showCreatePost = false

    // Callback to switch to Create tab (set by parent)
    var onSwitchToCreateTab: (() -> Void)?

    var body: some View {
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

                        // My Rank Card
                        myRankCard

                        // Momentum Section
                        momentumSection

                        // Comparison Section
                        comparisonSection

                        // CTA
                        boostImpactCTA

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
        .task {
            await loadData()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("My Impact")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "0a4d3c"))

            Text("Track your leadership momentum")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "6b7280"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - My Rank Card
    private var myRankCard: some View {
        let data = impactData ?? GeniusImpactData.placeholder

        return VStack(spacing: 16) {
            // Rank Badge
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Rank")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "6b7280"))

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("#\(data.currentRank)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color(hex: "0a4d3c"))

                        HStack(spacing: 2) {
                            Image(systemName: data.rankChange >= 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 12, weight: .bold))
                            Text("\(abs(data.rankChange))")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(data.rankChange >= 0 ? Color(hex: "10b981") : Color(hex: "ef4444"))
                    }
                }

                Spacer()

                // Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "f59e0b"), Color(hex: "fb923c")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }

            Divider()

            // Stats Row
            HStack(spacing: 0) {
                ImpactStatItem(title: "Total Votes", value: formatNumber(data.totalVotes), icon: "checkmark.circle.fill")
                ImpactStatItem(title: "Followers", value: formatNumber(data.followers), icon: "person.2.fill")
                ImpactStatItem(title: "Profile Views", value: formatNumber(data.profileViews), icon: "eye.fill")
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    // MARK: - Momentum Section
    private var momentumSection: some View {
        let data = impactData ?? GeniusImpactData.placeholder

        return VStack(alignment: .leading, spacing: 12) {
            Text("📈 Momentum")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            HStack(spacing: 12) {
                MomentumCard(
                    title: "24h Change",
                    voteChange: data.votes24h,
                    followerChange: data.followers24h
                )
                MomentumCard(
                    title: "7 Day Change",
                    voteChange: data.votes7d,
                    followerChange: data.followers7d
                )
            }
        }
    }

    // MARK: - Comparison Section
    private var comparisonSection: some View {
        let data = impactData ?? GeniusImpactData.placeholder

        return VStack(alignment: .leading, spacing: 12) {
            Text("🏆 Standing")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            VStack(spacing: 12) {
                ComparisonRow(
                    icon: "person.3.fill",
                    text: "You are ahead of \(data.peerPercentage)% of peers in your category"
                )

                if let countryRank = data.countryRank {
                    ComparisonRow(
                        icon: "mappin.circle.fill",
                        text: "Top \(countryRank) in \(data.country ?? "your country")"
                    )
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Boost Impact CTA
    private var boostImpactCTA: some View {
        Button(action: {
            HapticFeedback.impact(.medium)
            // Try callback first, fallback to showing create post sheet
            if let callback = onSwitchToCreateTab {
                callback()
            } else {
                showCreatePost = true
            }
        }) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18))
                Text("Boost Impact")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "10b981"), Color(hex: "059669")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostSheet()
        }
    }

    // MARK: - Helper Functions
    private func loadData() async {
        isLoading = true
        // Simulate API call
        try? await Task.sleep(nanoseconds: 500_000_000)
        impactData = GeniusImpactData.placeholder
        isLoading = false
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1000000 {
            return String(format: "%.1fM", Double(number) / 1000000)
        } else if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000)
        }
        return "\(number)"
    }
}

// MARK: - Data Model
struct GeniusImpactData {
    let currentRank: Int
    let rankChange: Int
    let totalVotes: Int
    let followers: Int
    let profileViews: Int
    let votes24h: Int
    let followers24h: Int
    let votes7d: Int
    let followers7d: Int
    let peerPercentage: Int
    let countryRank: Int?
    let country: String?

    static let placeholder = GeniusImpactData(
        currentRank: 47,
        rankChange: 5,
        totalVotes: 12847,
        followers: 3421,
        profileViews: 8934,
        votes24h: 156,
        followers24h: 23,
        votes7d: 892,
        followers7d: 134,
        peerPercentage: 78,
        countryRank: 5,
        country: "Nigeria"
    )
}

// MARK: - Impact Stat Item
struct ImpactStatItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "10b981"))

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "6b7280"))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Momentum Card
struct MomentumCard: View {
    let title: String
    let voteChange: Int
    let followerChange: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "6b7280"))

            VStack(alignment: .leading, spacing: 8) {
                MomentumRow(label: "Votes", change: voteChange)
                MomentumRow(label: "Followers", change: followerChange)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Momentum Row
struct MomentumRow: View {
    let label: String
    let change: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "4b5563"))

            Spacer()

            HStack(spacing: 2) {
                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                    .font(.system(size: 10, weight: .bold))
                Text("+\(change)")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(change >= 0 ? Color(hex: "10b981") : Color(hex: "ef4444"))
        }
    }
}

// MARK: - Comparison Row
struct ComparisonRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "f59e0b"))
                .frame(width: 24)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "4b5563"))

            Spacer()
        }
    }
}

#Preview {
    GeniusImpactView()
        .environmentObject(AuthViewModel(authService: AuthService.shared))
}
