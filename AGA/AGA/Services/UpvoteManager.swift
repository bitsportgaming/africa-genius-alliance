//
//  UpvoteManager.swift
//  AGA
//
//  Centralized upvote state management for real-time updates across the app
//  Tracks which geniuses a user has upvoted during the current session
//

import Foundation
import SwiftUI
import Combine

/// Result type for upvote operations
enum UpvoteResult {
    case success(Int)  // New vote count
    case alreadyUpvoted
    case error(String) // Error message
}

/// Centralized manager for upvote state across the entire app
/// Uses @Observable for SwiftUI integration and real-time updates
@Observable
final class UpvoteManager {
    static let shared = UpvoteManager()

    // MARK: - State
    private(set) var upvotedGeniusIds: Set<String> = []
    private(set) var isLoading: Set<String> = [] // Track loading state per genius
    private(set) var voteCounts: [String: Int] = [:] // Track updated vote counts per genius
    private(set) var lastError: String? = nil // Last error message for display

    private init() {
        // Load cached upvotes on init
        loadCachedUpvotes()
    }

    // MARK: - Public Methods

    /// Check if user has upvoted a genius
    func hasUpvoted(_ geniusId: String) -> Bool {
        upvotedGeniusIds.contains(geniusId)
    }

    /// Check if an upvote action is in progress for a genius
    func isLoadingUpvote(_ geniusId: String) -> Bool {
        isLoading.contains(geniusId)
    }

    /// Get the current vote count for a genius (returns cached count or nil if not available)
    func getVoteCount(_ geniusId: String) -> Int? {
        voteCounts[geniusId]
    }

    /// Upvote a genius (one-time action - cannot be undone in session)
    /// Returns the new vote count on success, or nil on failure
    @MainActor
    func upvote(userId: String, geniusId: String) async -> Int? {
        let result = await upvoteWithResult(userId: userId, geniusId: geniusId)
        switch result {
        case .success(let count):
            return count
        case .alreadyUpvoted, .error:
            return nil
        }
    }

    /// Upvote a genius with detailed result including error messages
    @MainActor
    func upvoteWithResult(userId: String, geniusId: String) async -> UpvoteResult {
        // Clear previous error
        lastError = nil

        // Don't allow upvoting if already upvoted or loading
        guard !upvotedGeniusIds.contains(geniusId) else {
            return .alreadyUpvoted
        }

        guard !isLoading.contains(geniusId) else {
            return .error("Upvote already in progress")
        }

        isLoading.insert(geniusId)
        HapticFeedback.impact(.medium)

        do {
            let newVoteCount = try await HomeAPIService.shared.upvoteGenius(
                giverUserId: userId,
                geniusId: geniusId,
                positionId: "general"
            )

            if let count = newVoteCount {
                upvotedGeniusIds.insert(geniusId)
                voteCounts[geniusId] = count
                HapticFeedback.notification(.success)
                saveCachedUpvotes()
                isLoading.remove(geniusId)
                return .success(count)
            }

            isLoading.remove(geniusId)
            lastError = "Failed to upvote"
            return .error("Failed to upvote")
        } catch {
            let errorMessage = error.localizedDescription
            print("Error upvoting genius \(geniusId): \(errorMessage)")
            HapticFeedback.notification(.error)
            isLoading.remove(geniusId)
            lastError = errorMessage
            return .error(errorMessage)
        }
    }
    
    /// Mark a genius as upvoted (for when upvote was done elsewhere)
    @MainActor
    func markAsUpvoted(_ geniusId: String) {
        upvotedGeniusIds.insert(geniusId)
        saveCachedUpvotes()
    }
    
    /// Set upvoted geniuses directly (for initial load)
    @MainActor
    func setUpvotedGeniuses(_ ids: [String]) {
        upvotedGeniusIds = Set(ids)
        saveCachedUpvotes()
    }
    
    // MARK: - Persistence
    
    private func loadCachedUpvotes() {
        if let cached = UserDefaults.standard.array(forKey: "upvoted_geniuses") as? [String] {
            upvotedGeniusIds = Set(cached)
        }
    }
    
    private func saveCachedUpvotes() {
        UserDefaults.standard.set(Array(upvotedGeniusIds), forKey: "upvoted_geniuses")
    }
    
    /// Clear all upvote data (for logout)
    @MainActor
    func clearAll() {
        upvotedGeniusIds.removeAll()
        isLoading.removeAll()
        UserDefaults.standard.removeObject(forKey: "upvoted_geniuses")
    }
}

