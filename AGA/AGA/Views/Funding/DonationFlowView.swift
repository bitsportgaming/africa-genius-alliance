//
//  DonationFlowView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

struct DonationFlowView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    let recipientId: String
    let recipientName: String
    let recipientType: String // "genius", "project", "product"
    let recipientImage: String?

    @State private var selectedAmount: Int = 25
    @State private var customAmount: String = ""
    @State private var message: String = ""
    @State private var isAnonymous: Bool = false
    @State private var isProcessing: Bool = false
    @State private var showSuccess: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private let presetAmounts = [10, 25, 50, 100, 250, 500]

    private var donationAmount: Double {
        if let custom = Double(customAmount), custom > 0 {
            return custom
        }
        return Double(selectedAmount)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a4d3c").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Recipient Card
                        recipientCard

                        // Amount Selection
                        amountSection

                        // Message (optional)
                        messageSection

                        // Anonymous toggle
                        anonymousToggle

                        // Donate Button
                        donateButton

                        // Transparency note
                        transparencyNote
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Support \(recipientName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
        .alert("Donation Successful! 🎉", isPresented: $showSuccess) {
            Button("Done") { dismiss() }
        } message: {
            Text("Thank you for supporting \(recipientName) with $\(Int(donationAmount))!")
        }
        .alert("Donation Failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Recipient Card
    private var recipientCard: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(hex: "f59e0b").opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(String(recipientName.prefix(1)))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "f59e0b"))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(recipientName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text(recipientType.capitalized)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }

    // MARK: - Amount Section
    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SELECT AMOUNT")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            // Preset amounts grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(presetAmounts, id: \.self) { amount in
                    Button(action: {
                        selectedAmount = amount
                        customAmount = ""
                        HapticFeedback.impact(.light)
                    }) {
                        Text("$\(amount)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(selectedAmount == amount && customAmount.isEmpty ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedAmount == amount && customAmount.isEmpty ? Color(hex: "f59e0b") : Color.white.opacity(0.1))
                            )
                    }
                }
            }

            // Custom amount
            HStack {
                Text("$")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                TextField("Custom amount", text: $customAmount)
                    .keyboardType(.numberPad)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }

    // MARK: - Message Section
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ADD A MESSAGE (OPTIONAL)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            TextField("Write an encouraging message...", text: $message, axis: .vertical)
                .lineLimit(3...5)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
        }
    }

    // MARK: - Anonymous Toggle
    private var anonymousToggle: some View {
        Toggle(isOn: $isAnonymous) {
            HStack(spacing: 12) {
                Image(systemName: isAnonymous ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(Color(hex: "f59e0b"))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Donate Anonymously")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)

                    Text("Your name won't be shown publicly")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "f59e0b")))
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }

    // MARK: - Donate Button
    private var donateButton: some View {
        Button(action: { Task { await processDonation() } }) {
            HStack(spacing: 12) {
                if isProcessing {
                    ProgressView()
                        .tint(.black)
                } else {
                    Image(systemName: "heart.fill")
                }

                Text(isProcessing ? "Processing..." : "Donate $\(Int(donationAmount))")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "f59e0b"))
            )
        }
        .disabled(isProcessing || donationAmount <= 0)
    }

    // MARK: - Transparency Note
    private var transparencyNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(.green)

            Text("100% of your donation goes directly to the recipient. All transactions are transparent and auditable.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
        )
    }

    // MARK: - Process Donation
    private func processDonation() async {
        guard let userId = authService.currentUser?.id else { return }
        let userName = authService.currentUser?.displayName ?? "Anonymous"

        isProcessing = true
        HapticFeedback.impact(.medium)

        do {
            _ = try await FundingAPIService.shared.donate(
                donorId: userId,
                donorName: userName,
                recipientId: recipientId,
                recipientType: recipientType,
                amount: donationAmount,
                message: message.isEmpty ? nil : message,
                isAnonymous: isAnonymous
            )

            await MainActor.run {
                showSuccess = true
                HapticFeedback.notification(.success)
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                HapticFeedback.notification(.error)
            }
        }

        isProcessing = false
    }
}

#Preview {
    DonationFlowView(
        recipientId: "test123",
        recipientName: "Amina Mensah",
        recipientType: "genius",
        recipientImage: nil
    )
    .environment(AuthService.shared)
}
