//
//  FundingView.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI

struct FundingView: View {
    @State private var selectedAmount = 25
    @State private var customAmount = ""
    @State private var selectedCurrency = "USD"
    @State private var showComingSoonAlert = false

    private let presetAmounts = [25, 50, 100, 250]
    private let currencies = ["USD", "USDT", "EUR"]

    private let accentColor = Color(hex: "f59e0b")

    var body: some View {
        ZStack {
            // Background gradient
            Color(hex: "0a4d3c").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    AGAHeader()
                        .padding(.top, 8)

                    // Title
                    Text("Fund This Genius")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                    // Campaign Card
                    campaignCard

                    // Milestone Breakdown
                    milestoneCard

                    // Contribution Card
                    contributionCard

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
            }
        }
        .alert("Coming Soon", isPresented: $showComingSoonAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This function will be activated shortly.")
        }
    }

    // MARK: - Campaign Card
    private var campaignCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("FUNDING CAMPAIGN")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(accentColor)
                .tracking(1.2)

            Text("Amina Mensah • Education Reform 2035")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.15))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [accentColor, accentColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * 0.62)
                }
            }
            .frame(height: 8)

            HStack(spacing: 6) {
                Text("$84,210")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text("raised of $135,000 goal")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                Text("62%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(accentColor)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Milestone Card
    private var milestoneCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Milestone Breakdown")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 10) {
                MilestoneRowImproved(percentage: "25%", description: "Community townhalls & school tours", color: accentColor)
                MilestoneRowImproved(percentage: "35%", description: "Research, curriculum redesign teams", color: accentColor)
                MilestoneRowImproved(percentage: "20%", description: "Digital content, teacher training", color: accentColor)
                MilestoneRowImproved(percentage: "20%", description: "Compliance, legal, audit & reporting", color: accentColor)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Contribution Card
    private var contributionCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Choose Your Contribution")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            // Preset amounts
            HStack(spacing: 10) {
                ForEach(presetAmounts, id: \.self) { amount in
                    Button {
                        HapticFeedback.selection()
                        selectedAmount = amount
                        customAmount = ""
                    } label: {
                        Text("$\(amount)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(selectedAmount == amount ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedAmount == amount ? accentColor : Color.white.opacity(0.12))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedAmount == amount ? accentColor : Color.white.opacity(0.25), lineWidth: 1)
                            )
                    }
                }
            }

            // Custom amount input
            HStack {
                Text("$")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))

                TextField("Enter custom amount", text: $customAmount)
                    .keyboardType(.numberPad)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .tint(accentColor)
                    .onChange(of: customAmount) { _, newValue in
                        if !newValue.isEmpty {
                            selectedAmount = 0
                        }
                    }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )

            // Currency selector
            Menu {
                ForEach(currencies, id: \.self) { currency in
                    Button(currency) {
                        selectedCurrency = currency
                    }
                }
            } label: {
                HStack {
                    Text("Currency:")
                        .foregroundColor(.white.opacity(0.7))
                    Text(selectedCurrency)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }

            // Continue Button
            Button {
                HapticFeedback.impact(.medium)
                showComingSoonAlert = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "link")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Continue to On-Chain Payment")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accentColor)
                )
            }

            // Transparency note
            Text("Funds are held in a smart contract and released only when milestones are verified.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

// MARK: - Improved Milestone Row
struct MilestoneRowImproved: View {
    let percentage: String
    let description: String
    let color: Color

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(percentage)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
                .frame(width: 40, alignment: .leading)

            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.85))
        }
    }
}

// MARK: - Legacy Milestone Row (for compatibility)
struct MilestoneRow: View {
    let percentage: String
    let description: String

    var body: some View {
        MilestoneRowImproved(percentage: percentage, description: description, color: Color(hex: "f59e0b"))
    }
}

#Preview {
    FundingView()
}

