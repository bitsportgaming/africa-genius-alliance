//
//  ModernProfileView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ModernProfileView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Post.createdAt, order: .reverse) private var allPosts: [Post]

    @State private var showSettings = false
    @State private var showRoleChange = false
    @State private var showImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isUploadingPhoto = false

    private var userPosts: [Post] {
        allPosts.filter { $0.author?.id == authService.currentUser?.id }
    }

    private var isGenius: Bool {
        authService.currentUser?.role == .genius
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

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            Text("Profile")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Button(action: { showSettings = true }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                        // Profile Image Section with Upload
                        VStack(spacing: 16) {
                            // Large circular profile image with upload button
                            ZStack(alignment: .bottomTrailing) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 140, height: 140)
                                        .blur(radius: 15)

                                    // Show uploaded image, existing image, or initials
                                    if let profileImage = profileImage {
                                        Image(uiImage: profileImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 4)
                                            )
                                    } else if let imageURL = authService.currentUser?.profileImageURL, !imageURL.isEmpty {
                                        AsyncImage(url: URL(string: imageURL)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Circle()
                                                .fill(Color.white.opacity(0.3))
                                                .overlay(
                                                    ProgressView()
                                                        .tint(.white)
                                                )
                                        }
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 4)
                                        )
                                    } else {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "fbbf24"), Color(hex: "f59e0b")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 120, height: 120)
                                            .overlay(
                                                Text(authService.currentUser?.initials ?? "?")
                                                    .font(.system(size: 40, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 4)
                                            )
                                    }

                                    // Upload progress overlay
                                    if isUploadingPhoto {
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                            .frame(width: 120, height: 120)
                                            .overlay(
                                                ProgressView()
                                                    .tint(.white)
                                                    .scaleEffect(1.5)
                                            )
                                    }
                                }

                                // Camera button for photo upload
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "0a4d3c"))
                                            .frame(width: 36, height: 36)

                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                }
                                .offset(x: -5, y: -5)
                            }
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                            .onChange(of: selectedPhotoItem) { _, newValue in
                                Task {
                                    await loadAndUploadImage(from: newValue)
                                }
                            }

                            // Name
                            Text(authService.currentUser?.displayName ?? "Unknown")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)

                            // Username
                            Text("@\(authService.currentUser?.username ?? "unknown")")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))

                            // Country if available
                            if let country = authService.currentUser?.country, !country.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 12))
                                    Text(country)
                                        .font(.system(size: 13))
                                }
                                .foregroundColor(.white.opacity(0.8))
                            }

                            // Role and verification badges
                            if isGenius {
                                geniusBadges
                            }
                        }
                        .padding(.top, 20)
                        
                        // Stats Row (matching reference)
                        HStack(spacing: 40) {
                            ProfileStatItem(value: "\(authService.currentUser?.followersCount ?? 0)", label: "Followers")
                            ProfileStatItem(value: "\(userPosts.count)", label: "Posts")
                            ProfileStatItem(value: formatLikes(authService.currentUser?.votesReceived ?? 0), label: "Likes")
                        }
                        .padding(.vertical, 20)

                        // Action Buttons (matching reference)
                        VStack(spacing: 12) {
                            // Join Waitlist button
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

                            // I'm Genius Me button
                            Button(action: { showRoleChange = true }) {
                                Text("I'm Genius Me")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.horizontal, 40)

                        // Bio Section
                        if let bio = authService.currentUser?.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 30)
                                .padding(.top, 10)
                        }

                        Spacer()
                            .frame(height: 20)

                        // Settings section (card style)
                        VStack(spacing: 0) {
                            #if DEBUG
                            NavigationLink(destination: DeveloperSettingsView()) {
                                SettingsRow(icon: "hammer.fill", title: "Developer Settings")
                            }
                            Divider()
                            #endif

                            Button(action: { authService.signOut() }) {
                                SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", isDestructive: true)
                            }
                        }
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)

                        Spacer()
                            .frame(height: 40)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Change Role", isPresented: $showRoleChange) {
                Button("Genius") {
                    authService.currentUser?.role = .genius
                }
                Button("Regular User") {
                    authService.currentUser?.role = .regular
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Select your new role")
            }
        }
    }

    // MARK: - Genius Badges
    private var geniusBadges: some View {
        VStack(spacing: 8) {
            // Role badge (Admin/Genius)
            if let user = authService.currentUser {
                if user.role.isAdmin {
                    // Admin badge with gold checkmark
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                        Text(user.role.isSuperAdmin ? "Super Admin" : "Admin")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "FFD700"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                } else {
                    // Genius role badge
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text("Genius")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "0a4d3c"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                }
            }

            // Verification status badge
            if let user = authService.currentUser {
                HStack(spacing: 4) {
                    Image(systemName: verificationIcon(for: user))
                        .font(.system(size: 10))
                    Text(verificationText(for: user))
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(verificationColor(for: user))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Verification Helpers
    private func verificationIcon(for user: User) -> String {
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

    private func verificationText(for user: User) -> String {
        // Admin roles show admin status
        if user.role.isAdmin {
            return user.role.isSuperAdmin ? "Super Admin" : "Admin"
        }
        switch user.verificationStatus {
        case .unverified: return "Unverified"
        case .pending: return "Pending Verification"
        case .verified: return "AGA Verified"
        }
    }

    private func verificationColor(for user: User) -> Color {
        // Admin roles get gold color
        if user.role.isAdmin {
            return Color(hex: "FFD700")
        }
        switch user.verificationStatus {
        case .unverified: return .white.opacity(0.5)
        case .pending: return .white.opacity(0.7)
        case .verified: return Color(hex: "fbbf24")
        }
    }

    private func formatLikes(_ count: Int) -> String {
        if count >= 1000000 {
            return String(format: "%.1fM", Double(count) / 1000000)
        } else if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000)
        }
        return "\(count)"
    }

    // MARK: - Photo Upload
    private func loadAndUploadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let userId = authService.currentUser?.id else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    profileImage = uiImage
                    isUploadingPhoto = true
                }

                // Upload to backend
                let imageURL = try await UserAPIService.shared.uploadProfileImage(image: uiImage, userId: userId)

                // Update local user with new image URL
                await MainActor.run {
                    authService.currentUser?.profileImageURL = imageURL
                    // Persist the updated user
                    if let user = authService.currentUser {
                        authService.saveUser(user)
                    }
                    isUploadingPhoto = false
                    HapticFeedback.notification(.success)
                }
            }
        } catch {
            print("Profile image upload error: \(error)")
            await MainActor.run {
                isUploadingPhoto = false
                HapticFeedback.notification(.error)
            }
        }
    }
}

// MARK: - Profile Stat Item (for orange background)
struct ProfileStatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(isDestructive ? .red.opacity(0.8) : .white)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 16))
                .foregroundColor(isDestructive ? .red.opacity(0.8) : .white)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Stat Card (legacy)
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(DesignSystem.Colors.adaptiveSurface)
        .cornerRadius(AppConstants.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Compact Post Card
struct CompactPostCard: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.content)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(3)

            HStack(spacing: 16) {
                Label("\(post.likesCount)", systemImage: "heart.fill")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)

                Label("\(post.commentsCount)", systemImage: "bubble.right.fill")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)

                Spacer()

                Text(post.createdAt.timeAgoDisplay)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(AppConstants.padding)
        .background(DesignSystem.Colors.adaptiveSurface)
        .cornerRadius(AppConstants.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ModernProfileView()
        .modelContainer(for: [User.self, Post.self])
        .environment(AuthService.shared)
}

