//
//  FollowManager.swift
//  AGA
//
//  Centralized follow state management for real-time updates across the app
//

import Foundation
import SwiftUI
import Combine

/// Centralized manager for follow state across the entire app
/// Uses @Observable for SwiftUI integration and real-time updates
@Observable
final class FollowManager {
    static let shared = FollowManager()
    
    // MARK: - State
    private(set) var followedGeniusIds: Set<String> = []
    private(set) var isLoading: Set<String> = [] // Track loading state per genius
    
    private init() {
        // Load cached followed geniuses on init
        loadCachedFollows()
    }
    
    // MARK: - Public Methods
    
    /// Check if user is following a genius
    func isFollowing(_ geniusId: String) -> Bool {
        followedGeniusIds.contains(geniusId)
    }
    
    /// Check if a follow action is in progress for a genius
    func isLoadingFollow(_ geniusId: String) -> Bool {
        isLoading.contains(geniusId)
    }
    
    /// Toggle follow state for a genius
    @MainActor
    func toggleFollow(userId: String, geniusId: String) async -> Bool {
        guard !isLoading.contains(geniusId) else { return false }
        
        isLoading.insert(geniusId)
        HapticFeedback.impact(.medium)
        
        let wasFollowing = followedGeniusIds.contains(geniusId)
        
        do {
            let success: Bool
            if wasFollowing {
                success = try await HomeAPIService.shared.unfollowGenius(userId: userId, geniusId: geniusId)
            } else {
                success = try await HomeAPIService.shared.followGenius(userId: userId, geniusId: geniusId)
            }
            
            if success {
                if wasFollowing {
                    followedGeniusIds.remove(geniusId)
                } else {
                    followedGeniusIds.insert(geniusId)
                    HapticFeedback.notification(.success)
                }
                saveCachedFollows()
            }
            
            isLoading.remove(geniusId)
            return success
        } catch {
            print("Error toggling follow for genius \(geniusId): \(error)")
            HapticFeedback.notification(.error)
            isLoading.remove(geniusId)
            return false
        }
    }
    
    /// Follow a genius (explicit follow action)
    @MainActor
    func follow(userId: String, geniusId: String) async -> Bool {
        guard !followedGeniusIds.contains(geniusId) else { return true }
        return await toggleFollow(userId: userId, geniusId: geniusId)
    }
    
    /// Unfollow a genius (explicit unfollow action)
    @MainActor
    func unfollow(userId: String, geniusId: String) async -> Bool {
        guard followedGeniusIds.contains(geniusId) else { return true }
        return await toggleFollow(userId: userId, geniusId: geniusId)
    }
    
    /// Load user's followed geniuses from API
    @MainActor
    func loadFollowedGeniuses(userId: String) async {
        do {
            let geniusIds = try await HomeAPIService.shared.getFollowedGeniuses(userId: userId)
            followedGeniusIds = Set(geniusIds)
            saveCachedFollows()
        } catch {
            print("Error loading followed geniuses: \(error)")
        }
    }
    
    /// Set followed geniuses directly (for initial load from home data)
    @MainActor
    func setFollowedGeniuses(_ ids: [String]) {
        followedGeniusIds = Set(ids)
        saveCachedFollows()
    }
    
    // MARK: - Persistence
    
    private func loadCachedFollows() {
        if let cached = UserDefaults.standard.array(forKey: "followed_geniuses") as? [String] {
            followedGeniusIds = Set(cached)
        }
    }
    
    private func saveCachedFollows() {
        UserDefaults.standard.set(Array(followedGeniusIds), forKey: "followed_geniuses")
    }
    
    /// Clear all follow data (for logout)
    @MainActor
    func clearAll() {
        followedGeniusIds.removeAll()
        isLoading.removeAll()
        UserDefaults.standard.removeObject(forKey: "followed_geniuses")
    }
}

