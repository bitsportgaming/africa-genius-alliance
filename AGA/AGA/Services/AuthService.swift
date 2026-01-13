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

    // Track if genius has completed onboarding
    var needsGeniusOnboarding: Bool {
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

        // Convert API response to local User model
        let user = convertAPIUserToUser(apiUser)

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
    }

    func updateUserRole(to role: UserRole) {
        currentUser?.role = role
        if let user = currentUser {
            saveUser(user)
        }
    }

    // MARK: - Profile Methods

    func refreshProfile() async throws {
        guard let userId = currentUser?.id else { return }

        let apiUser = try await UserAPIService.shared.getProfile(userId: userId)
        let user = convertAPIUserToUser(apiUser)

        self.currentUser = user
        saveUser(user)
    }

    func updateProfile(displayName: String?, bio: String?, country: String?) async throws {
        guard let userId = currentUser?.id else { return }

        let apiUser = try await UserAPIService.shared.updateProfile(
            userId: userId,
            displayName: displayName,
            bio: bio,
            country: country
        )

        let user = convertAPIUserToUser(apiUser)
        self.currentUser = user
        saveUser(user)
    }

    // MARK: - Persistence

    func saveUser(_ user: User) {
        UserDefaults.standard.set(user.id, forKey: userIdKey)

        let userData: [String: Any] = [
            "id": user.id,
            "username": user.username,
            "displayName": user.displayName,
            "email": user.email,
            "bio": user.bio ?? "",
            "profileImageURL": user.profileImageURL ?? "",
            "role": user.role.rawValue,
            "country": user.country ?? "",
            "followersCount": user.followersCount,
            "followingCount": user.followingCount,
            "votesReceived": user.votesReceived
        ]
        UserDefaults.standard.set(userData, forKey: userDataKey)
    }

    private func restoreUser() {
        guard let userData = UserDefaults.standard.dictionary(forKey: userDataKey),
              let id = userData["id"] as? String else {
            return
        }

        let roleString = userData["role"] as? String ?? "regular"
        let role = parseRole(from: roleString)

        let user = User(
            id: id,
            username: userData["username"] as? String ?? "",
            displayName: userData["displayName"] as? String ?? "",
            email: userData["email"] as? String ?? "",
            bio: userData["bio"] as? String,
            profileImageURL: userData["profileImageURL"] as? String,
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

