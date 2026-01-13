//
//  CreateHubView.swift
//  AGA
//
//  Leadership Action Hub for Geniuses
//  This is where geniuses take action to move people.
//

import SwiftUI

struct CreateHubView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showPostVision = false
    @State private var showGoLive = false
    @State private var showScheduleLive = false
    @State private var showProposals = false
    @State private var isLive = false

    var body: some View {
        ZStack {
            // Background
            Color(hex: "fef9e7")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Primary Actions
                    primaryActionsSection

                    // Guidelines Section
                    guidelinesSection

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .sheet(isPresented: $showPostVision) {
            CreatePostSheet()
        }
        .fullScreenCover(isPresented: $showGoLive) {
            GoLiveSheet(
                isLive: $isLive,
                userId: authViewModel.currentUser?.id ?? "",
                userName: authViewModel.currentUser?.fullName ?? "Genius",
                userPosition: nil
            )
        }
        .sheet(isPresented: $showScheduleLive) {
            ScheduleLiveSheet()
        }
        .sheet(isPresented: $showProposals) {
            ProposalsSheet()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Create")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "0a4d3c"))

            Text("Lead. Speak. Mobilize.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "6b7280"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Primary Actions Section
    private var primaryActionsSection: some View {
        VStack(spacing: 16) {
            // Post Vision - Large Card
            CreateActionCard(
                title: "Post Vision",
                subtitle: "Share your ideas, plans, and vision for the future",
                icon: "square.and.pencil",
                color: Color(hex: "10b981"),
                isLarge: true
            ) {
                showPostVision = true
            }

            HStack(spacing: 16) {
                // Go Live
                CreateActionCard(
                    title: isLive ? "Live Now" : "Go Live",
                    subtitle: "Start live session",
                    icon: isLive ? "dot.radiowaves.left.and.right" : "video.fill",
                    color: Color(hex: "ef4444"),
                    isLarge: false,
                    badge: isLive ? "LIVE" : nil
                ) {
                    showGoLive = true
                }

                // Schedule Live
                CreateActionCard(
                    title: "Schedule",
                    subtitle: "Plan ahead",
                    icon: "calendar.badge.clock",
                    color: Color(hex: "3b82f6"),
                    isLarge: false
                ) {
                    showScheduleLive = true
                }
            }

            // Proposals Card
            CreateActionCard(
                title: "Proposals",
                subtitle: "Create long-form policy or manifesto updates",
                icon: "doc.text.fill",
                color: Color(hex: "8b5cf6"),
                isLarge: true,
                isComingSoon: true
            ) {
                showProposals = true
            }
        }
    }

    // MARK: - Guidelines Section
    private var guidelinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Leadership Tips")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "374151"))

            VStack(alignment: .leading, spacing: 8) {
                GuidelineRow(icon: "calendar", text: "Great leaders post consistently")
                GuidelineRow(icon: "video", text: "Lives increase votes and trust")
                GuidelineRow(icon: "person.3", text: "Engage with your supporters daily")
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Create Action Card
struct CreateActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isLarge: Bool = false
    var badge: String? = nil
    var isComingSoon: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            if !isComingSoon {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                action()
            }
        }) {
            VStack(alignment: .leading, spacing: isLarge ? 12 : 8) {
                HStack {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: isLarge ? 56 : 44, height: isLarge ? 56 : 44)

                        Image(systemName: icon)
                            .font(.system(size: isLarge ? 24 : 18, weight: .semibold))
                            .foregroundColor(color)
                    }

                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "ef4444"))
                            .cornerRadius(4)
                    }

                    Spacer()

                    if isComingSoon {
                        Text("Coming Soon")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "9ca3af"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "f3f4f6"))
                            .cornerRadius(4)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "9ca3af"))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: isLarge ? 18 : 15, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))

                    Text(subtitle)
                        .font(.system(size: isLarge ? 14 : 12))
                        .foregroundColor(Color(hex: "6b7280"))
                        .lineLimit(2)
                }
            }
            .padding(isLarge ? 20 : 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            .opacity(isComingSoon ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Guideline Row
struct GuidelineRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "10b981"))
                .frame(width: 20)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "4b5563"))
        }
    }
}

// MARK: - Schedule Live Sheet
struct ScheduleLiveSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()

    var body: some View {
        NavigationView {
            Form {
                Section("Live Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }

                Section("Schedule") {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                }

                Section {
                    Button(action: scheduleLive) {
                        HStack {
                            Spacer()
                            Text("Schedule Live")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("Schedule Live")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func scheduleLive() {
        // TODO: Implement scheduling logic
        dismiss()
    }
}

// MARK: - Proposals Sheet
struct ProposalsSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "8b5cf6"))

                Text("Proposals Coming Soon")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "1f2937"))

                Text("Create long-form policy documents and manifesto updates to share your detailed vision with supporters.")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "6b7280"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
            }
            .navigationTitle("Proposals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CreateHubView()
        .environmentObject(AuthViewModel(authService: AuthService.shared))
}
