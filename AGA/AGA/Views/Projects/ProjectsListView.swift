//
//  ProjectsListView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

struct ProjectsListView: View {
    @Environment(AuthService.self) private var authService
    @State private var projects: [ProjectRecord] = []
    @State private var isLoading = true
    @State private var selectedCategory: String? = nil
    @State private var showNationalOnly = false
    @State private var selectedProject: ProjectRecord?

    private let categories = ["All", "Technology", "Education", "Health", "Trade", "Environment", "Governance", "Arts", "Agriculture"]

    var body: some View {
        ZStack {
            Color(hex: "0a4d3c").ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                // Category Filter
                categoryFilter

                // National Projects Toggle
                nationalToggle

                // Projects List
                if isLoading {
                    loadingView
                } else if projects.isEmpty {
                    emptyStateView
                } else {
                    projectsList
                }
            }
        }
        .task {
            await loadProjects()
        }
        .sheet(item: $selectedProject) { project in
            ProjectDetailView(project: project)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Projects")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("Support African innovation")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Button(action: { Task { await loadProjects() } }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category == "All" ? nil : category.lowercased()
                        }
                        Task { await loadProjects() }
                    }) {
                        Text(category)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isSelectedCategory(category) ? .black : .white.opacity(0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelectedCategory(category) ? Color(hex: "f59e0b") : Color.white.opacity(0.15))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }

    private func isSelectedCategory(_ category: String) -> Bool {
        if category == "All" && selectedCategory == nil { return true }
        return selectedCategory == category.lowercased()
    }

    // MARK: - National Toggle
    private var nationalToggle: some View {
        Toggle(isOn: $showNationalOnly) {
            HStack(spacing: 8) {
                Image(systemName: "flag.fill")
                    .foregroundColor(Color(hex: "f59e0b"))
                Text("National Projects Only")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "f59e0b")))
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .onChange(of: showNationalOnly) { _, _ in
            Task { await loadProjects() }
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
            Text("Loading projects...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 12)
            Spacer()
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.4))

            Text("No projects found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Text("Check back later for new projects")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Projects List
    private var projectsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(projects, id: \.projectId) { project in
                    ProjectCard(project: project) {
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
            if showNationalOnly {
                projects = try await ProjectAPIService.shared.getNationalProjects()
            } else {
                projects = try await ProjectAPIService.shared.getProjects(
                    category: selectedCategory,
                    status: "active"
                )
            }
        } catch {
            print("Error loading projects: \(error)")
            projects = []
        }

        isLoading = false
    }
}

// MARK: - Project Card
struct ProjectCard: View {
    let project: ProjectRecord
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(project.category.capitalized)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "f59e0b"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "f59e0b").opacity(0.2))
                                .cornerRadius(6)

                            if project.isNationalProject {
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                            }
                        }

                        Text(project.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }

                    Spacer()
                }

                // Description
                Text(project.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)

                // Progress Bar
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "f59e0b"))
                                .frame(width: geo.size.width * project.fundingProgress, height: 8)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Text("$\(Int(project.fundingRaised))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)

                        Text("of $\(Int(project.fundingGoal))")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))

                        Spacer()

                        Text("\(project.fundingPercentage)%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "f59e0b"))
                    }
                }

                // Stats
                HStack(spacing: 16) {
                    Label("\(project.votesCount)", systemImage: "hand.thumbsup.fill")
                    Label("\(project.supportersCount)", systemImage: "person.2.fill")

                    Spacer()

                    Text("by \(project.creatorName)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProjectsListView()
        .environment(AuthService.shared)
}
