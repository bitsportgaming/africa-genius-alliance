//
//  NationalProjectsView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

struct NationalProjectsView: View {
    @Environment(AuthService.self) private var authService

    @State private var projects: [ProjectRecord] = []
    @State private var isLoading = true
    @State private var selectedProject: ProjectRecord? = nil
    @State private var totalFunded: Double = 0
    @State private var totalGoal: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a4d3c").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header Stats
                    statsHeader

                    // Content
                    if isLoading {
                        loadingView
                    } else if projects.isEmpty {
                        emptyStateView
                    } else {
                        projectsList
                    }
                }
            }
            .navigationTitle("National Projects")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadProjects()
            }
            .sheet(item: $selectedProject) { project in
                ProjectDetailView(project: project)
                    .environment(authService)
            }
        }
    }

    // MARK: - Stats Header
    private var statsHeader: some View {
        VStack(spacing: 16) {
            // Total Progress
            VStack(spacing: 8) {
                Text("NATIONAL FUNDING PROGRESS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "f59e0b"))
                    .tracking(1)

                HStack(alignment: .bottom, spacing: 8) {
                    Text("$\(formatNumber(totalFunded))")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("of $\(formatNumber(totalGoal))")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 4)
                }

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.2))

                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "f59e0b"))
                            .frame(width: geo.size.width * min(totalFunded / max(totalGoal, 1), 1))
                    }
                }
                .frame(height: 12)

                Text("\(projects.count) Active National Projects")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func formatNumber(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.0fK", value / 1_000)
        }
        return String(format: "%.0f", value)
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color(hex: "f59e0b"))
            Text("Loading projects...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "flag.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
            Text("No national projects")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text("Check back later for new initiatives")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Projects List
    private var projectsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(projects) { project in
                    NationalProjectCard(project: project) {
                        selectedProject = project
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Load Projects
    private func loadProjects() async {
        isLoading = true

        do {
            projects = try await ProjectAPIService.shared.getNationalProjects()
            totalFunded = projects.reduce(0) { $0 + $1.fundingRaised }
            totalGoal = projects.reduce(0) { $0 + $1.fundingGoal }
        } catch {
            print("Error loading national projects: \(error)")
        }

        isLoading = false
    }
}

// MARK: - National Project Card
struct NationalProjectCard: View {
    let project: ProjectRecord
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                // Header with flag
                HStack {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)

                    Text("NATIONAL PROJECT")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                        .tracking(1)

                    Spacer()

                    Text(project.category.capitalized)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "f59e0b"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "f59e0b").opacity(0.2))
                        .cornerRadius(6)
                }

                // Title
                Text(project.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                // Description
                Text(project.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)

                // Funding Progress
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.2))

                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "f59e0b"), Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * project.fundingProgress)
                        }
                    }
                    .frame(height: 10)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("$\(Int(project.fundingRaised))")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)

                            Text("raised of $\(Int(project.fundingGoal))")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(project.fundingPercentage)%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))

                            Text("funded")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }

                // Stats Row
                HStack(spacing: 20) {
                    Label("\(project.supportersCount) supporters", systemImage: "person.2.fill")
                    Label("\(project.votesCount) votes", systemImage: "hand.thumbsup.fill")
                }
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))

                // Fund Button
                Button(action: onTap) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("Fund This Project")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "f59e0b"))
                    )
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NationalProjectsView()
        .environment(AuthService.shared)
}
