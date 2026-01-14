//
//  ModernCreatePostView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ModernCreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthService.self) private var authService

    @State private var viewModel: PostViewModel?
    @State private var content = ""
    @State private var showImagePicker = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isUploadingImages = false
    @FocusState private var isContentFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Light cream background for better visibility
                Color(hex: "f9fafb")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with emerald theme
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(hex: "064e3b").opacity(0.8))
                                .cornerRadius(12)
                        }

                        Spacer()

                        Text("Create Post")
                            .font(DesignSystem.Typography.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()

                        Button {
                            Task {
                                await createPost()
                            }
                        } label: {
                            Text("Post")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(content.isEmpty ? Color(hex: "9ca3af") : .white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    content.isEmpty ?
                                        Color(hex: "e5e7eb") :
                                        Color(hex: "f59e0b")
                                )
                                .cornerRadius(12)
                        }
                        .disabled(content.isEmpty)
                    }
                    .padding(AppConstants.padding)
                    .background(Color(hex: "0a4d3c"))
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Author Info
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(DesignSystem.Gradients.primary)
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Text(authService.currentUser?.displayName.prefix(1).uppercased() ?? "?")
                                            .font(DesignSystem.Typography.headline)
                                            .foregroundColor(.white)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(authService.currentUser?.displayName ?? "Unknown")
                                            .font(DesignSystem.Typography.headline)
                                            .foregroundColor(DesignSystem.Colors.textPrimary)

                                        Image(systemName: "star.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(DesignSystem.Colors.genius)
                                            .padding(4)
                                            .background(DesignSystem.Colors.geniusLight)
                                            .cornerRadius(6)
                                    }

                                    Text("Genius")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                }

                                Spacer()
                            }
                            .padding(.horizontal, AppConstants.padding)
                            .padding(.top, AppConstants.padding)

                            // Content Editor with white background card
                            VStack(alignment: .leading, spacing: 12) {
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $content)
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(Color(hex: "1f2937"))
                                        .frame(minHeight: 180)
                                        .focused($isContentFocused)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                        .padding(12)

                                    if content.isEmpty {
                                        Text("Share your genius thoughts...")
                                            .font(DesignSystem.Typography.body)
                                            .foregroundColor(Color(hex: "9ca3af"))
                                            .padding(.top, 20)
                                            .padding(.leading, 16)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "e5e7eb"), lineWidth: 1)
                                )

                                HStack {
                                    Spacer()
                                    Text("\(content.count)/\(AppConstants.maxPostLength)")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(
                                            content.count > AppConstants.maxPostLength ?
                                            DesignSystem.Colors.error : DesignSystem.Colors.textTertiary
                                        )
                                }
                            }
                            .padding(.horizontal, AppConstants.padding)

                            // Image Preview (if any)
                            if !selectedImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(selectedImages.indices, id: \.self) { index in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: selectedImages[index])
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 120, height: 120)
                                                    .cornerRadius(AppConstants.smallCornerRadius)
                                                    .clipped()

                                                Button {
                                                    selectedImages.remove(at: index)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(.white)
                                                        .shadow(radius: 2)
                                                }
                                                .padding(4)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, AppConstants.padding)
                                }
                            }

                            Spacer()
                        }
                    }

                    // Bottom Toolbar
                    HStack(spacing: 20) {
                        PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 4, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                Text(selectedImages.isEmpty ? "Add Photo" : "\(selectedImages.count) selected")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(DesignSystem.Colors.primary)
                        }

                        if isUploadingImages {
                            ProgressView()
                                .scaleEffect(0.8)
                        }

                        Spacer()
                    }
                    .padding(AppConstants.padding)
                    .background(DesignSystem.Colors.adaptiveSurface)
                }
            }
        }
        .onChange(of: selectedPhotos) { _, newValue in
            Task {
                await loadImages(from: newValue)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = PostViewModel(modelContext: modelContext)
            }
            isContentFocused = true
        }
    }

    private func loadImages(from items: [PhotosPickerItem]) async {
        selectedImages = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImages.append(image)
            }
        }
    }

    private func createPost() async {
        guard let user = authService.currentUser else { return }

        do {
            isUploadingImages = true

            // Apply watermark to all images before uploading
            let watermarkedImages = selectedImages.compactMap { $0.withWatermark() }

            // Create post with watermarked media
            _ = try await PostAPIService.shared.createPostWithMedia(
                authorId: user.id,
                authorName: user.displayName,
                authorPosition: user.bio ?? "",
                content: content,
                images: watermarkedImages
            )

            isUploadingImages = false
            dismiss()
        } catch {
            isUploadingImages = false
            print("Error creating post: \(error)")
        }
    }
}

#Preview {
    ModernCreatePostView()
        .modelContainer(for: [Post.self, User.self])
        .environment(AuthService.shared)
}

