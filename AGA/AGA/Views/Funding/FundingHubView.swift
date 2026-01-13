//
//  FundingHubView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

struct FundingHubView: View {
    @Environment(AuthService.self) private var authService

    @State private var selectedTab: FundingTab = .geniuses

    enum FundingTab: String, CaseIterable {
        case geniuses = "Geniuses"
        case projects = "Projects"
        case marketplace = "Marketplace"
        case transparency = "Transparency"

        var icon: String {
            switch self {
            case .geniuses: return "person.fill"
            case .projects: return "flag.fill"
            case .marketplace: return "bag.fill"
            case .transparency: return "chart.pie.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a4d3c").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tab Selector
                    tabSelector

                    // Content
                    TabView(selection: $selectedTab) {
                        GeniusFundingView()
                            .tag(FundingTab.geniuses)

                        NationalProjectsView()
                            .tag(FundingTab.projects)

                        ImpactMarketplaceView()
                            .tag(FundingTab.marketplace)

                        TransparencyDashboardView()
                            .tag(FundingTab.transparency)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Fund Impact")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FundingTab.allCases, id: \.self) { tab in
                    Button(action: {
                        HapticFeedback.selection()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 12))
                            Text(tab.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(selectedTab == tab ? .black : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color(hex: "f59e0b") : Color.white.opacity(0.12))
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color(hex: "0a4d3c"))
    }
}

// MARK: - Genius Funding View (Wrapper)
struct GeniusFundingView: View {
    @Environment(AuthService.self) private var authService

    @State private var geniuses: [APIGenius] = []
    @State private var isLoading = true
    @State private var selectedGenius: APIGenius? = nil

    var body: some View {
        ZStack {
            Color(hex: "0a4d3c").ignoresSafeArea()

            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(Color(hex: "f59e0b"))
                    Text("Loading geniuses...")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            } else if geniuses.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.3))
                    Text("No geniuses found")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Check back later")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SUPPORT AFRICAN GENIUSES")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))
                                .tracking(1)

                            Text("Your donation directly supports talented individuals")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Genius Cards
                        ForEach(geniuses) { genius in
                            GeniusFundingCard(genius: genius) {
                                selectedGenius = genius
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .task {
            await loadGeniuses()
        }
        .sheet(item: $selectedGenius) { genius in
            DonationFlowView(
                recipientId: genius.userId,
                recipientName: genius.displayName,
                recipientType: "genius",
                recipientImage: genius.profileImageURL
            )
            .environment(authService)
        }
    }

    private func loadGeniuses() async {
        isLoading = true

        do {
            geniuses = try await GeniusAPIService.shared.getGeniuses()
        } catch {
            print("Error loading geniuses: \(error)")
            geniuses = []
        }

        isLoading = false
    }
}

// MARK: - Genius Funding Card
struct GeniusFundingCard: View {
    let genius: APIGenius
    let onDonate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                // Profile Image
                Circle()
                    .fill(Color(hex: "f59e0b").opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(genius.initials)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "f59e0b"))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(genius.displayName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)

                    if let category = genius.positionCategory {
                        Text(category.capitalized)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "f59e0b"))
                    }

                    if let country = genius.country {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.system(size: 10))
                            Text(country)
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                    }
                }

                Spacer()
            }

            // Bio
            if let bio = genius.bio {
                Text(bio)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }

            // Stats
            HStack(spacing: 20) {
                Label("\(genius.followersCount ?? 0) followers", systemImage: "person.2.fill")
                Label("\(genius.votesReceived ?? 0) votes", systemImage: "hand.thumbsup.fill")
            }
            .font(.system(size: 12))
            .foregroundColor(.white.opacity(0.6))

            // Donate Button
            Button(action: onDonate) {
                HStack {
                    Image(systemName: "heart.fill")
                    Text("Support \(genius.displayName.components(separatedBy: " ").first ?? "Genius")")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "f59e0b"))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    FundingHubView()
        .environment(AuthService.shared)
}
