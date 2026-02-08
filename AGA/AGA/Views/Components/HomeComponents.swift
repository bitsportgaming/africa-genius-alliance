//
//  HomeComponents.swift
//  AGA
//
//  Created by AGA Team on 12/30/25.
//  Enhanced UI V2
//

import SwiftUI

// MARK: - Top Bar (Enhanced with glass effect)
struct HomeTopBar: View {
    let greeting: String
    let subtitle: String?
    let avatarURL: String?
    let initials: String
    var notificationCount: Int = 0
    var onNotificationTap: () -> Void = {}
    var onAvatarTap: () -> Void = {}
    var onSearchTap: (() -> Void)? = nil

    private var initialsView: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(DesignSystem.Colors.primary.opacity(0.2))
                .frame(width: 46, height: 46)
                .blur(radius: 4)

            Circle()
                .fill(DesignSystem.Gradients.primary)
                .frame(width: 42, height: 42)
            Text(initials)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }

            Spacer()

            HStack(spacing: 10) {
                if let onSearch = onSearchTap {
                    IconButtonSmall(icon: "magnifyingglass", action: onSearch)
                }

                // Notification button with badge
                Button(action: {
                    HapticFeedback.impact(.light)
                    onNotificationTap()
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .frame(width: 42, height: 42)
                            .background(DesignSystem.Colors.surfaceSecondary)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )

                        // Notification badge - only show when there are notifications
                        if notificationCount > 0 {
                            ZStack {
                                Circle()
                                    .fill(DesignSystem.Colors.error)
                                    .frame(width: notificationCount > 9 ? 18 : 14, height: 14)

                                if notificationCount <= 99 {
                                    Text("\(notificationCount)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Text("99+")
                                        .font(.system(size: 7, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .offset(x: 4, y: -4)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.3), value: notificationCount)
                }
                .buttonStyle(ScaleButtonStyle())

                // Avatar button
                Button(action: {
                    HapticFeedback.impact(.light)
                    onAvatarTap()
                }) {
                    if let avatarURL = avatarURL, !avatarURL.isEmpty {
                        RemoteImage(urlString: avatarURL)
                            .frame(width: 42, height: 42)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 2)
                            )
                    } else {
                        initialsView
                    }
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Colors.surface
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Small Icon Button
struct IconButtonSmall: View {
    let icon: String
    var badge: Int? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.impact(.light)
            action()
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(width: 42, height: 42)
                    .background(DesignSystem.Colors.surfaceSecondary)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(DesignSystem.Colors.border, lineWidth: 1)
                    )

                if let badge = badge, badge > 0 {
                    Text(badge > 99 ? "99+" : "\(badge)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(DesignSystem.Colors.error)
                        .clipShape(Capsule())
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Home Stat Card (Enhanced with gradient and animation)
struct HomeStatCard: View {
    let label: String
    let value: String
    let delta: Int?
    let icon: String
    let color: Color

    @State private var isAnimated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Icon with soft background
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(color)
                }

                Spacer()

                if let delta = delta {
                    HStack(spacing: 3) {
                        Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                        Text(delta >= 0 ? "+\(delta)" : "\(delta)")
                            .font(DesignSystem.Typography.captionBold)
                    }
                    .foregroundColor(delta >= 0 ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(delta >= 0 ? DesignSystem.Colors.successSoft : DesignSystem.Colors.errorSoft)
                    )
                }
            }

            Text(value)
                .font(DesignSystem.Typography.stat)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .scaleEffect(isAnimated ? 1.0 : 0.8)
                .opacity(isAnimated ? 1.0 : 0)

            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                isAnimated = true
            }
        }
    }
}

// MARK: - Action Card (Enhanced with press effect)
struct ActionCard: View {
    let title: String
    let icon: String
    let color: Color
    var subtitle: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.impact(.light)
            action()
        }) {
            VStack(spacing: 10) {
                // Icon with gradient glow
                ZStack {
                    // Glow
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 54, height: 54)
                        .blur(radius: 6)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Genius Card (Enhanced for Carousels)
struct GeniusCardSmall: View {
    let genius: TrendingGenius
    var onTap: () -> Void = {}
    var onFollow: () -> Void = {}
    var onUpvote: () -> Void = {}

    // Use stored constants instead of computed properties for proper @Observable tracking
    private let followManager = FollowManager.shared
    private let upvoteManager = UpvoteManager.shared

    private var isFollowing: Bool {
        followManager.isFollowing(genius.id)
    }

    private var isLoadingFollow: Bool {
        followManager.isLoadingFollow(genius.id)
    }

    private var hasUpvoted: Bool {
        upvoteManager.hasUpvoted(genius.id)
    }

    private var isLoadingUpvote: Bool {
        upvoteManager.isLoadingUpvote(genius.id)
    }

    /// Current vote count - use UpvoteManager's cached count if available, otherwise use genius.votes
    private var currentVoteCount: Int {
        upvoteManager.getVoteCount(genius.id) ?? genius.votes
    }

    var body: some View {
        VStack(spacing: 12) {
            // Tappable area for opening genius detail
            Button(action: {
                HapticFeedback.impact(.light)
                onTap()
            }) {
                VStack(spacing: 12) {
                    // Avatar with glow effect
                    ZStack(alignment: .bottomTrailing) {
                        // Outer glow
                        Circle()
                            .fill(DesignSystem.Colors.accent.opacity(0.15))
                            .frame(width: 72, height: 72)

                        if let avatarURL = genius.avatarURL, !avatarURL.isEmpty {
                            RemoteImage(urlString: avatarURL)
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(DesignSystem.Colors.accent.opacity(0.3), lineWidth: 2)
                                )
                        } else {
                            ZStack {
                                Circle()
                                    .fill(DesignSystem.Gradients.genius)
                                    .frame(width: 64, height: 64)
                                Text(genius.initials)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }

                        if genius.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 18))
                                .foregroundColor(DesignSystem.Colors.success)
                                .background(
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 20, height: 20)
                                )
                                .offset(x: 2, y: 2)
                        }
                    }

                    VStack(spacing: 4) {
                        Text(genius.name)
                            .font(DesignSystem.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .lineLimit(1)

                        Text(genius.positionTitle)
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .lineLimit(1)

                        // Rank badge - use UpvoteManager's cached count if available
                        HStack(spacing: 4) {
                            Text("#\(genius.rank)")
                                .font(DesignSystem.Typography.captionBold)
                                .foregroundColor(DesignSystem.Colors.accent)

                            Text("•")
                                .foregroundColor(DesignSystem.Colors.textMuted)
                                .font(.system(size: 8))

                            Text("\(currentVoteCount.formatted()) upvotes")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Action buttons - separate from the tap area above
            HStack(spacing: 6) {
                Button(action: {
                    HapticFeedback.impact(.light)
                    onFollow()
                }) {
                    if isLoadingFollow {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(height: 28)
                    } else {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(isFollowing ? DesignSystem.Colors.primary : .white)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(isFollowing ? DesignSystem.Colors.primarySoft : DesignSystem.Colors.primary)
                            )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isLoadingFollow ? 1.0 : 1.0)
                .disabled(isLoadingFollow)

                Button(action: {
                    if !hasUpvoted && !isLoadingUpvote {
                        HapticFeedback.impact(.medium)
                        onUpvote()
                    }
                }) {
                    if isLoadingUpvote {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(height: 28)
                    } else {
                        HStack(spacing: 4) {
                            if hasUpvoted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                            }
                            Text(hasUpvoted ? "Upvoted" : "Upvote")
                                .font(.system(size: 10, weight: .semibold))
                                .lineLimit(1)
                        }
                        .foregroundColor(hasUpvoted ? .white : DesignSystem.Colors.accent)
                        .padding(.horizontal, hasUpvoted ? 8 : 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(hasUpvoted ? Color.green.opacity(0.8) : DesignSystem.Colors.accentSoft)
                        )
                        .opacity(hasUpvoted ? 0.7 : 1.0)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(hasUpvoted || isLoadingUpvote)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(width: 160)
        .background(DesignSystem.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                .stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Alert Row (Enhanced with priority indicators)
struct AlertRow: View {
    let alert: AlertItem
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: {
            HapticFeedback.impact(.light)
            onTap()
        }) {
            HStack(spacing: 14) {
                // Priority indicator with glow
                ZStack {
                    Circle()
                        .fill(priorityColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Circle()
                        .fill(priorityColor.opacity(0.08))
                        .frame(width: 46, height: 46)
                        .blur(radius: 4)
                    Image(systemName: alert.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(priorityColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(alert.message)
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(alert.actionLabel)
                        .font(DesignSystem.Typography.captionBold)
                        .foregroundColor(DesignSystem.Colors.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textMuted)
                    .frame(width: 24, height: 24)
                    .background(DesignSystem.Colors.surfaceSecondary)
                    .clipShape(Circle())
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(priorityColor.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var priorityColor: Color {
        switch alert.priority {
        case 1: return DesignSystem.Colors.error
        case 2: return DesignSystem.Colors.accent
        default: return DesignSystem.Colors.textSecondary
        }
    }
}

// MARK: - Quick Action Pill (Enhanced with selection state)
struct QuickActionPill: View {
    let title: String
    let icon: String?
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.selection()
            action()
        }) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(DesignSystem.Typography.captionBold)
            }
            .foregroundColor(isActive ? .white : DesignSystem.Colors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isActive ? DesignSystem.Colors.primary : DesignSystem.Colors.surfaceSecondary)
            )
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.clear : DesignSystem.Colors.border, lineWidth: 1)
            )
            .shadow(
                color: isActive ? DesignSystem.Colors.primary.opacity(0.3) : .clear,
                radius: isActive ? 6 : 0,
                x: 0,
                y: isActive ? 3 : 0
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Category Grid Item (Enhanced with hover effect)
struct CategoryGridItem: View {
    let category: CategoryItem
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticFeedback.impact(.light)
            action()
        }) {
            VStack(spacing: 10) {
                // Icon with gradient background
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(Color(hex: category.color).opacity(0.1))
                        .frame(width: 52, height: 52)
                        .blur(radius: 4)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: category.color),
                                    Color(hex: category.color).opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text(category.name)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

