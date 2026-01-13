//
//  PostViewModel.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftData

@Observable
class PostViewModel {
    var content: String = ""
    var selectedImages: [String] = []
    var isPosting = false
    var errorMessage: String?
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Post Creation
    
    func createPost(by user: User) async throws {
        guard user.role.canCreatePosts else {
            throw PostError.unauthorizedUser
        }

        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PostError.emptyContent
        }

        isPosting = true
        errorMessage = nil

        do {
            // Create post via backend API
            let payload = CreatePostPayload(
                content: content,
                imageURLs: selectedImages.isEmpty ? nil : selectedImages,
                videoURL: nil,
                postType: selectedImages.isEmpty ? .text : .image
            )

            let success = try await HomeAPIService.shared.createPost(
                payload: payload,
                userId: user.id,
                userName: user.displayName,
                userPosition: user.bio ?? ""
            )

            if success {
                // Also save locally for offline support
                let post = Post(
                    content: content,
                    author: user,
                    imageURLs: selectedImages.isEmpty ? nil : selectedImages
                )
                modelContext.insert(post)
                try? modelContext.save()

                // Reset form
                content = ""
                selectedImages = []
            }
            isPosting = false
        } catch {
            isPosting = false
            errorMessage = "Failed to create post: \(error.localizedDescription)"
            throw error
        }
    }
    
    func addImage(_ imageURL: String) {
        selectedImages.append(imageURL)
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    func reset() {
        content = ""
        selectedImages = []
        errorMessage = nil
    }
}

// MARK: - Errors

enum PostError: LocalizedError {
    case unauthorizedUser
    case emptyContent
    
    var errorDescription: String? {
        switch self {
        case .unauthorizedUser:
            return "Only Geniuses can create posts"
        case .emptyContent:
            return "Post content cannot be empty"
        }
    }
}

