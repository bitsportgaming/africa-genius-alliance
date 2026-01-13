//
//  HomeAPIService.swift
//  AGA
//
//  Created by AGA Team on 12/30/25.
//

import Foundation

// MARK: - API Response Types
struct StatsAPIResponse: Codable {
    let success: Bool
    let data: StatsData?
    let error: String?

    struct StatsData: Codable {
        let profile: ProfileData
        let topGeniuses: [APITrendingGenius]
    }

    struct ProfileData: Codable {
        let userId: String
        let displayName: String
        let positionCategory: String
        let positionTitle: String
        let manifestoShort: String
        let isVerified: Bool
        let rank: Int
        let votesTotal: Int
        let followersTotal: Int
        let profileViews: Int
        let stats24h: Stats24hData
    }

    struct Stats24hData: Codable {
        let votesDelta: Int
        let followersDelta: Int
        let rankDelta: Int
        let profileViewsDelta: Int
    }

    struct APITrendingGenius: Codable {
        let id: String
        let name: String
        let positionTitle: String
        let country: String
        let avatarURL: String?
        let isVerified: Bool
        let rank: Int
        let votes: Int
    }
}

// MARK: - Home API Service
@MainActor
class HomeAPIService {
    static let shared = HomeAPIService()
    private let baseURL = Config.apiBaseURL

    private init() {}

    // MARK: - Genius Home Data
    func getHomeGenius(userId: String) async throws -> GeniusHomeData {
        guard !userId.isEmpty else {
            return getDefaultGeniusHomeData(userId: userId)
        }

        guard let url = URL(string: "\(baseURL)/users/\(userId)/stats") else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                // Return default data if user not found
                return getDefaultGeniusHomeData(userId: userId)
            }

            let result = try JSONDecoder().decode(StatsAPIResponse.self, from: data)

            if result.success, let statsData = result.data {
                let profile = GeniusProfile(
                    userId: statsData.profile.userId,
                    positionCategory: statsData.profile.positionCategory,
                    positionTitle: statsData.profile.positionTitle,
                    manifestoShort: statsData.profile.manifestoShort,
                    verifiedStatus: statsData.profile.isVerified ? .verified : .unverified,
                    rank: statsData.profile.rank,
                    votesTotal: statsData.profile.votesTotal,
                    followersTotal: statsData.profile.followersTotal,
                    likesTotal: 0,
                    donationsTotal: 0,
                    liveStatus: .offline,
                    stats24h: Stats24h(
                        votesDelta: statsData.profile.stats24h.votesDelta,
                        followersDelta: statsData.profile.stats24h.followersDelta,
                        rankDelta: statsData.profile.stats24h.rankDelta,
                        profileViewsDelta: statsData.profile.stats24h.profileViewsDelta
                    ),
                    lastPostDate: nil,
                    weeklyVotes: []
                )

                let topGeniuses = statsData.topGeniuses.map { g in
                    TrendingGenius(
                        id: g.id,
                        name: g.name,
                        positionTitle: g.positionTitle,
                        country: g.country,
                        avatarURL: g.avatarURL,
                        isVerified: g.isVerified,
                        rank: g.rank,
                        votes: g.votes
                    )
                }

                // Generate dynamic alerts based on real data
                let alerts = generateAlerts(profile: profile)

                return GeniusHomeData(
                    profile: profile,
                    alerts: alerts,
                    topGeniuses: topGeniuses
                )
            } else {
                return getDefaultGeniusHomeData(userId: userId)
            }
        } catch {
            print("Error fetching stats: \(error)")
            return getDefaultGeniusHomeData(userId: userId)
        }
    }

    // MARK: - Generate Dynamic Alerts
    private func generateAlerts(profile: GeniusProfile) -> [AlertItem] {
        var alerts: [AlertItem] = []

        // Alert if gaining votes
        if profile.stats24h.votesDelta > 0 {
            alerts.append(AlertItem(
                icon: "arrow.up.circle.fill",
                message: "You gained \(profile.stats24h.votesDelta) votes in the last 24h!",
                actionLabel: "View",
                destination: "analytics",
                priority: 1
            ))
        }

        // Alert if gaining followers
        if profile.stats24h.followersDelta > 0 {
            alerts.append(AlertItem(
                icon: "person.badge.plus.fill",
                message: "\(profile.stats24h.followersDelta) new followers today",
                actionLabel: "View",
                destination: "analytics",
                priority: 2
            ))
        }

        // Encourage posting if no recent activity
        if profile.votesTotal == 0 {
            alerts.append(AlertItem(
                icon: "pencil.circle.fill",
                message: "Start your campaign! Create your first post",
                actionLabel: "Post",
                destination: "post",
                priority: 1
            ))
        }

        // Verification reminder
        if profile.verifiedStatus == .unverified {
            alerts.append(AlertItem(
                icon: "checkmark.seal.fill",
                message: "Get verified to increase your visibility",
                actionLabel: "Verify",
                destination: "settings",
                priority: 2
            ))
        }

        // Profile views alert
        if profile.stats24h.profileViewsDelta > 10 {
            alerts.append(AlertItem(
                icon: "eye.fill",
                message: "\(profile.stats24h.profileViewsDelta) people viewed your profile",
                actionLabel: "View",
                destination: "analytics",
                priority: 2
            ))
        }

        return alerts
    }

    // MARK: - Default Data (for new users or errors)
    private func getDefaultGeniusHomeData(userId: String) -> GeniusHomeData {
        return GeniusHomeData(
            profile: GeniusProfile(
                userId: userId,
                positionCategory: "",
                positionTitle: "Genius Candidate",
                manifestoShort: "",
                verifiedStatus: .unverified,
                rank: 0,
                votesTotal: 0,
                followersTotal: 0,
                likesTotal: 0,
                donationsTotal: 0,
                liveStatus: .offline,
                stats24h: Stats24h(votesDelta: 0, followersDelta: 0, rankDelta: 0, profileViewsDelta: 0),
                lastPostDate: nil,
                weeklyVotes: []
            ),
            alerts: [
                AlertItem(icon: "pencil.circle.fill", message: "Create your first post to start your campaign", actionLabel: "Post", destination: "post", priority: 1),
                AlertItem(icon: "person.crop.circle.badge.plus", message: "Complete your profile to attract supporters", actionLabel: "Edit", destination: "settings", priority: 2)
            ],
            topGeniuses: []
        )
    }

    // MARK: - Supporter Home Data
    func getHomeSupporter(userId: String) async throws -> SupporterHomeData {
        guard !userId.isEmpty else {
            return getDefaultSupporterHomeData()
        }

        guard let url = URL(string: "\(baseURL)/users/\(userId)/stats") else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return getDefaultSupporterHomeData()
            }

            // Decode the response
            struct SupporterStatsResponse: Codable {
                let success: Bool
                let data: SupporterStatsData?

                struct SupporterStatsData: Codable {
                    let topGeniuses: [StatsAPIResponse.APITrendingGenius]
                    let supporterStats: SupporterStatsInfo
                }

                struct SupporterStatsInfo: Codable {
                    let votesCast: Int
                    let followsTotal: Int
                    let donationsTotal: Double
                }
            }

            let result = try JSONDecoder().decode(SupporterStatsResponse.self, from: data)

            if result.success, let statsData = result.data {
                let stats = SupporterStats(
                    votesCastTotal: statsData.supporterStats.votesCast,
                    followsTotal: statsData.supporterStats.followsTotal,
                    donationsTotal: statsData.supporterStats.donationsTotal
                )

                let trendingGeniuses = statsData.topGeniuses.map { g in
                    TrendingGenius(
                        id: g.id,
                        name: g.name,
                        positionTitle: g.positionTitle,
                        country: g.country,
                        avatarURL: g.avatarURL,
                        isVerified: g.isVerified,
                        rank: g.rank,
                        votes: g.votes
                    )
                }

                return SupporterHomeData(
                    stats: stats,
                    trendingGeniuses: trendingGeniuses,
                    categories: getCategories(),
                    feedPosts: []
                )
            } else {
                return getDefaultSupporterHomeData()
            }
        } catch {
            print("Error fetching supporter stats: \(error)")
            return getDefaultSupporterHomeData()
        }
    }

    private func getDefaultSupporterHomeData() -> SupporterHomeData {
        return SupporterHomeData(
            stats: SupporterStats(votesCastTotal: 0, followsTotal: 0, donationsTotal: 0),
            trendingGeniuses: [],
            categories: getCategories(),
            feedPosts: []
        )
    }

    // MARK: - Trending Geniuses
    func getTrendingGeniuses() async throws -> [TrendingGenius] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return getMockTrendingGeniuses()
    }

    // MARK: - Feed Posts
    func getFeedPosts(userId: String, role: UserRole) async throws -> [FeedPost] {
        guard let url = URL(string: "\(baseURL)/posts") else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return getMockFeedPosts()
            }

            struct PostsResponse: Codable {
                let success: Bool
                let data: [APIPost]?

                struct APIPost: Codable {
                    let _id: String
                    let authorId: String
                    let authorName: String
                    let authorAvatar: String?
                    let authorPosition: String?
                    let content: String
                    let mediaURLs: [String]?
                    let mediaType: String?
                    let postType: String?
                    let likesCount: Int
                    let commentsCount: Int
                    let sharesCount: Int
                    let likedBy: [String]?
                    let createdAt: String
                }
            }

            let result = try JSONDecoder().decode(PostsResponse.self, from: data)

            if result.success, let posts = result.data {
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                return posts.map { post in
                    let postType: FeedPost.PostType
                    switch post.postType {
                    case "image": postType = .image
                    case "video": postType = .video
                    case "liveAnnouncement": postType = .liveAnnouncement
                    default: postType = .text
                    }

                    let createdAt = dateFormatter.date(from: post.createdAt) ?? Date()
                    let isLiked = post.likedBy?.contains(userId) ?? false
                    let imageURL = post.mediaURLs?.first

                    // Debug logging
                    print("📝 Post: \(post.authorName) - mediaURLs: \(post.mediaURLs ?? []) - imageURL: \(imageURL ?? "nil")")

                    return FeedPost(
                        id: post._id,
                        authorId: post.authorId,
                        authorName: post.authorName,
                        authorAvatar: post.authorAvatar,
                        authorPosition: post.authorPosition ?? "",
                        content: post.content,
                        imageURL: imageURL,
                        postType: postType,
                        likesCount: post.likesCount,
                        commentsCount: post.commentsCount,
                        sharesCount: post.sharesCount,
                        createdAt: createdAt,
                        isLiked: isLiked,
                        isFollowing: false
                    )
                }
            } else {
                return getMockFeedPosts()
            }
        } catch {
            print("Error fetching posts: \(error)")
            return getMockFeedPosts()
        }
    }

    // MARK: - Create Post
    func createPost(payload: CreatePostPayload, userId: String, userName: String, userPosition: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/posts") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let postTypeString: String
        switch payload.postType {
        case .text: postTypeString = "text"
        case .image: postTypeString = "image"
        case .video: postTypeString = "video"
        case .liveAnnouncement: postTypeString = "liveAnnouncement"
        }

        var body: [String: Any] = [
            "authorId": userId,
            "authorName": userName,
            "authorPosition": userPosition,
            "content": payload.content,
            "postType": postTypeString
        ]

        if let imageURLs = payload.imageURLs, !imageURLs.isEmpty {
            body["mediaURLs"] = imageURLs
            body["mediaType"] = "image"
        }

        if let videoURL = payload.videoURL {
            body["mediaURLs"] = [videoURL]
            body["mediaType"] = "video"
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            struct ErrorResponse: Codable {
                let error: String?
            }
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.custom(errorResponse.error ?? "Failed to create post")
            }
            throw APIError.custom("Failed to create post")
        }

        return true
    }

    // MARK: - Live Functions
    func startLive(userId: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 300_000_000)
        return true
    }

    func stopLive(userId: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 200_000_000)
        return true
    }

    // MARK: - Social Actions
    func followGenius(userId: String, geniusId: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/users/\(geniusId)/follow") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["followerId": userId])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }

        struct FollowResponse: Codable {
            let success: Bool
            let following: Bool
        }

        let result = try JSONDecoder().decode(FollowResponse.self, from: data)
        return result.following
    }

    func unfollowGenius(userId: String, geniusId: String) async throws -> Bool {
        // Uses the same endpoint - it toggles
        return try await followGenius(userId: userId, geniusId: geniusId)
    }

    func getFollowedGeniuses(userId: String) async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/users/\(userId)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return []
        }

        struct UserResponse: Codable {
            let success: Bool
            let data: UserData?

            struct UserData: Codable {
                let following: [String]?
            }
        }

        let result = try JSONDecoder().decode(UserResponse.self, from: data)
        return result.data?.following ?? []
    }

    func vote(giverUserId: String, geniusId: String, positionId: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/users/\(geniusId)/vote") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["voterId": giverUserId])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }

        struct VoteResponse: Codable {
            let success: Bool
        }

        let result = try JSONDecoder().decode(VoteResponse.self, from: data)
        return result.success
    }

    func donate(giverUserId: String, geniusId: String, amount: Double, method: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 500_000_000)
        return true
    }

    func likePost(userId: String, postId: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 150_000_000)
        return true
    }

    func commentOnPost(userId: String, postId: String, content: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 300_000_000)
        return true
    }

    func sharePost(userId: String, postId: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 150_000_000)
        return true
    }

    // MARK: - Private Mock Data Helpers
    private func getMockTopGeniuses() -> [TrendingGenius] {
        return [
            TrendingGenius(id: "1", name: "Amina Mensah", positionTitle: "Minister of Education", country: "Ghana", avatarURL: "profile_amina", isVerified: true, rank: 1, votes: 31442),
            TrendingGenius(id: "2", name: "Nkosi Dlamini", positionTitle: "Minister of Digital Economy", country: "South Africa", avatarURL: "profile_nkosi", isVerified: true, rank: 2, votes: 24580),
            TrendingGenius(id: "3", name: "Leila Ben Ali", positionTitle: "Minister of Transport", country: "Morocco", avatarURL: "profile_leila", isVerified: true, rank: 3, votes: 19340),
            TrendingGenius(id: "4", name: "Kofi Asante", positionTitle: "Minister of Trade", country: "Ghana", avatarURL: "profile_kofi", isVerified: false, rank: 4, votes: 15890),
            TrendingGenius(id: "5", name: "Fatima Diallo", positionTitle: "Minister of Health", country: "Senegal", avatarURL: "profile_fatima", isVerified: true, rank: 5, votes: 14200)
        ]
    }

    private func getMockTrendingGeniuses() -> [TrendingGenius] {
        return getMockTopGeniuses()
    }

    private func getCategories() -> [CategoryItem] {
        return [
            CategoryItem(name: "Education", icon: "book.fill", color: "10b981"),
            CategoryItem(name: "Health", icon: "heart.fill", color: "ef4444"),
            CategoryItem(name: "Infrastructure", icon: "building.2.fill", color: "3b82f6"),
            CategoryItem(name: "Trade", icon: "cart.fill", color: "f59e0b"),
            CategoryItem(name: "Security", icon: "shield.fill", color: "6366f1"),
            CategoryItem(name: "Tech", icon: "cpu.fill", color: "8b5cf6")
        ]
    }

    private func getMockFeedPosts() -> [FeedPost] {
        return [
            FeedPost(id: "1", authorId: "1", authorName: "Amina Mensah", authorAvatar: "profile_amina", authorPosition: "Minister of Education", content: "Education is the key to Africa's future. Today I visited 3 rural schools and saw the incredible potential of our youth. We must invest in digital literacy now! 📚💡", imageURL: nil, postType: .text, likesCount: 234, commentsCount: 45, sharesCount: 12, createdAt: Date().addingTimeInterval(-3600), isLiked: false, isFollowing: true),
            FeedPost(id: "2", authorId: "2", authorName: "Nkosi Dlamini", authorAvatar: "profile_nkosi", authorPosition: "Minister of Digital Economy", content: "Announcing our new fiber optic initiative that will connect 50 rural communities by 2025. This is just the beginning! 🌍🔌", imageURL: "sample_electricity", postType: .image, likesCount: 567, commentsCount: 89, sharesCount: 34, createdAt: Date().addingTimeInterval(-7200), isLiked: true, isFollowing: true),
            FeedPost(id: "3", authorId: "3", authorName: "Leila Ben Ali", authorAvatar: "profile_leila", authorPosition: "Minister of Transport", content: "The Pan-African rail network isn't just about trains—it's about connecting our people, our markets, and our dreams. 🚂🌍", imageURL: nil, postType: .text, likesCount: 189, commentsCount: 23, sharesCount: 8, createdAt: Date().addingTimeInterval(-14400), isLiked: false, isFollowing: false)
        ]
    }
}

// MARK: - Data Transfer Objects

struct GeniusHomeData {
    var profile: GeniusProfile
    var alerts: [AlertItem]
    var topGeniuses: [TrendingGenius]
}

struct SupporterHomeData {
    var stats: SupporterStats
    var trendingGeniuses: [TrendingGenius]
    var categories: [CategoryItem]
    var feedPosts: [FeedPost]
}

struct TrendingGenius: Identifiable {
    var id: String
    var name: String
    var positionTitle: String
    var country: String
    var avatarURL: String?
    var isVerified: Bool
    var rank: Int
    var votes: Int

    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

struct FeedPost: Identifiable {
    var id: String
    var authorId: String
    var authorName: String
    var authorAvatar: String?
    var authorPosition: String
    var content: String
    var imageURL: String?
    var postType: PostType
    var likesCount: Int
    var commentsCount: Int
    var sharesCount: Int
    var createdAt: Date
    var isLiked: Bool
    var isFollowing: Bool

    enum PostType: String, Codable {
        case text
        case image
        case video
        case liveAnnouncement
    }
}

struct CreatePostPayload {
    var content: String
    var imageURLs: [String]?
    var videoURL: String?
    var postType: FeedPost.PostType
}

