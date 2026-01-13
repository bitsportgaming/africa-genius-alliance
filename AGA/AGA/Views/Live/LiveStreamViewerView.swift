//
//  LiveStreamViewerView.swift
//  AGA
//
//  Viewer experience for watching live streams
//
//  Created by AGA Team on 01/01/26.
//

import SwiftUI

struct LiveStreamViewerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthService.self) private var authService
    
    let stream: APILiveStream
    
    @State private var currentStream: APILiveStream
    @State private var isLiked: Bool = false
    @State private var showComments = false
    @State private var pollingTimer: Timer?
    
    private var currentUserId: String {
        authService.currentUser?.id ?? "viewer"
    }
    
    init(stream: APILiveStream) {
        self.stream = stream
        _currentStream = State(initialValue: stream)
        _isLiked = State(initialValue: stream.isLikedBy(userId: ""))
    }
    
    var body: some View {
        ZStack {
            // Video placeholder
            Color(hex: "0f172a")
                .ignoresSafeArea()
            
            VStack {
                // Top bar
                topBar
                
                Spacer()
                
                // Host info overlay
                hostInfoOverlay
                
                // Bottom controls
                bottomControls
            }
        }
        .onAppear { joinStream() }
        .onDisappear { leaveStream() }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // Live badge
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: "ef4444"))
                    .frame(width: 8, height: 8)
                Text("LIVE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.5))
            .clipShape(Capsule())
            
            // Viewers
            HStack(spacing: 4) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 12))
                Text("\(currentStream.viewerCount)")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.5))
            .clipShape(Capsule())
            
            Spacer()
            
            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Host Info
    private var hostInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "10b981"), Color(hex: "059669")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(initials(from: currentStream.hostName))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentStream.hostName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    if let position = currentStream.hostPosition, !position.isEmpty {
                        Text(position)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
            }
            
            Text(currentStream.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding(16)
        .background(
            LinearGradient(colors: [Color.clear, Color.black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        )
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        HStack(spacing: 24) {
            // Like
            Button(action: toggleLike) {
                VStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundColor(isLiked ? Color(hex: "ef4444") : .white)
                    Text("\(currentStream.likesCount)")
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                }
            }
            
            // Comments
            Button(action: { showComments = true }) {
                VStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text("\(currentStream.commentsCount)")
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    // MARK: - Helper Functions
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private func joinStream() {
        isLiked = currentStream.isLikedBy(userId: currentUserId)

        Task {
            do {
                let updated = try await LiveStreamService.shared.joinStream(
                    streamId: stream.id,
                    userId: currentUserId
                )
                await MainActor.run {
                    currentStream = updated
                    startPolling()
                }
            } catch {
                print("Error joining stream: \(error)")
                startPolling()
            }
        }
    }

    private func leaveStream() {
        pollingTimer?.invalidate()

        Task {
            try? await LiveStreamService.shared.leaveStream(
                streamId: stream.id,
                userId: currentUserId
            )
        }
    }

    private func startPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            Task {
                if let updated = try? await LiveStreamService.shared.getStream(id: stream.id) {
                    if updated.status != "live" {
                        await MainActor.run { dismiss() }
                    } else {
                        await MainActor.run { currentStream = updated }
                    }
                }
            }
        }
    }

    private func toggleLike() {
        Task {
            do {
                let result = try await LiveStreamService.shared.likeStream(
                    streamId: stream.id,
                    userId: currentUserId
                )
                await MainActor.run {
                    currentStream = result.stream
                    isLiked = result.liked
                }
            } catch {
                print("Error toggling like: \(error)")
            }
        }
    }
}

