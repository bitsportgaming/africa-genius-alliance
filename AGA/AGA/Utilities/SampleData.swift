//
//  SampleData.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftData

@MainActor
class SampleData {
    static func createSampleData(in modelContext: ModelContext) {
        // Create sample users with real avatar images
        let genius1 = User(
            username: "nkosi_dlamini",
            displayName: "Nkosi Dlamini",
            email: "nkosi@aga.com",
            bio: "Bringing AI, solar and fiber to rural communities while creating 1M digital jobs.",
            profileImageURL: "avatar_male",
            role: .genius,
            followersCount: 8113,
            country: "South Africa",
            age: 32,
            votesReceived: 24580
        )

        let genius2 = User(
            username: "amina_mensah",
            displayName: "Amina Mensah",
            email: "amina@aga.com",
            bio: "Rewriting the curriculum to match the future, not the past — tech, trade and African history.",
            profileImageURL: "avatar_female",
            role: .genius,
            followersCount: 12007,
            country: "Ghana",
            age: 28,
            votesReceived: 31442
        )

        let genius3 = User(
            username: "leila_benali",
            displayName: "Leila Ben Ali",
            email: "leila@aga.com",
            bio: "Building the Pan-African high-speed rail network. Connecting our continent.",
            profileImageURL: "avatar_verified",
            role: .genius,
            followersCount: 6540,
            country: "Morocco",
            age: 35,
            votesReceived: 19340
        )

        let genius4 = User(
            username: "kwame_osei",
            displayName: "Kwame Osei",
            email: "kwame@aga.com",
            bio: "Renewable energy for every African village. Solar, wind, and hydro power for all.",
            profileImageURL: "avatar_youth",
            role: .genius,
            followersCount: 9234,
            country: "Kenya",
            age: 30,
            votesReceived: 22150
        )

        let regularUser1 = User(
            username: "john_doe",
            displayName: "John Doe",
            email: "john@aga.com",
            bio: "Enthusiastic learner and science lover 📚",
            profileImageURL: "avatar_male",
            role: .regular,
            country: "Nigeria",
            age: 25
        )

        let regularUser2 = User(
            username: "jane_smith",
            displayName: "Jane Smith",
            email: "jane@aga.com",
            bio: "Curious mind exploring the world of geniuses 🌟",
            profileImageURL: "avatar_female",
            role: .regular,
            country: "Egypt",
            age: 27
        )

        let regularUser3 = User(
            username: "alex_wonder",
            displayName: "Alex Wonder",
            email: "alex@aga.com",
            bio: "Always asking questions and seeking knowledge 🤔",
            profileImageURL: "avatar_neutral",
            role: .regular,
            country: "Tanzania",
            age: 23
        )

        // Additional geniuses for leaderboard - cycling through avatar images
        let genius5 = User(
            username: "zara_okonkwo",
            displayName: "Zara Okonkwo",
            email: "zara@aga.com",
            bio: "Building Africa's first quantum computing research center.",
            profileImageURL: "avatar_neutral",
            role: .genius,
            followersCount: 7890,
            country: "Nigeria",
            age: 29,
            votesReceived: 18750
        )

        let genius6 = User(
            username: "malik_hassan",
            displayName: "Malik Hassan",
            email: "malik@aga.com",
            bio: "Revolutionizing healthcare with AI diagnostics for rural Africa.",
            profileImageURL: "avatar_male",
            role: .genius,
            followersCount: 6234,
            country: "Egypt",
            age: 34,
            votesReceived: 16420
        )

        let genius7 = User(
            username: "fatima_diop",
            displayName: "Fatima Diop",
            email: "fatima@aga.com",
            bio: "Sustainable agriculture and food security champion.",
            profileImageURL: "avatar_female",
            role: .genius,
            followersCount: 5678,
            country: "Senegal",
            age: 31,
            votesReceived: 14890
        )

        let genius8 = User(
            username: "kofi_mensah",
            displayName: "Kofi Mensah",
            email: "kofi@aga.com",
            bio: "Fintech innovator bringing banking to the unbanked.",
            profileImageURL: "avatar_youth",
            role: .genius,
            followersCount: 8901,
            country: "Ghana",
            age: 27,
            votesReceived: 13560
        )

        let genius9 = User(
            username: "aisha_kamara",
            displayName: "Aisha Kamara",
            email: "aisha@aga.com",
            bio: "Clean water solutions for 10 million Africans.",
            profileImageURL: "avatar_verified",
            role: .genius,
            followersCount: 4567,
            country: "Sierra Leone",
            age: 33,
            votesReceived: 12340
        )

        let genius10 = User(
            username: "jabari_mwangi",
            displayName: "Jabari Mwangi",
            email: "jabari@aga.com",
            bio: "Wildlife conservation through blockchain technology.",
            profileImageURL: "avatar_neutral",
            role: .genius,
            followersCount: 5432,
            country: "Kenya",
            age: 30,
            votesReceived: 11220
        )

        modelContext.insert(genius1)
        modelContext.insert(genius2)
        modelContext.insert(genius3)
        modelContext.insert(genius4)
        modelContext.insert(genius5)
        modelContext.insert(genius6)
        modelContext.insert(genius7)
        modelContext.insert(genius8)
        modelContext.insert(genius9)
        modelContext.insert(genius10)
        modelContext.insert(regularUser1)
        modelContext.insert(regularUser2)
        modelContext.insert(regularUser3)
        
        // Create sample posts
        let post1 = Post(
            content: "Just published my theory of relativity! E=mc² 🚀\n\nThis equation shows that energy and mass are interchangeable. It's one of the most profound discoveries in physics!",
            author: genius1,
            likesCount: 142,
            commentsCount: 28,
            votesCount: 138
        )

        let post2 = Post(
            content: "Excited to share my latest research on radioactivity. Science is fascinating! 🔬\n\nWe've discovered two new elements: Polonium and Radium. The journey continues!",
            author: genius2,
            likesCount: 95,
            commentsCount: 18,
            votesCount: 87
        )

        let post3 = Post(
            content: "The important thing is not to stop questioning. Curiosity has its own reason for existing.\n\n✨ Never lose your sense of wonder about the universe.",
            author: genius1,
            imageURLs: ["sample_universe", "sample_stars"],
            likesCount: 256,
            commentsCount: 45,
            votesCount: 241
        )

        let post4 = Post(
            content: "Working on wireless energy transmission! ⚡\n\nImagine a world where electricity flows freely through the air. The future is closer than you think!",
            author: genius3,
            imageURLs: ["sample_electricity"],
            likesCount: 178,
            commentsCount: 32,
            votesCount: 165
        )

        let post5 = Post(
            content: "Just completed the first algorithm for the Analytical Engine! 💻\n\nThis machine could do so much more than just calculations. It could create art, music, and poetry through numbers!",
            author: genius4,
            imageURLs: ["sample_code", "sample_algorithm"],
            likesCount: 203,
            commentsCount: 41,
            votesCount: 189
        )

        let post6 = Post(
            content: "Nothing in life is to be feared, it is only to be understood. Now is the time to understand more, so that we may fear less. 💪",
            author: genius2,
            likesCount: 312,
            commentsCount: 56,
            votesCount: 298
        )

        let post7 = Post(
            content: "The present is theirs; the future, for which I really worked, is mine. ⚡✨",
            author: genius3,
            likesCount: 167,
            commentsCount: 23,
            votesCount: 154
        )

        let post8 = Post(
            content: "Imagination is more important than knowledge. Knowledge is limited. Imagination encircles the world. 🌍",
            author: genius1,
            imageURLs: ["sample_imagination"],
            likesCount: 421,
            commentsCount: 67,
            votesCount: 402
        )

        let post9 = Post(
            content: "Mathematical science shows what is. It is the language of unseen relations between things. 🔢✨",
            author: genius4,
            imageURLs: ["sample_math"],
            likesCount: 134,
            commentsCount: 19,
            votesCount: 126
        )

        let post10 = Post(
            content: "Be less curious about people and more curious about ideas. 💡\n\nIdeas shape our world and define our future!",
            author: genius2,
            likesCount: 189,
            commentsCount: 34,
            votesCount: 176
        )

        modelContext.insert(post1)
        modelContext.insert(post2)
        modelContext.insert(post3)
        modelContext.insert(post4)
        modelContext.insert(post5)
        modelContext.insert(post6)
        modelContext.insert(post7)
        modelContext.insert(post8)
        modelContext.insert(post9)
        modelContext.insert(post10)
        
        // Create sample comments
        let comment1 = Comment(
            content: "This is revolutionary! Thank you for sharing! 🙏",
            author: regularUser1,
            post: post1,
            likesCount: 15
        )

        let comment2 = Comment(
            content: "Amazing work! Can't wait to learn more about this.",
            author: regularUser2,
            post: post1,
            likesCount: 8
        )

        let comment3 = Comment(
            content: "Mind = blown 🤯 This changes everything!",
            author: regularUser3,
            post: post1,
            likesCount: 12
        )

        let comment4 = Comment(
            content: "Your research is inspiring! Keep pushing the boundaries! 🔬",
            author: regularUser1,
            post: post2,
            likesCount: 6
        )

        let comment5 = Comment(
            content: "This is exactly what I needed to hear today. Thank you! ✨",
            author: regularUser2,
            post: post3,
            likesCount: 23
        )

        let comment6 = Comment(
            content: "Words to live by! Curiosity is the key to everything 🔑",
            author: regularUser3,
            post: post3,
            likesCount: 18
        )

        let comment7 = Comment(
            content: "Wireless energy?! This sounds like science fiction! 😱",
            author: regularUser1,
            post: post4,
            likesCount: 11
        )

        let comment8 = Comment(
            content: "You're literally inventing the future! Can't wait to see this happen ⚡",
            author: regularUser2,
            post: post4,
            likesCount: 9
        )

        let comment9 = Comment(
            content: "The first programmer! You're a legend! 💻👑",
            author: regularUser3,
            post: post5,
            likesCount: 14
        )

        let comment10 = Comment(
            content: "Art through mathematics? That's beautiful! 🎨",
            author: regularUser1,
            post: post5,
            likesCount: 7
        )

        let comment11 = Comment(
            content: "Such powerful words! Understanding over fear 💪",
            author: regularUser2,
            post: post6,
            likesCount: 19
        )

        let comment12 = Comment(
            content: "This quote changed my perspective on life. Thank you! 🙏",
            author: regularUser3,
            post: post6,
            likesCount: 16
        )

        let comment13 = Comment(
            content: "The future is definitely yours! Your inventions are timeless ⚡",
            author: regularUser1,
            post: post7,
            likesCount: 10
        )

        let comment14 = Comment(
            content: "Imagination is everything! This resonates so much 🌟",
            author: regularUser2,
            post: post8,
            likesCount: 21
        )

        let comment15 = Comment(
            content: "Knowledge + Imagination = Genius! 🧠✨",
            author: regularUser3,
            post: post8,
            likesCount: 17
        )

        let comment16 = Comment(
            content: "Mathematics is truly the language of the universe 🔢",
            author: regularUser1,
            post: post9,
            likesCount: 8
        )

        let comment17 = Comment(
            content: "Ideas over gossip! Love this mindset 💡",
            author: regularUser2,
            post: post10,
            likesCount: 13
        )

        let comment18 = Comment(
            content: "This is the kind of wisdom we need more of! 🌟",
            author: regularUser3,
            post: post10,
            likesCount: 11
        )

        modelContext.insert(comment1)
        modelContext.insert(comment2)
        modelContext.insert(comment3)
        modelContext.insert(comment4)
        modelContext.insert(comment5)
        modelContext.insert(comment6)
        modelContext.insert(comment7)
        modelContext.insert(comment8)
        modelContext.insert(comment9)
        modelContext.insert(comment10)
        modelContext.insert(comment11)
        modelContext.insert(comment12)
        modelContext.insert(comment13)
        modelContext.insert(comment14)
        modelContext.insert(comment15)
        modelContext.insert(comment16)
        modelContext.insert(comment17)
        modelContext.insert(comment18)

        // Create election and proposal data
        let allUsers = [genius1, genius2, genius3, genius4, genius5, genius6, genius7, genius8, genius9, genius10, regularUser1, regularUser2, regularUser3]
        createElectionData(in: modelContext, users: allUsers)
        createProposalData(in: modelContext)

        // Save all changes
        do {
            try modelContext.save()
            print("✅ Sample data created successfully")
        } catch {
            print("❌ Failed to create sample data: \(error)")
        }
    }
    
    // Wrapper method for automatic loading
    static func loadAllSampleData(in modelContext: ModelContext) {
        createSampleData(in: modelContext)
    }

    static func clearAllData(in modelContext: ModelContext) {
        do {
            try modelContext.delete(model: User.self)
            try modelContext.delete(model: Post.self)
            try modelContext.delete(model: Comment.self)
            try modelContext.delete(model: Like.self)
            try modelContext.delete(model: Vote.self)
            try modelContext.save()
            print("✅ All data cleared successfully")
        } catch {
            print("❌ Failed to clear data: \(error)")
        }
    }

    static func createElectionData(in modelContext: ModelContext, users: [User]) {
        // Create election
        let election = Election(
            title: "Minister of Digital Economy • South Africa",
            position: "Minister of Digital Economy",
            country: "South Africa",
            electionDescription: "Your vote is recorded on-chain, publicly auditable, and cannot be altered by any government or political actor.",
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        )
        modelContext.insert(election)

        // Create candidates
        if let genius1 = users.first(where: { $0.username == "nkosi_dlamini" }) {
            let candidate1 = Candidate(
                userId: genius1.id,
                electionId: election.id,
                party: "Africa Genius Alliance",
                votesReceived: 24580
            )
            modelContext.insert(candidate1)
        }

        // Create a traditional party candidate
        let traditionalCandidate = User(
            username: "traditional_candidate",
            displayName: "Other Candidate",
            email: "other@traditional.com",
            bio: "Traditional party representative",
            role: .genius,
            country: "South Africa",
            age: 45,
            votesReceived: 19340
        )
        modelContext.insert(traditionalCandidate)

        let candidate2 = Candidate(
            userId: traditionalCandidate.id,
            electionId: election.id,
            party: "Traditional Party",
            votesReceived: 19340
        )
        modelContext.insert(candidate2)

        print("✅ Election data created")
    }

    static func createProposalData(in modelContext: ModelContext) {
        // Proposal 1
        let proposal1 = Proposal(
            title: "Expand Pan-African Train Feasibility Study",
            proposalDescription: "Fund comprehensive feasibility study for high-speed rail connecting major African cities.",
            closesAt: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            yesVotes: 680,
            noVotes: 320,
            quorumRequired: 50
        )
        modelContext.insert(proposal1)

        // Proposal 2
        let proposal2 = Proposal(
            title: "Fund 200 Youth Genius Fellowships",
            proposalDescription: "Provide full scholarships and mentorship for 200 young African leaders in STEM fields.",
            closesAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            yesVotes: 410,
            noVotes: 590,
            quorumRequired: 50
        )
        modelContext.insert(proposal2)

        print("✅ Proposal data created")
    }
}

