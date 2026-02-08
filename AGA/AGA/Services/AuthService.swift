//
//  AuthService.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftData

@Observable
class AuthService {
    static let shared = AuthService()

    var currentUser: User?
    var isAuthenticated: Bool {
        return currentUser != nil
    }

    /// Flag to suppress SplashScreenView from auto-switching to onboarding
    /// when role is changed from within the app (e.g., RoleSelectionSheet)
    var suppressOnboardingRedirect: Bool = false

    // Track if genius has completed onboarding
    var needsGeniusOnboarding: Bool {
        // If redirect is suppressed (in-app role switch), don't trigger onboarding redirect
        if suppressOnboardingRedirect { return false }
        guard let user = currentUser, user.role == .genius else { return false }
        return !hasCompletedGeniusOnboarding
    }

    private var hasCompletedGeniusOnboarding: Bool {
        guard let userId = currentUser?.id else { return false }
        return UserDefaults.standard.bool(forKey: "aga_genius_onboarding_\(userId)")
    }

    // UserDefaults keys for persistence
    private let userIdKey = "aga_current_user_id"
    private let userDataKey = "aga_current_user_data"

    private init() {
        // Restore user from UserDefaults on init
        restoreUser()
    }

    // MARK: - Authentication Methods

    func signUp(username: String, email: String, password: String, displayName: String, role: UserRole) async throws -> User {
        // Call the backend API
        let apiUser = try await UserAPIService.shared.register(
            username: username,
            email: email,
            password: password,
            displayName: displayName,
            role: role
        )

        print("🔍 [AuthService] Registration response - userId: '\(apiUser.userId)', role: '\(apiUser.role)', votesReceived: \(apiUser.votesReceived ?? 0), followersCount: \(apiUser.followersCount ?? 0)")

        // Convert API response to local User model
        let user = convertAPIUserToUser(apiUser)

        print("🔍 [AuthService] Converted user - id: '\(user.id)', role: '\(user.role.rawValue)', votesReceived: \(user.votesReceived), followersCount: \(user.followersCount)")

        // Save to persistence
        self.currentUser = user
        saveUser(user)

        return user
    }

    func signIn(email: String, password: String) async throws -> User {
        // Call the backend API
        let apiUser = try await UserAPIService.shared.login(email: email, password: password)

        // Convert API response to local User model
        let user = convertAPIUserToUser(apiUser)

        // Save to persistence
        self.currentUser = user
        saveUser(user)

        return user
    }

    func signOut() {
        self.currentUser = nil
        clearSavedUser()
        KeychainService.shared.deleteToken()
    }

    func updateUserRole(to role: UserRole) {
        guard let user = currentUser else { return }
        user.role = role
        // Reassign to trigger @Observable update
        currentUser = user
        saveUser(user)
    }

    /// Update the user's profile image URL and persist to UserDefaults
    /// This method properly triggers @Observable update by reassigning currentUser
    func updateProfileImageURL(_ imageURL: String) {
        guard let user = currentUser else { return }
        user.profileImageURL = imageURL
        // Reassign to trigger @Observable update
        currentUser = user
        saveUser(user)
        print("💾 [AuthService] Profile image URL updated and saved: \(imageURL)")
    }

    // MARK: - Profile Methods

    func refreshProfile() async throws {
        guard let userId = currentUser?.id else { return }

        // Preserve current profileImageURL in case backend doesn't return it
        let existingProfileImageURL = currentUser?.profileImageURL

        let apiUser = try await UserAPIService.shared.getProfile(userId: userId)
        let user = convertAPIUserToUser(apiUser)

        // Preserve profileImageURL if backend didn't return one (fallback)
        if user.profileImageURL == nil || user.profileImageURL?.isEmpty == true {
            if existingProfileImageURL != nil {
                user.profileImageURL = existingProfileImageURL
                print("⚠️ [AuthService] refreshProfile: Backend didn't return profileImageURL, preserved existing: '\(existingProfileImageURL ?? "nil")'")
            }
        }

        self.currentUser = user
        saveUser(user)
    }

    func updateProfile(displayName: String?, bio: String?, country: String?) async throws {
        guard let userId = currentUser?.id else { return }

        // Preserve current profileImageURL in case backend doesn't return it
        let existingProfileImageURL = currentUser?.profileImageURL

        let apiUser = try await UserAPIService.shared.updateProfile(
            userId: userId,
            displayName: displayName,
            bio: bio,
            country: country
        )

        let user = convertAPIUserToUser(apiUser)

        // Preserve profileImageURL if backend didn't return one
        if user.profileImageURL == nil || user.profileImageURL?.isEmpty == true {
            user.profileImageURL = existingProfileImageURL
            print("🔍 [AuthService] updateProfile: Preserved existing profileImageURL: '\(existingProfileImageURL ?? "nil")'")
        }

        self.currentUser = user
        saveUser(user)
    }

    func updateSocialLinks(twitter: String?, instagram: String?, linkedin: String?, website: String?) async throws {
        guard let userId = currentUser?.id else { return }

        // Preserve current profileImageURL in case backend doesn't return it
        let existingProfileImageURL = currentUser?.profileImageURL

        let apiUser = try await UserAPIService.shared.updateSocialLinks(
            userId: userId,
            twitter: twitter,
            instagram: instagram,
            linkedin: linkedin,
            website: website
        )

        let user = convertAPIUserToUser(apiUser)

        // Preserve profileImageURL if backend didn't return one
        if user.profileImageURL == nil || user.profileImageURL?.isEmpty == true {
            user.profileImageURL = existingProfileImageURL
            print("🔍 [AuthService] updateSocialLinks: Preserved existing profileImageURL: '\(existingProfileImageURL ?? "nil")'")
        }

        self.currentUser = user
        saveUser(user)
    }

    // MARK: - Persistence

    func saveUser(_ user: User) {
        UserDefaults.standard.set(user.id, forKey: userIdKey)

        let profileImageValue = user.profileImageURL ?? ""
        print("💾 [AuthService] saveUser - profileImageURL: '\(profileImageValue)'")

        let userData: [String: Any] = [
            "id": user.id,
            "username": user.username,
            "displayName": user.displayName,
            "email": user.email,
            "bio": user.bio ?? "",
            "profileImageURL": profileImageValue,
            "role": user.role.rawValue,
            "country": user.country ?? "",
            "followersCount": user.followersCount,
            "followingCount": user.followingCount,
            "votesReceived": user.votesReceived
        ]
        UserDefaults.standard.set(userData, forKey: userDataKey)

        // Force synchronize to ensure data is written immediately
        UserDefaults.standard.synchronize()
    }

    private func restoreUser() {
        guard let userData = UserDefaults.standard.dictionary(forKey: userDataKey),
              let id = userData["id"] as? String else {
            print("🔍 [AuthService] restoreUser: No saved user data found")
            return
        }

        let roleString = userData["role"] as? String ?? "regular"
        let role = parseRole(from: roleString)

        // Get profileImageURL and handle empty string as nil
        let rawProfileImageURL = userData["profileImageURL"] as? String
        let profileImageURL: String? = (rawProfileImageURL?.isEmpty == false) ? rawProfileImageURL : nil

        print("🔍 [AuthService] restoreUser: Restoring user - id: '\(id)', role: '\(roleString)', profileImageURL: '\(profileImageURL ?? "nil")', followersCount: \(userData["followersCount"] ?? 0), votesReceived: \(userData["votesReceived"] ?? 0)")

        let user = User(
            id: id,
            username: userData["username"] as? String ?? "",
            displayName: userData["displayName"] as? String ?? "",
            email: userData["email"] as? String ?? "",
            bio: userData["bio"] as? String,
            profileImageURL: profileImageURL,
            role: role,
            followersCount: userData["followersCount"] as? Int ?? 0,
            followingCount: userData["followingCount"] as? Int ?? 0,
            country: userData["country"] as? String,
            votesReceived: userData["votesReceived"] as? Int ?? 0
        )

        self.currentUser = user
    }

    private func clearSavedUser() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: userDataKey)
    }

    // MARK: - Helper Methods

    private func parseRole(from roleString: String) -> UserRole {
        switch roleString {
        case "genius": return .genius
        case "admin": return .admin
        case "superadmin": return .superadmin
        case "supporter": return .supporter
        default: return .regular
        }
    }

    private func convertAPIUserToUser(_ apiUser: APIUser) -> User {
        let role = parseRole(from: apiUser.role)

        return User(
            id: apiUser.userId,
            username: apiUser.username,
            displayName: apiUser.displayName,
            email: apiUser.email,
            bio: apiUser.bio,
            profileImageURL: apiUser.profileImageURL,
            role: role,
            followersCount: apiUser.followersCount ?? 0,
            followingCount: apiUser.followingCount ?? 0,
            country: apiUser.country,
            votesReceived: apiUser.votesReceived ?? 0
        )
    }

    func canCreatePost() -> Bool {
        return currentUser?.role.canCreatePosts ?? false
    }

    func canComment() -> Bool {
        return currentUser?.role.canComment ?? false
    }

    func canLike() -> Bool {
        return currentUser?.role.canLike ?? false
    }

    func canVote() -> Bool {
        return currentUser?.role.canVote ?? false
    }

    func canShare() -> Bool {
        return currentUser?.role.canShare ?? false
    }

    // MARK: - Genius Onboarding

    func completeGeniusOnboarding(data: GeniusOnboardingData) async throws {
        guard let userId = currentUser?.id else {
            throw APIError.custom("User not authenticated")
        }

        // Preserve current profileImageURL in case backend doesn't return it
        let existingProfileImageURL = currentUser?.profileImageURL

        // Update profile with onboarding data
        let apiUser = try await UserAPIService.shared.updateGeniusProfile(
            userId: userId,
            displayName: data.fullName,
            country: data.country,
            bio: data.biography,
            positionCategory: data.category?.rawValue,
            positionTitle: data.position?.title,
            manifestoShort: data.whyGenius,
            problemSolved: data.problemSolved,
            proofLinks: data.proofLinks,
            credentials: data.credentials,
            videoIntroURL: data.videoIntroURL
        )

        // Update local user
        let user = convertAPIUserToUser(apiUser)

        // Preserve profileImageURL if backend didn't return one
        if user.profileImageURL == nil || user.profileImageURL?.isEmpty == true {
            user.profileImageURL = existingProfileImageURL
            print("🔍 [AuthService] completeGeniusOnboarding: Preserved existing profileImageURL: '\(existingProfileImageURL ?? "nil")'")
        }

        self.currentUser = user
        saveUser(user)

        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "aga_genius_onboarding_\(userId)")
    }

    func resetOnboardingStatus() {
        guard let userId = currentUser?.id else { return }
        UserDefaults.standard.removeObject(forKey: "aga_genius_onboarding_\(userId)")
    }
}

