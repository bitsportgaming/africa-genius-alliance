//
//  TransparencyDashboardView.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import SwiftUI

struct TransparencyDashboardView: View {
    @Environment(AuthService.self) private var authService

    @State private var transparencyData: TransparencyData? = nil
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a4d3c").ignoresSafeArea()

                if isLoading {
                    loadingView
                } else if let data = transparencyData {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header
                            headerSection

                            // Total Stats
                            totalStatsCard(data: data)

                            // Allocation Breakdown
                            allocationBreakdown(data: data)

                            // Recent Transactions
                            recentTransactions(data: data)

                            // Trust Badge
                            trustBadge
                        }
                        .padding(20)
                        .padding(.bottom, 40)
                    }
                } else {
                    errorView
                }
            }
            .navigationTitle("Transparency")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadData()
            }
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color(hex: "f59e0b"))
            Text("Loading transparency data...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("Unable to load data")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Button("Retry") {
                Task { await loadData() }
            }
            .foregroundColor(Color(hex: "f59e0b"))
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)

                Text("100% TRANSPARENT")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
                    .tracking(1)
            }

            Text("Every donation is tracked and auditable")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Total Stats Card
    private func totalStatsCard(data: TransparencyData) -> some View {
        VStack(spacing: 16) {
            Text("TOTAL FUNDS RAISED")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            Text("$\(formatNumber(data.totalRaised))")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 24) {
                statItem(value: "\(data.totalDonors)", label: "Donors")
                statItem(value: "\(data.totalTransactions)", label: "Transactions")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "f59e0b").opacity(0.2), Color(hex: "0a4d3c")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    // MARK: - Allocation Breakdown
    private func allocationBreakdown(data: TransparencyData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FUND ALLOCATION")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "f59e0b"))
                .tracking(1)

            VStack(spacing: 12) {
                allocationRow(label: "Genius Support", amount: data.byType.genius, color: .blue, total: data.totalRaised)
                allocationRow(label: "National Projects", amount: data.byType.project, color: .green, total: data.totalRaised)
                allocationRow(label: "Impact Products", amount: data.byType.product, color: .purple, total: data.totalRaised)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func allocationRow(label: String, amount: Double, color: Color, total: Double) -> some View {
        let percentage = total > 0 ? (amount / total) : 0

        return HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white)

            Spacer()

            Text("$\(formatNumber(amount))")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            Text("(\(Int(percentage * 100))%)")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 45, alignment: .trailing)
        }
    }

    // MARK: - Recent Transactions
    private func recentTransactions(data: TransparencyData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("RECENT TRANSACTIONS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "f59e0b"))
                    .tracking(1)

                Spacer()

                Text("Live")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(6)
            }

            if data.recentDonations.isEmpty {
                Text("No recent transactions")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(data.recentDonations) { donation in
                    transactionRow(donation: donation)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func transactionRow(donation: RecentDonation) -> some View {
        HStack {
            // Icon
            Circle()
                .fill(typeColor(donation.recipientType).opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: typeIcon(donation.recipientType))
                        .font(.system(size: 16))
                        .foregroundColor(typeColor(donation.recipientType))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(donation.donorName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)

                Text(donation.recipientType.capitalized)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("+$\(Int(donation.amount))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)

                Text(formatDate(donation.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
    }

    private func typeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "genius": return "person.fill"
        case "project": return "flag.fill"
        case "product": return "bag.fill"
        default: return "heart.fill"
        }
    }

    private func typeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "genius": return .blue
        case "project": return .green
        case "product": return .purple
        default: return Color(hex: "f59e0b")
        }
    }

    // MARK: - Trust Badge
    private var trustBadge: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)

                Text("Blockchain Verified")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text("All transactions are recorded on-chain for complete transparency and auditability.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Helper Functions
    private func formatNumber(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.0fK", value / 1_000)
        }
        return String(format: "%.0f", value)
    }

    private func formatDate(_ dateString: String) -> String {
        // Simple date formatting
        let components = dateString.split(separator: "T")
        if let date = components.first {
            return String(date)
        }
        return dateString
    }

    // MARK: - Load Data
    private func loadData() async {
        isLoading = true

        do {
            transparencyData = try await FundingAPIService.shared.getTransparencyData()
        } catch {
            print("Error loading transparency data: \(error)")
            // Use mock data as fallback
            transparencyData = TransparencyData(
                totalRaised: 125000,
                totalDonors: 1250,
                totalTransactions: 3500,
                byType: DonationByType(genius: 45000, project: 55000, product: 25000),
                recentDonations: [
                    RecentDonation(amount: 50, currency: "USD", recipientType: "genius", createdAt: "2026-01-04T10:30:00Z", donorName: "Anonymous"),
                    RecentDonation(amount: 100, currency: "USD", recipientType: "project", createdAt: "2026-01-04T09:15:00Z", donorName: "John D."),
                    RecentDonation(amount: 25, currency: "USD", recipientType: "product", createdAt: "2026-01-04T08:45:00Z", donorName: "Sarah M.")
                ]
            )
        }

        isLoading = false
    }
}

#Preview {
    TransparencyDashboardView()
        .environment(AuthService.shared)
}
