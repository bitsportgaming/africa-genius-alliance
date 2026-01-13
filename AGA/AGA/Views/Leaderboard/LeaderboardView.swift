//
//  LeaderboardView.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI
import SwiftData

struct LeaderboardView: View {
    @Query(sort: \User.votesReceived, order: .reverse) private var users: [User]
    @State private var selectedFilter = "Top 100"
    
    private let filters = ["Top 100", "By Country", "By Position", "Rising Stars"]
    
    private var geniuses: [User] {
        users.filter { $0.role == .genius }.prefix(100).map { $0 }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            DesignSystem.Gradients.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    AGAHeader()
                        .padding(.top, 8)
                    
                    // Title
                    Text("Continental Leaderboard")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textBright)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(filters, id: \.self) { filter in
                                AGAChip(text: filter, isSelected: selectedFilter == filter) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    // Leaderboard list
                    VStack(spacing: 8) {
                        ForEach(Array(geniuses.enumerated()), id: \.element.id) { index, genius in
                            LeaderboardRow(rank: index + 1, user: genius)
                        }
                    }
                    
                    // Bottom hint
                    Text("Rankings are computed on-chain using votes, support, reputation and verified impact.")
                        .font(.system(size: 11))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let rank: Int
    let user: User
    
    private var scoreGrade: String {
        switch rank {
        case 1: return "AAA"
        case 2: return "AA+"
        case 3: return "AA"
        case 4...10: return "A+"
        case 11...25: return "A"
        case 26...50: return "B+"
        default: return "B"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(rank <= 3 ? DesignSystem.Colors.accent : DesignSystem.Colors.textTertiary)
                .frame(width: 32)
            
            // Leader info
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textBright)
                
                Text("\(user.country ?? "Unknown") • Education • \(user.votesReceived) votes")
                    .font(.system(size: 11))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            Spacer()
            
            // Score
            Text(scoreGrade)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DesignSystem.Colors.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(DesignSystem.Colors.primarySoft)
                .cornerRadius(6)
        }
        .padding(10)
        .background(Color(hex: "0f172a").opacity(0.6))
        .cornerRadius(AppConstants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                .stroke(Color(hex: "94a3b8").opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    LeaderboardView()
        .modelContainer(for: [User.self])
}

