//
//  ModernFeedView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI
import SwiftData

struct ModernFeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthService.self) private var authService
    @Query(sort: \User.votesReceived, order: .reverse) private var users: [User]
    @Query(sort: \Post.createdAt, order: .reverse) private var posts: [Post]

    @State private var viewModel: FeedViewModel?
    @State private var showCreatePost = false
    @State private var selectedPost: Post?
    @State private var selectedGenius: User?
    @State private var currentIndex = 0
    @State private var refreshing = false

    private var geniuses: [User] {
        users.filter { $0.role == .genius }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Orange gradient background (matching reference)
                LinearGradient(
                    colors: [Color(hex: "fb923c"), Color(hex: "f59e0b"), Color(hex: "d97706")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Home")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 16)

                    // Main content - Genius cards carousel
                    if geniuses.isEmpty {
                        EmptyFeedView()
                    } else {
                        TabView(selection: $currentIndex) {
                            ForEach(Array(geniuses.enumerated()), id: \.element.id) { index, genius in
                                GeniusHeroCard(genius: genius)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(maxHeight: .infinity)
                    }

                    // Page indicator dots
                    if !geniuses.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(0..<min(geniuses.count, 5), id: \.self) { index in
                                Circle()
                                    .fill(currentIndex == index ? Color.white : Color.white.opacity(0.4))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreatePost) {
                ModernCreatePostView()
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = FeedViewModel(modelContext: modelContext)
                }
            }
        }
    }
}

// MARK: - Genius Hero Card (Matching Reference Design)
struct GeniusHeroCard: View {
    let genius: User

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Large circular profile image
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)

                // Profile image or placeholder
                if let imageURL = genius.profileImageURL, !imageURL.isEmpty {
                    Image(imageURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "fbbf24"), Color(hex: "f59e0b")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 160, height: 160)
                        .overlay(
                            Text(genius.initials)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                }
            }

            // Name
            Text(genius.displayName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            // Title/tagline
            Text("Hire Genius,\nBy Geniuses")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "0a4d3c"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Bio
            Text(genius.bio ?? "")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 30)

            Spacer()

            // Action button
            Button(action: {}) {
                Text("Join Waitlist")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "f59e0b"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                    )
            }
            .padding(.horizontal, 40)

            // Stats row
            HStack(spacing: 30) {
                StatItem(value: "\(genius.followersCount)", label: "Followers")
                StatItem(value: "\(genius.votesReceived)", label: "Votes")
                StatItem(value: "4.8k", label: "Likes")
            }
            .padding(.top, 10)

            Spacer()
                .frame(height: 30)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Empty State
struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("agas")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .opacity(0.3)

            Text("No Posts Yet")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Text("Be the first genius to share your thoughts!")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    ModernFeedView()
        .modelContainer(for: [Post.self, User.self, Comment.self, Like.self, Vote.self])
        .environment(AuthService.shared)
}

