//
//  ModernPostCardView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI

struct ModernPostCardView: View {
    let post: Post
    let onLike: () -> Void
    let onComment: () -> Void
    let onVote: (VoteType) -> Void
    let onShare: () -> Void

    @State private var isLiked = false
    @State private var currentVote: VoteType?
    @State private var showComments = false
    @State private var animateHeart = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Full-width image (if any) - matching reference design
            if let imageURLs = post.imageURLs, !imageURLs.isEmpty {
                ZStack(alignment: .bottomLeading) {
                    // Main image with watermark
                    ZStack {
                        PostImageView(imageURL: imageURLs.first ?? "")
                            .frame(height: 450)  // Instagram-size height
                            .frame(maxWidth: .infinity)

                        // AGA Watermark
                        AGAWatermark(opacity: 0.15, fontSize: 24, color: .white)
                    }
                    .clipped()

                    // Gradient overlay
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)

                    // Title overlay
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.author?.displayName ?? "Unknown")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text(post.createdAt.timeAgoDisplay)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(16)
                }
            }

            // Content section with green background
            VStack(alignment: .leading, spacing: 16) {
                // Author Header (only if no image)
                if post.imageURLs == nil || post.imageURLs?.isEmpty == true {
                    HStack(spacing: 12) {
                        // Profile Image
                        if let imageURL = post.author?.profileImageURL, !imageURL.isEmpty {
                            Image(imageURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "fb923c"), Color(hex: "f59e0b")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Text(post.author?.initials ?? "?")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text(post.author?.displayName ?? "Unknown")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)

                                // Gold checkmark for admin posts
                                if post.shouldShowAdminBadge {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "FFD700"))
                                } else if post.author?.role == .genius {
                                    // Star for genius
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(hex: "f59e0b"))
                                }
                            }

                            Text(post.createdAt.timeAgoDisplay)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }

                        Spacer()
                    }
                }

                // Content
                Text(post.content)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.95))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Stats row (matching reference)
                HStack(spacing: 24) {
                    PostStatItem(icon: "person.2.fill", value: "\(post.author?.followersCount ?? 0)", label: "Followers")
                    PostStatItem(icon: "star.fill", value: "\(post.votesCount)", label: "Votes")
                    PostStatItem(icon: "heart.fill", value: "\(post.likesCount)", label: "Likes")
                }
                .padding(.top, 8)

                // Action Buttons (matching reference)
                HStack(spacing: 16) {
                    PostActionButton(icon: "square.and.arrow.up", label: "Share") {
                        onShare()
                    }

                    PostActionButton(icon: "link", label: "URL") {
                        // Copy URL
                    }

                    PostActionButton(
                        icon: isLiked ? "heart.fill" : "heart",
                        label: "Like",
                        isActive: isLiked
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isLiked.toggle()
                        }
                        onLike()
                    }

                    PostActionButton(icon: "bubble.right", label: "Comment") {
                        onComment()
                    }
                }
                .padding(.top, 8)
            }
            .padding(16)
            .background(Color(hex: "0a4d3c"))
        }
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Post Stat Item
struct PostStatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - Post Action Button
struct PostActionButton: View {
    let icon: String
    let label: String
    var isActive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isActive ? Color(hex: "f59e0b") : .white)

                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Supporting Views
struct StatLabel: View {
    let icon: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text("\(count)")
        }
        .foregroundColor(color)
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(DesignSystem.Typography.footnote)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            if let samplePost = createSamplePost() {
                ModernPostCardView(
                    post: samplePost,
                    onLike: {},
                    onComment: {},
                    onVote: { _ in },
                    onShare: {}
                )
            }
        }
        .padding()
        .background(DesignSystem.Colors.background)
    }
}

private func createSamplePost() -> Post? {
    let user = User(
        username: "einstein",
        displayName: "Albert Einstein",
        email: "albert@genius.com",
        role: .genius
    )

    return Post(
        content: "Just published my theory of relativity! E=mc² 🚀\n\nThis equation shows that energy and mass are interchangeable. It's a fundamental principle that will change how we understand the universe.",
        author: user,
        likesCount: 42,
        commentsCount: 15,
        votesCount: 38
    )
}

// MARK: - Post Image View
struct PostImageView: View {
    let imageURL: String
    @State private var loadedImage: UIImage?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if let loadedImage = loadedImage {
                // Display loaded remote image
                Image(uiImage: loadedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
            } else if isLoading {
                // Loading placeholder
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                )
            } else {
                // Error placeholder
                gradientForImage(imageURL)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        VStack(spacing: 16) {
                            Image(systemName: "photo")
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(.white)

                            Text("Image not available")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    )
            }
        }
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        // Construct full HTTPS URL
        var urlString = imageURL

        // If it's a relative path, prepend the base URL
        if urlString.starts(with: "/") {
            urlString = "https://africageniusalliance.com\(urlString)"
        }
        // If it starts with http://, convert to https://
        else if urlString.starts(with: "http://") {
            urlString = urlString.replacingOccurrences(of: "http://", with: "https://")
        }
        // If no protocol, assume it needs the base URL
        else if !urlString.starts(with: "https://") && !urlString.starts(with: "http://") {
            urlString = "https://africageniusalliance.com/\(urlString)"
        }

        print("📷 Loading image from: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            await MainActor.run {
                self.isLoading = false
            }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                print("✅ Successfully loaded image")
                await MainActor.run {
                    self.loadedImage = image
                    self.isLoading = false
                }
            } else {
                print("❌ Failed to decode image data")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        } catch {
            print("❌ Error loading image from \(urlString): \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    private func gradientForImage(_ name: String) -> LinearGradient {
        switch name {
        case "sample_universe":
            return LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "sample_stars":
            return LinearGradient(
                colors: [Color(hex: "2C3E50"), Color(hex: "4CA1AF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "sample_electricity":
            return LinearGradient(
                colors: [Color(hex: "F2994A"), Color(hex: "F2C94C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "sample_code":
            return LinearGradient(
                colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "sample_algorithm":
            return LinearGradient(
                colors: [Color(hex: "4776E6"), Color(hex: "8E54E9")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "sample_imagination":
            return LinearGradient(
                colors: [Color(hex: "FA709A"), Color(hex: "FEE140")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "sample_math":
            return LinearGradient(
                colors: [Color(hex: "30cfd0"), Color(hex: "330867")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return DesignSystem.Gradients.primary
        }
    }

    private func iconForImage(_ name: String) -> String {
        switch name {
        case "sample_universe": return "sparkles"
        case "sample_stars": return "star.fill"
        case "sample_electricity": return "bolt.fill"
        case "sample_code": return "chevron.left.forwardslash.chevron.right"
        case "sample_algorithm": return "function"
        case "sample_imagination": return "brain.head.profile"
        case "sample_math": return "x.squareroot"
        default: return "photo"
        }
    }

    private func titleForImage(_ name: String) -> String {
        switch name {
        case "sample_universe": return "The Universe"
        case "sample_stars": return "Stars"
        case "sample_electricity": return "Electricity"
        case "sample_code": return "Code"
        case "sample_algorithm": return "Algorithm"
        case "sample_imagination": return "Imagination"
        case "sample_math": return "Mathematics"
        default: return "Image"
        }
    }
}

