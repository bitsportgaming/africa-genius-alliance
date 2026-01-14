//
//  HomeComponents.swift
//  AGA
//
//  Created by AGA Team on 12/30/25.
//

import SwiftUI

// MARK: - Top Bar
struct HomeTopBar: View {
    let greeting: String
    let subtitle: String?
    let avatarURL: String?
    let initials: String
    var onNotificationTap: () -> Void = {}
    var onAvatarTap: () -> Void = {}
    var onSearchTap: (() -> Void)? = nil

    private var initialsView: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Gradients.primary)
                .frame(width: 40, height: 40)
            Text(initials)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "1f2937"))
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6b7280"))
                }
            }

            Spacer()

            HStack(spacing: 12) {
                if let onSearch = onSearchTap {
                    Button(action: onSearch) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "4b5563"))
                            .frame(width: 40, height: 40)
                            .background(Color(hex: "f3f4f6"))
                            .clipShape(Circle())
                    }
                }

                Button(action: onNotificationTap) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "4b5563"))
                            .frame(width: 40, height: 40)
                            .background(Color(hex: "f3f4f6"))
                            .clipShape(Circle())

                        Circle()
                            .fill(Color(hex: "ef4444"))
                            .frame(width: 10, height: 10)
                            .offset(x: 2, y: -2)
                    }
                }

                Button(action: onAvatarTap) {
                    if let avatarURL = avatarURL, !avatarURL.isEmpty, let url = URL(string: avatarURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            case .failure, .empty:
                                initialsView
                            @unknown default:
                                initialsView
                            }
                        }
                    } else {
                        initialsView
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Home Stat Card (for Impact Snapshot)
struct HomeStatCard: View {
    let label: String
    let value: String
    let delta: Int?
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Spacer()
                if let delta = delta {
                    HStack(spacing: 2) {
                        Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                        Text(delta >= 0 ? "+\(delta)" : "\(delta)")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(delta >= 0 ? Color(hex: "10b981") : Color(hex: "ef4444"))
                }
            }

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "6b7280"))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Action Card (for Command Center)
struct ActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "1f2937"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Genius Card (for Carousels)
struct GeniusCardSmall: View {
    let genius: TrendingGenius
    var onTap: () -> Void = {}
    var onFollow: () -> Void = {}
    var onVote: () -> Void = {}

    private var followManager: FollowManager { FollowManager.shared }
    @State private var isPressed = false
    @State private var followButtonScale: CGFloat = 1.0
    @State private var voteButtonScale: CGFloat = 1.0

    private var isFollowing: Bool {
        followManager.isFollowing(genius.id)
    }

    private var isLoadingFollow: Bool {
        followManager.isLoadingFollow(genius.id)
    }

    var body: some View {
        VStack(spacing: 10) {
            // Avatar with subtle hover effect
            ZStack(alignment: .bottomTrailing) {
                if let avatarURL = genius.avatarURL, !avatarURL.isEmpty {
                    Image(avatarURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Gradients.genius)
                            .frame(width: 60, height: 60)
                        Text(genius.initials)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                if genius.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "10b981"))
                        .background(Circle().fill(.white).frame(width: 18, height: 18))
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(FluidAnimation.snappy, value: isPressed)

            VStack(spacing: 2) {
                Text(genius.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "1f2937"))
                    .lineLimit(1)

                Text(genius.positionTitle)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "6b7280"))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text("#\(genius.rank)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "f59e0b"))

                    Text("•")
                        .foregroundColor(Color(hex: "d1d5db"))

                    Text("\(genius.votes.formatted()) votes")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "6b7280"))
                }
            }

            HStack(spacing: 6) {
                Button(action: {
                    HapticFeedback.impact(.light)
                    withAnimation(FluidAnimation.bouncy) {
                        followButtonScale = 0.9
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(FluidAnimation.smooth) {
                            followButtonScale = 1.0
                        }
                    }
                    onFollow()
                }) {
                    if isLoadingFollow {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 50, height: 24)
                    } else {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(isFollowing ? Color(hex: "10b981") : .white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isFollowing ? Color(hex: "10b981").opacity(0.15) : Color(hex: "10b981"))
                            .cornerRadius(12)
                    }
                }
                .scaleEffect(followButtonScale)
                .disabled(isLoadingFollow)

                Button(action: {
                    HapticFeedback.impact(.medium)
                    withAnimation(FluidAnimation.bouncy) {
                        voteButtonScale = 0.9
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(FluidAnimation.smooth) {
                            voteButtonScale = 1.0
                        }
                    }
                    onVote()
                }) {
                    Text("Vote")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "f59e0b"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "f59e0b").opacity(0.15))
                        .cornerRadius(12)
                }
                .scaleEffect(voteButtonScale)
            }
        }
        .padding(12)
        .frame(width: 140)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(isPressed ? 0.08 : 0.05), radius: isPressed ? 6 : 10, x: 0, y: isPressed ? 2 : 4)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(FluidAnimation.snappy, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        HapticFeedback.impact(.light)
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    onTap()
                }
        )
    }
}

// MARK: - Alert Row
struct AlertRow: View {
    let alert: AlertItem
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(priorityColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: alert.icon)
                        .font(.system(size: 14))
                        .foregroundColor(priorityColor)
                }

                Text(alert.message)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "374151"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                Text(alert.actionLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "10b981"))

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var priorityColor: Color {
        switch alert.priority {
        case 1: return Color(hex: "ef4444")
        case 2: return Color(hex: "f59e0b")
        default: return Color(hex: "6b7280")
        }
    }
}

// MARK: - Quick Action Pill
struct QuickActionPill: View {
    let title: String
    let icon: String?
    let isActive: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticFeedback.selection()
            action()
        }) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isActive ? .white : Color(hex: "4b5563"))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isActive ? Color(hex: "10b981") : Color(hex: "f3f4f6"))
            .cornerRadius(20)
            .scaleEffect(isPressed ? 0.94 : 1.0)
            .animation(FluidAnimation.snappy, value: isPressed)
            .animation(FluidAnimation.smooth, value: isActive)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Category Grid Item
struct CategoryGridItem: View {
    let category: CategoryItem
    let action: () -> Void
    @State private var isPressed = false
    @State private var iconScale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            HapticFeedback.impact(.light)
            withAnimation(FluidAnimation.bouncy) {
                iconScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(FluidAnimation.smooth) {
                    iconScale = 1.0
                }
            }
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: category.color).opacity(isPressed ? 0.25 : 0.15))
                        .frame(width: 44, height: 44)
                        .animation(FluidAnimation.snappy, value: isPressed)
                    Image(systemName: category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: category.color))
                        .scaleEffect(iconScale)
                }

                Text(category.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "374151"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(isPressed ? 0.06 : 0.03), radius: isPressed ? 2 : 4, x: 0, y: isPressed ? 1 : 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(FluidAnimation.snappy, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

