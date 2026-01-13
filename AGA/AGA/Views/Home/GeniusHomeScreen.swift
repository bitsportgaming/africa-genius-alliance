//
//  GeniusHomeScreen.swift
//  AGA
//
//  Created by AGA Team on 12/30/25.
//

import SwiftUI

struct GeniusHomeScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var homeData: GeniusHomeData?
    @State private var isLoading = true
    @State private var showCreatePost = false
    @State private var showGoLive = false
    @State private var showAnalytics = false
    @State private var showInbox = false
    @State private var showCampaign = false
    @State private var showSettings = false
    @State private var isLive = false
    @State private var showGeniusDetail: TrendingGenius?
    @State private var showVoteSuccess = false
    @State private var votedGeniusName: String = ""
    @State private var showProfile = false

    private var followManager: FollowManager { FollowManager.shared }

    private var userName: String {
        authViewModel.currentUser?.fullName ?? "Genius"
    }

    private var userInitials: String {
        let components = userName.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(userName.prefix(2)).uppercased()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "f9fafb").ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                } else {
                    ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Top Bar
                        HomeTopBar(
                            greeting: "Hello, \(userName.split(separator: " ").first ?? "Genius")",
                            subtitle: homeData?.profile.positionTitle,
                            avatarURL: authViewModel.currentUser?.profileImageURL,
                            initials: userInitials,
                            onNotificationTap: {
                                HapticFeedback.impact(.light)
                                showInbox = true
                            },
                            onAvatarTap: {
                                HapticFeedback.impact(.light)
                                showProfile = true
                            }
                        )

                        VStack(spacing: 20) {
                            // Impact Snapshot
                            impactSnapshotSection

                            // Command Center
                            commandCenterSection

                            // Alerts & Opportunities
                            if let alerts = homeData?.alerts, !alerts.isEmpty {
                                alertsSection(alerts: alerts)
                            }

                            // Leaderboard Preview
                            if let topGeniuses = homeData?.topGeniuses, !topGeniuses.isEmpty {
                                leaderboardSection(geniuses: topGeniuses)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                    }
                }
            }
            .task {
                await loadData()
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostSheet()
            }
            .fullScreenCover(isPresented: $showGoLive) {
                GoLiveSheet(
                    isLive: $isLive,
                    userId: authViewModel.currentUser?.id ?? "",
                    userName: authViewModel.currentUser?.fullName ?? "Genius",
                    userPosition: homeData?.profile.positionTitle
                )
            }
            .sheet(isPresented: $showAnalytics) {
                AnalyticsSheet(userId: authViewModel.currentUser?.id ?? "")
            }
            .sheet(isPresented: $showInbox) {
                InboxSheet(userId: authViewModel.currentUser?.id ?? "")
            }
            .sheet(isPresented: $showProfile) {
                NavigationStack {
                    ProfileView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") { showProfile = false }
                            }
                        }
                }
            }
            .sheet(isPresented: $showCampaign) {
                CampaignSheet(userId: authViewModel.currentUser?.id ?? "")
            }
            .sheet(isPresented: $showSettings) {
                GeniusSettingsSheet(userId: authViewModel.currentUser?.id ?? "")
            }
            .sheet(item: $showGeniusDetail) { genius in
                GeniusDetailSheet(genius: genius, userId: authViewModel.currentUser?.id ?? "")
            }
            .alert("Vote Submitted!", isPresented: $showVoteSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your vote for \(votedGeniusName) has been recorded. Thank you for supporting!")
            }
        }
    }

    // MARK: - Impact Snapshot Section
    private var impactSnapshotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📊 Impact Snapshot")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1f2937"))
                Spacer()
                Text("Last 24h")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6b7280"))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HomeStatCard(
                    label: "Total Votes",
                    value: formatNumber(homeData?.profile.votesTotal ?? 0),
                    delta: homeData?.profile.stats24h.votesDelta,
                    icon: "hand.thumbsup.fill",
                    color: Color(hex: "f59e0b")
                )

                HomeStatCard(
                    label: "Followers",
                    value: formatNumber(homeData?.profile.followersTotal ?? 0),
                    delta: homeData?.profile.stats24h.followersDelta,
                    icon: "person.2.fill",
                    color: Color(hex: "10b981")
                )

                HomeStatCard(
                    label: "Rank",
                    value: "#\(homeData?.profile.rank ?? 0)",
                    delta: homeData?.profile.stats24h.rankDelta,
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color(hex: "3b82f6")
                )

                HomeStatCard(
                    label: "Profile Views",
                    value: formatNumber(homeData?.profile.stats24h.profileViewsDelta ?? 0),
                    delta: nil,
                    icon: "eye.fill",
                    color: Color(hex: "8b5cf6")
                )
            }
        }
        .padding(16)
        .background(Color(hex: "f3f4f6"))
        .cornerRadius(16)
    }

    // MARK: - Command Center Section
    private var commandCenterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎯 Command Center")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ActionCard(title: "Post", icon: "square.and.pencil", color: Color(hex: "10b981")) {
                    showCreatePost = true
                }

                ActionCard(title: isLive ? "Live Now" : "Go Live", icon: isLive ? "dot.radiowaves.left.and.right" : "video.fill", color: Color(hex: "ef4444")) {
                    showGoLive = true
                }

                ActionCard(title: "Analytics", icon: "chart.bar.fill", color: Color(hex: "3b82f6")) {
                    showAnalytics = true
                }

                ActionCard(title: "Inbox", icon: "envelope.fill", color: Color(hex: "8b5cf6")) {
                    showInbox = true
                }

                ActionCard(title: "Campaign", icon: "megaphone.fill", color: Color(hex: "f59e0b")) {
                    showCampaign = true
                }

                ActionCard(title: "Settings", icon: "gearshape.fill", color: Color(hex: "6b7280")) {
                    showSettings = true
                }
            }
        }
    }

    // MARK: - Alerts Section
    private func alertsSection(alerts: [AlertItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🔔 Alerts & Opportunities")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1f2937"))
                Spacer()
                Text("\(alerts.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "ef4444"))
                    .cornerRadius(10)
            }

            VStack(spacing: 8) {
                ForEach(alerts.prefix(3)) { alert in
                    AlertRow(alert: alert) {
                        handleAlertTap(alert)
                    }
                }
            }
        }
    }

    // MARK: - Leaderboard Section
    private func leaderboardSection(geniuses: [TrendingGenius]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🏆 Leaderboard")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1f2937"))
                Spacer()
                NavigationLink(destination: LeaderboardFullView(geniuses: geniuses)) {
                    Text("See All")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "10b981"))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(geniuses) { genius in
                        GeniusCardSmall(
                            genius: genius,
                            onTap: { showGeniusDetail = genius },
                            onFollow: { followGenius(genius) },
                            onVote: { voteForGenius(genius) }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Follow/Vote Actions
    private func followGenius(_ genius: TrendingGenius) {
        let userId = authViewModel.currentUser?.id ?? ""
        Task {
            await followManager.toggleFollow(userId: userId, geniusId: genius.id)
        }
    }

    private func voteForGenius(_ genius: TrendingGenius) {
        HapticFeedback.impact(.medium)

        Task {
            do {
                let userId = authViewModel.currentUser?.id ?? ""
                let success = try await HomeAPIService.shared.vote(
                    giverUserId: userId,
                    geniusId: genius.id,
                    positionId: "general"
                )

                if success {
                    await MainActor.run {
                        votedGeniusName = genius.name
                        showVoteSuccess = true
                        HapticFeedback.notification(.success)
                    }
                }
            } catch {
                print("Error voting for genius: \(error)")
                await MainActor.run {
                    HapticFeedback.notification(.error)
                }
            }
        }
    }

    private func handleAlertTap(_ alert: AlertItem) {
        HapticFeedback.impact(.light)

        // Handle different alert destinations
        switch alert.destination {
        case "analytics":
            showAnalytics = true
        case "inbox", "messages", "notifications":
            showInbox = true
        case "campaign", "campaigns":
            showCampaign = true
        case "post", "create_post":
            showCreatePost = true
        case "live", "go_live":
            showGoLive = true
        case "settings":
            showSettings = true
        default:
            // For any unhandled destination, show a brief feedback
            print("Navigating to: \(alert.destination)")
        }
    }

    // MARK: - Helper Functions
    private func loadData() async {
        isLoading = true
        do {
            let userId = authViewModel.currentUser?.id ?? ""
            homeData = try await HomeAPIService.shared.getHomeGenius(userId: userId)
        } catch {
            print("Error loading genius home data: \(error)")
        }
        isLoading = false
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1000000 {
            return String(format: "%.1fM", Double(number) / 1000000)
        } else if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000)
        }
        return "\(number)"
    }
}

// MARK: - Create Post Sheet
struct CreatePostSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthService.self) private var authService

    @State private var postContent = ""
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideoURL: URL? = nil
    @State private var isPosting = false
    @State private var showImagePicker = false
    @State private var showVideoPicker = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        textInputSection
                        mediaPreviewSection
                        mediaButtonsSection
                        characterCountSection

                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    .padding(16)
                }
                postButtonSection
            }
            .background(Color.white)
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(hex: "6b7280"))
                }
            }
            .sheet(isPresented: $showImagePicker) {
                PhotoPicker(selectedImages: $selectedImages, maxSelection: 5)
            }
            .sheet(isPresented: $showVideoPicker) {
                VideoPicker(selectedVideoURL: $selectedVideoURL)
            }
        }
    }

    // MARK: - Text Input Section
    private var textInputSection: some View {
        ZStack(alignment: .topLeading) {
            if postContent.isEmpty {
                Text("What's on your mind? Share updates with your supporters...")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "9ca3af"))
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
            }

            TextEditor(text: $postContent)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "1f2937")) // Dark text for visibility
                .frame(minHeight: 150)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
        }
        .background(Color.white) // White background for better contrast
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "d1d5db"), lineWidth: 1.5)
        )
    }

    // MARK: - Media Preview Section
    @ViewBuilder
    private var mediaPreviewSection: some View {
        if !selectedImages.isEmpty || selectedVideoURL != nil {
            MediaPreviewGrid(images: $selectedImages, videoURL: $selectedVideoURL)
        }
    }

    // MARK: - Media Buttons Section
    private var mediaButtonsSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                selectedVideoURL = nil  // Clear video if selecting images
                showImagePicker = true
            }) {
                Label("Photo (\(selectedImages.count)/5)", systemImage: "photo")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "10b981"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: "10b981").opacity(0.1))
                    .cornerRadius(20)
            }
            .disabled(selectedImages.count >= 5)

            Button(action: {
                selectedImages.removeAll()  // Clear images if selecting video
                showVideoPicker = true
            }) {
                Label("Video", systemImage: "video")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(selectedVideoURL != nil ? .white : Color(hex: "3b82f6"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(selectedVideoURL != nil ? Color(hex: "3b82f6") : Color(hex: "3b82f6").opacity(0.1))
                    .cornerRadius(20)
            }

            Spacer()
        }
    }

    // MARK: - Character Count Section
    private var characterCountSection: some View {
        HStack {
            Spacer()
            Text("\(postContent.count)/500")
                .font(.system(size: 12))
                .foregroundColor(postContent.count > 500 ? Color(hex: "ef4444") : Color(hex: "9ca3af"))
        }
    }

    // MARK: - Post Button Section
    private var postButtonSection: some View {
        VStack(spacing: 0) {
            Divider()

            Button(action: createPost) {
                HStack {
                    if isPosting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "paperplane.fill")
                        Text("Post")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Group {
                        if canPost {
                            DesignSystem.Gradients.primary
                        } else {
                            LinearGradient(colors: [Color(hex: "d1d5db")], startPoint: .leading, endPoint: .trailing)
                        }
                    }
                )
                .cornerRadius(12)
            }
            .disabled(!canPost || isPosting)
            .padding(16)
        }
        .background(Color.white)
    }

    private var canPost: Bool {
        !postContent.isEmpty && postContent.count <= 500
    }

    private func createPost() {
        guard !postContent.isEmpty else { return }
        guard let user = authService.currentUser else {
            errorMessage = "You must be logged in to post"
            return
        }

        isPosting = true
        errorMessage = nil

        Task {
            do {
                // Use the real backend API
                _ = try await PostAPIService.shared.createPost(
                    authorId: user.id,
                    authorName: user.displayName,
                    authorAvatar: user.profileImageURL,
                    authorPosition: user.role == .genius ? "Genius Candidate" : nil,
                    content: postContent,
                    images: selectedImages.isEmpty ? nil : selectedImages,
                    videoURL: selectedVideoURL
                )

                await MainActor.run {
                    isPosting = false
                    dismiss()
                }
            } catch {
                print("Error creating post: \(error)")
                await MainActor.run {
                    isPosting = false
                    errorMessage = "Failed to create post: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Go Live Sheet
struct GoLiveSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isLive: Bool
    let userId: String
    let userName: String
    let userPosition: String?

    @State private var liveTitle = ""
    @State private var liveDescription = ""
    @State private var isStarting = false
    @State private var showCamera = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var viewerCount = 0
    @State private var likesCount = 0
    @State private var currentStreamId: String?
    @State private var viewerPollingTimer: Timer?

    var body: some View {
        NavigationView {
            ZStack {
                if isLive {
                    // Live View
                    liveStreamView
                } else {
                    // Pre-Live Setup
                    preLiveSetupView
                }
            }
            .background(Color(hex: "0f172a").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if isLive {
                            endLive()
                        } else {
                            dismiss()
                        }
                    }) {
                        Text(isLive ? "End" : "Cancel")
                            .foregroundColor(isLive ? Color(hex: "ef4444") : .white)
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            viewerPollingTimer?.invalidate()
        }
    }

    // MARK: - Pre-Live Setup View
    private var preLiveSetupView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Camera Preview (Real)
            CameraPreviewView()
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)

            // Live Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Live Title")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "94a3b8"))

                TextField("What are you going live about?", text: $liveTitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(14)
                    .background(Color(hex: "1e293b"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)

            // Live Description Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Description (Optional)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "94a3b8"))

                TextField("Add a brief description...", text: $liveDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(14)
                    .background(Color(hex: "1e293b"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)

            Spacer()

            // Go Live Button
            Button(action: startLive) {
                HStack(spacing: 10) {
                    if isStarting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "video.fill")
                        Text("Go Live")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    liveTitle.isEmpty
                        ? Color(hex: "475569")
                        : Color(hex: "ef4444")
                )
                .cornerRadius(16)
            }
            .disabled(liveTitle.isEmpty || isStarting)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Live Stream View
    private var liveStreamView: some View {
        ZStack {
            // Live Camera Feed
            CameraPreviewView()
                .ignoresSafeArea()

            VStack {
                // Top Bar
                HStack {
                    // Live Badge
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
                    .background(Color(hex: "ef4444").opacity(0.3))
                    .cornerRadius(20)

                    // Timer
                    Text(formatElapsedTime(elapsedTime))
                        .font(.system(size: 14, weight: .medium).monospacedDigit())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)

                    Spacer()

                    // Viewer Count
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 12))
                        Text("\(viewerCount)")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Title Overlay
                VStack(alignment: .leading, spacing: 4) {
                    Text(liveTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    if !liveDescription.isEmpty {
                        Text(liveDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Bottom Controls
                HStack(spacing: 24) {
                    // Flip Camera
                    Button(action: {}) {
                        VStack(spacing: 4) {
                            Image(systemName: "camera.rotate.fill")
                                .font(.system(size: 24))
                            Text("Flip")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.white)
                    }

                    // Mute
                    Button(action: {}) {
                        VStack(spacing: 4) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 24))
                            Text("Mute")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.white)
                    }

                    // End Live Button
                    Button(action: endLive) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "ef4444"))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            Text("End")
                                .font(.system(size: 11))
                                .foregroundColor(.white)
                        }
                    }

                    // Effects
                    Button(action: {}) {
                        VStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 24))
                            Text("Effects")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.white)
                    }

                    // Share
                    Button(action: {}) {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                            Text("Share")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Helper Functions
    private func startLive() {
        isStarting = true

        Task {
            do {
                let stream = try await LiveStreamService.shared.startStream(
                    hostId: userId,
                    hostName: userName,
                    hostAvatar: nil,
                    hostPosition: userPosition,
                    title: liveTitle,
                    description: liveDescription.isEmpty ? nil : liveDescription
                )

                await MainActor.run {
                    currentStreamId = stream.id
                    isStarting = false
                    isLive = true
                    viewerCount = stream.viewerCount
                    likesCount = stream.likesCount
                    startTimer()
                    startViewerPolling()
                }
            } catch {
                print("Error starting live: \(error)")
                await MainActor.run {
                    isStarting = false
                }
            }
        }
    }

    private func endLive() {
        timer?.invalidate()
        viewerPollingTimer?.invalidate()

        Task {
            do {
                if let streamId = currentStreamId {
                    _ = try await LiveStreamService.shared.stopStream(streamId: streamId)
                }
                await MainActor.run {
                    isLive = false
                    currentStreamId = nil
                    dismiss()
                }
            } catch {
                print("Error ending live: \(error)")
                await MainActor.run {
                    isLive = false
                    dismiss()
                }
            }
        }
    }

    private func startTimer() {
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    private func startViewerPolling() {
        viewerPollingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [self] _ in
            Task { @MainActor in
                guard let streamId = currentStreamId else { return }
                if let stream = try? await LiveStreamService.shared.getStream(id: streamId) {
                    viewerCount = stream.viewerCount
                    likesCount = stream.likesCount
                }
            }
        }
    }

    private func formatElapsedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Leaderboard Full View
struct LeaderboardFullView: View {
    let geniuses: [TrendingGenius]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(geniuses.enumerated()), id: \.element.id) { index, genius in
                    TrendingGeniusRow(genius: genius, rank: index + 1)
                }
            }
            .padding(16)
        }
        .background(Color(hex: "f9fafb").ignoresSafeArea())
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Trending Genius Row
struct TrendingGeniusRow: View {
    let genius: TrendingGenius
    let rank: Int

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(rank)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(rankColor)
                .frame(width: 36)

            // Avatar
            ZStack {
                Circle()
                    .fill(DesignSystem.Gradients.genius)
                    .frame(width: 48, height: 48)
                Text(genius.initials)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(genius.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))
                    if genius.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "10b981"))
                    }
                }
                Text(genius.positionTitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6b7280"))
            }

            Spacer()

            // Votes
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(genius.votes.formatted())")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "1f2937"))
                Text("votes")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }

    private var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "f59e0b") // Gold
        case 2: return Color(hex: "9ca3af") // Silver
        case 3: return Color(hex: "cd7f32") // Bronze
        default: return Color(hex: "6b7280")
        }
    }
}

#Preview {
    GeniusHomeScreen()
        .environmentObject(AuthViewModel())
}

