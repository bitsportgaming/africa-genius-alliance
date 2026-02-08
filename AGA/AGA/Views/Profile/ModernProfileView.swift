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
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Post.createdAt, order: .reverse) private var allPosts: [Post]

    @State private var showSettings = false
    @State private var showRoleChange = false
    @State private var showImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isUploadingPhoto = false
    @State private var showEditProfile = false
    @State private var showWaitlistConfirmation = false
    @State private var showWaitlistSuccess = false
    @State private var isJoiningWaitlist = false
    @State private var waitlistError: String?
    @State private var isRefreshing = false

    private var isOnWaitlist: Bool {
        guard let userId = authService.currentUser?.id else { return false }
        return UserDefaults.standard.bool(forKey: "aga_genius_waitlist_\(userId)")
    }

    // Use UpvoteManager for consistent vote counts across the app
    private let upvoteManager = UpvoteManager.shared

    /// Get the current vote count - uses UpvoteManager's cached count if available
    private var currentVoteCount: Int {
        guard let userId = authService.currentUser?.id else { return 0 }
        return upvoteManager.getVoteCount(userId) ?? authService.currentUser?.votesReceived ?? 0
    }

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
                            // Empty spacer to balance the settings button
                            Color.clear
                                .frame(width: 20, height: 20)

                            Spacer()

                            Text("Profile")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Spacer()

                            Button(action: {
                                HapticFeedback.impact(.light)
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
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
                                        RemoteImage(urlString: imageURL)
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
                            ProfileStatItem(value: formatLikes(currentVoteCount), label: "Likes")
                        }
                        .padding(.vertical, 20)

                        // Action Buttons (matching reference)
                        VStack(spacing: 12) {
                            // Edit Profile button
                            Button(action: {
                                HapticFeedback.impact(.light)
                                showEditProfile = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Edit Profile")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(Color(hex: "0a4d3c"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white)
                                )
                            }
                            .buttonStyle(.plain)

                            // Join Waitlist button (for becoming a verified Genius)
                            if !isGenius {
                                if isOnWaitlist {
                                    // Already on waitlist - show status
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14))
                                        Text("On Genius Waitlist")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                    )
                                } else {
                                    // Can join waitlist
                                    Button(action: {
                                        HapticFeedback.impact(.light)
                                        showWaitlistConfirmation = true
                                    }) {
                                        HStack(spacing: 8) {
                                            if isJoiningWaitlist {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .scaleEffect(0.8)
                                            } else {
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 14))
                                            }
                                            Text("Join Genius Waitlist")
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(Color(hex: "0a4d3c"))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(isJoiningWaitlist)
                                }
                            }

                            // Switch Role button
                            Button(action: {
                                HapticFeedback.impact(.light)
                                showRoleChange = true
                            }) {
                                Text("Switch Role")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
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
                            Button(action: {
                                HapticFeedback.impact(.medium)
                                authService.signOut()
                            }) {
                                SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", isDestructive: true)
                            }
                            .buttonStyle(.plain)
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
            .sheet(isPresented: $showSettings) {
                if let userId = authService.currentUser?.id {
                    GeniusSettingsSheet(userId: userId)
                        .environment(authService)
                }
            }
            .sheet(isPresented: $showEditProfile) {
                NavigationStack {
                    EditProfileSection()
                        .environment(authService)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    showEditProfile = false
                                }
                            }
                        }
                }
            }
            .alert("Join Genius Waitlist", isPresented: $showWaitlistConfirmation) {
                Button("Join Waitlist") {
                    joinWaitlist()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Join the waitlist to become a verified Genius. You'll be notified when your application is reviewed.")
            }
            .alert("You're on the Waitlist! 🎉", isPresented: $showWaitlistSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Thanks for joining! We'll notify you via email when your Genius application is ready for review.")
            }
            .alert("Waitlist Error", isPresented: .init(
                get: { waitlistError != nil },
                set: { if !$0 { waitlistError = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(waitlistError ?? "Failed to join waitlist. Please try again.")
            }
            .sheet(isPresented: $showRoleChange) {
                RoleSelectionSheet()
                    .environment(authService)
            }
            .onAppear {
                // Refresh profile stats from backend every time view appears
                Task {
                    await refreshProfileStats()
                }
            }
            .refreshable {
                // Pull-to-refresh support
                await refreshProfileStats()
            }
        }
    }

    // MARK: - Refresh Profile Stats
    private func refreshProfileStats() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await authService.refreshProfile()
            print("✅ [ModernProfileView] Profile stats refreshed - Followers: \(authService.currentUser?.followersCount ?? 0), Likes: \(authService.currentUser?.votesReceived ?? 0)")
        } catch {
            print("⚠️ [ModernProfileView] Failed to refresh profile: \(error)")
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

                // Validate the returned URL is not empty
                guard !imageURL.isEmpty else {
                    print("❌ [ProfileImage] Backend returned empty profileImageURL")
                    throw NSError(domain: "ProfileImage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server returned empty image URL"])
                }

                print("✅ [ProfileImage] Upload successful, URL: \(imageURL)")

                // Update local user with new image URL (uses AuthService method that properly triggers @Observable update)
                await MainActor.run {
                    authService.updateProfileImageURL(imageURL)
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

    // MARK: - Join Waitlist
    private func joinWaitlist() {
        guard let user = authService.currentUser else { return }

        isJoiningWaitlist = true
        waitlistError = nil

        Task {
            do {
                try await UserAPIService.shared.joinGeniusWaitlist(
                    userId: user.id,
                    email: user.email,
                    displayName: user.displayName
                )

                await MainActor.run {
                    // Save waitlist status locally
                    UserDefaults.standard.set(true, forKey: "aga_genius_waitlist_\(user.id)")
                    isJoiningWaitlist = false
                    showWaitlistSuccess = true
                    HapticFeedback.notification(.success)
                }
            } catch {
                await MainActor.run {
                    isJoiningWaitlist = false
                    waitlistError = error.localizedDescription
                    HapticFeedback.notification(.error)
                }
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

// MARK: - Role Selection Sheet
struct RoleSelectionSheet: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    @State private var showGeniusOnboarding = false

    private var currentRole: UserRole {
        authService.currentUser?.role ?? .regular
    }

    /// Check if user needs genius onboarding (hasn't completed it yet)
    private var needsGeniusOnboarding: Bool {
        guard let userId = authService.currentUser?.id else { return true }
        return !UserDefaults.standard.bool(forKey: "aga_genius_onboarding_\(userId)")
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "10b981"))

                    Text("Select Your Role")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "1f2937"))

                    Text("Choose how you want to participate in the AGA community")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6b7280"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)

                // Role Options
                VStack(spacing: 12) {
                    RoleOptionCard(
                        role: .genius,
                        isSelected: currentRole == .genius,
                        icon: "star.fill",
                        title: "Genius",
                        description: "Create posts, go live, and build your following",
                        selectedColor: Color(hex: "10b981"),
                        action: {
                            selectGeniusRole()
                        }
                    )

                    RoleOptionCard(
                        role: .regular,
                        isSelected: currentRole == .regular,
                        icon: "heart.fill",
                        title: "Supporter",
                        description: "Vote, comment, and support your favorite geniuses",
                        selectedColor: Color(hex: "3b82f6"),
                        action: {
                            selectRole(.regular)
                        }
                    )
                }
                .padding(.horizontal, 20)

                Spacer()

                // Current role indicator
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "10b981"))
                    Text("Current role: \(currentRole.displayName)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "6b7280"))
                }
                .padding(.bottom, 20)
            }
            .background(Color(hex: "f9fafb").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "10b981"))
                }
            }
            .fullScreenCover(isPresented: $showGeniusOnboarding) {
                GeniusOnboardingView()
                    .environment(authService)
            }
        }
    }

    private func selectGeniusRole() {
        HapticFeedback.impact(.medium)

        // Suppress SplashScreenView from auto-redirecting to onboarding
        // We handle onboarding here via fullScreenCover
        authService.suppressOnboardingRedirect = true

        // Update user role - User is a class so properties can be mutated with let
        guard let user = authService.currentUser else { return }
        user.role = .genius

        // Reassign to trigger @Observable update
        authService.currentUser = user
        authService.saveUser(user)

        // Check if user needs to complete genius onboarding
        if needsGeniusOnboarding {
            // Show genius onboarding flow as a fullScreenCover
            // This prevents the parent SplashScreenView from handling it
            HapticFeedback.notification(.warning)
            showGeniusOnboarding = true
        } else {
            // Already completed onboarding, just switch role
            authService.suppressOnboardingRedirect = false
            HapticFeedback.notification(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                dismiss()
            }
        }
    }

    private func selectRole(_ role: UserRole) {
        HapticFeedback.impact(.medium)

        // Update user role - User is a class so properties can be mutated with let
        guard let user = authService.currentUser else { return }
        user.role = role

        // Reassign to trigger @Observable update
        authService.currentUser = user
        authService.saveUser(user)

        HapticFeedback.notification(.success)

        // Dismiss after a short delay to show the selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}

// MARK: - Role Option Card
struct RoleOptionCard: View {
    let role: UserRole
    let isSelected: Bool
    let icon: String
    let title: String
    let description: String
    let selectedColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? selectedColor.opacity(0.15) : Color(hex: "f3f4f6"))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? selectedColor : Color(hex: "9ca3af"))
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isSelected ? Color(hex: "1f2937") : Color(hex: "6b7280"))

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "9ca3af"))
                        .lineLimit(2)
                }

                Spacer()

                // Radio button indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? selectedColor : Color(hex: "d1d5db"), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? selectedColor : Color(hex: "e5e7eb"), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? selectedColor.opacity(0.15) : Color.black.opacity(0.03), radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ModernProfileView()
        .modelContainer(for: [User.self, Post.self])
        .environment(AuthService.shared)
}

