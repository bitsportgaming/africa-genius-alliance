//
//  ProjectDetailView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

struct ProjectDetailView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    let project: ProjectRecord

    @State private var showDonation = false
    @State private var hasVoted = false
    @State private var isVoting = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a4d3c").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header Image Placeholder
                        headerImage

                        // Project Info
                        projectInfo

                        // Funding Progress
                        fundingSection

                        // Action Buttons
                        actionButtons

                        // Description
                        descriptionSection

                        // Creator Info
                        creatorSection
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(project.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .sheet(isPresented: $showDonation) {
            DonationFlowView(
                recipientId: project.projectId,
                recipientName: project.title,
                recipientType: "project",
                recipientImage: project.imageURL
            )
        }
    }

    // MARK: - Header Image
    private var headerImage: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "f59e0b").opacity(0.3), Color(hex: "0a4d3c")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 180)
            .overlay(
                VStack {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: "f59e0b"))

                    if project.isNationalProject {
                        HStack(spacing: 6) {
                            Image(systemName: "flag.fill")
                            Text("National Project")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(20)
                        .padding(.top, 8)
                    }
                }
            )
    }

    private var categoryIcon: String {
        switch project.category.lowercased() {
        case "technology": return "cpu"
        case "education": return "book.fill"
        case "health": return "heart.fill"
        case "trade": return "chart.line.uptrend.xyaxis"
        case "environment": return "leaf.fill"
        case "governance": return "building.columns.fill"
        case "arts": return "paintpalette.fill"
        case "agriculture": return "tree.fill"
        default: return "star.fill"
        }
    }

    // MARK: - Project Info
    private var projectInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.category.capitalized)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(hex: "f59e0b").opacity(0.2))
                .cornerRadius(8)

            Text(project.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 16) {
                Label("\(project.votesCount) votes", systemImage: "hand.thumbsup.fill")
                Label("\(project.supportersCount) supporters", systemImage: "person.2.fill")
            }
            .font(.system(size: 13))
            .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Funding Section
    private var fundingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FUNDING PROGRESS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.2))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "f59e0b"))
                        .frame(width: geo.size.width * project.fundingProgress)
                }
            }
            .frame(height: 12)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("$\(Int(project.fundingRaised))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("raised of $\(Int(project.fundingGoal))")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                Text("\(project.fundingPercentage)%")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "f59e0b"))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Vote Button
            Button(action: { Task { await voteForProject() } }) {
                HStack(spacing: 8) {
                    if isVoting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: hasVoted ? "checkmark" : "hand.thumbsup.fill")
                    }
                    Text(hasVoted ? "Voted" : "Vote")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(hasVoted ? .white : Color(hex: "0a4d3c"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(hasVoted ? Color.green : Color.white)
                )
            }
            .disabled(hasVoted || isVoting)

            // Fund Button
            Button(action: { showDonation = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                    Text("Fund")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "f59e0b"))
                )
            }
        }
    }

    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ABOUT THIS PROJECT")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            Text(project.description)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }

    // MARK: - Creator Section
    private var creatorSection: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "f59e0b").opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(project.creatorName.prefix(1)))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "f59e0b"))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Created by")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))

                Text(project.creatorName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            Button(action: {}) {
                Text("View Profile")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "f59e0b"))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }

    // MARK: - Vote Action
    private func voteForProject() async {
        guard let userId = authService.currentUser?.id else { return }

        isVoting = true

        do {
            _ = try await VotingAPIService.shared.voteForProject(
                voterId: userId,
                projectId: project.projectId
            )

            await MainActor.run {
                hasVoted = true
                HapticFeedback.notification(.success)
            }
        } catch {
            print("Vote error: \(error)")
            HapticFeedback.notification(.error)
        }

        isVoting = false
    }
}

#Preview {
    ProjectDetailView(project: ProjectRecord(
        id: "1",
        projectId: "test123",
        title: "Clean Water Initiative",
        description: "Bringing clean water to rural communities across Ghana through sustainable well construction and water purification systems.",
        category: "environment",
        creatorId: "user1",
        creatorName: "Kwame Asante",
        fundingGoal: 50000,
        fundingRaised: 32500,
        currency: "USD",
        status: "active",
        imageURL: nil,
        votesCount: 245,
        supportersCount: 89,
        isNationalProject: true,
        createdAt: "2025-12-01"
    ))
    .environment(AuthService.shared)
}
