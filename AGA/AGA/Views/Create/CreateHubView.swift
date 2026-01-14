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
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = "policy"
    @State private var implementationDetails = ""
    @State private var impact = ""
    @State private var votingDays = 7
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    let categories = ["policy", "funding", "governance", "community", "technical"]

    var isValid: Bool {
        !title.isEmpty && !description.isEmpty && description.count >= 50
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "fef9e7").ignoresSafeArea()

                if showSuccess {
                    successView
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Header Info
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Create a Proposal")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "1f2937"))

                                Text("Submit policy proposals for community voting. Clear, detailed proposals are more likely to pass.")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "6b7280"))
                            }
                            .padding(.horizontal)

                            // Form Fields
                            VStack(spacing: 20) {
                                // Title
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Proposal Title")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "374151"))

                                    TextField("e.g., Increase Education Budget by 15%", text: $title)
                                        .textFieldStyle(ProposalTextFieldStyle())
                                }

                                // Category
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Category")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "374151"))

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(categories, id: \.self) { cat in
                                                Button(action: { selectedCategory = cat }) {
                                                    Text(cat.capitalized)
                                                        .font(.system(size: 13, weight: .medium))
                                                        .padding(.horizontal, 16)
                                                        .padding(.vertical, 8)
                                                        .background(selectedCategory == cat ? Color(hex: "8b5cf6") : Color.white)
                                                        .foregroundColor(selectedCategory == cat ? .white : Color(hex: "6b7280"))
                                                        .cornerRadius(20)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .stroke(selectedCategory == cat ? Color.clear : Color(hex: "e5e7eb"), lineWidth: 1)
                                                        )
                                                }
                                            }
                                        }
                                    }
                                }

                                // Description
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Description")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color(hex: "374151"))
                                        Spacer()
                                        Text("\(description.count) chars (min 50)")
                                            .font(.system(size: 12))
                                            .foregroundColor(description.count >= 50 ? Color(hex: "10b981") : Color(hex: "9ca3af"))
                                    }

                                    TextEditor(text: $description)
                                        .frame(minHeight: 120)
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "e5e7eb"), lineWidth: 1))
                                }

                                // Implementation Details (Optional)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Implementation Plan (Optional)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "374151"))

                                    TextEditor(text: $implementationDetails)
                                        .frame(minHeight: 80)
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "e5e7eb"), lineWidth: 1))
                                }

                                // Expected Impact (Optional)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Expected Impact (Optional)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "374151"))

                                    TextField("e.g., Benefits 2 million students", text: $impact)
                                        .textFieldStyle(ProposalTextFieldStyle())
                                }

                                // Voting Duration
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Voting Duration")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "374151"))

                                    HStack(spacing: 12) {
                                        ForEach([7, 14, 30], id: \.self) { days in
                                            Button(action: { votingDays = days }) {
                                                Text("\(days) days")
                                                    .font(.system(size: 13, weight: .medium))
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 10)
                                                    .background(votingDays == days ? Color(hex: "10b981") : Color.white)
                                                    .foregroundColor(votingDays == days ? .white : Color(hex: "6b7280"))
                                                    .cornerRadius(10)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(votingDays == days ? Color.clear : Color(hex: "e5e7eb"), lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }

                                // Error Message
                                if let error = errorMessage {
                                    Text(error)
                                        .font(.system(size: 13))
                                        .foregroundColor(.red)
                                        .padding(.horizontal)
                                }

                                // Submit Button
                                Button(action: submitProposal) {
                                    HStack {
                                        if isSubmitting {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.9)
                                        }
                                        Text(isSubmitting ? "Submitting..." : "Submit Proposal")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(isValid ? Color(hex: "8b5cf6") : Color(hex: "d1d5db"))
                                    .cornerRadius(14)
                                }
                                .disabled(!isValid || isSubmitting)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                        }
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("New Proposal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "10b981"))

            Text("Proposal Submitted!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "1f2937"))

            Text("Your proposal is now live for community voting. You'll be notified when voting concludes.")
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "6b7280"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "8b5cf6"))
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func submitProposal() {
        guard let user = authViewModel.currentUser else { return }

        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                let endDate = Calendar.current.date(byAdding: .day, value: votingDays, to: Date()) ?? Date()

                _ = try await ProposalAPIService.shared.createProposal(
                    title: title,
                    description: description,
                    category: selectedCategory,
                    proposerId: user.id,
                    proposerName: user.displayName,
                    endDate: endDate
                )

                await MainActor.run {
                    isSubmitting = false
                    showSuccess = true
                    HapticFeedback.notification(.success)
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = "Failed to submit proposal. Please try again."
                    HapticFeedback.notification(.error)
                }
            }
        }
    }
}

// Custom TextField Style for Proposals
struct ProposalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "e5e7eb"), lineWidth: 1))
    }
}

#Preview {
    CreateHubView()
        .environmentObject(AuthViewModel(authService: AuthService.shared))
}
