//
//  DAOView.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI

struct DAOView: View {
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
                    Text("DAO & Treasury")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textBright)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    
                    // Treasury Card
                    AGACard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Treasury")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            Text("$5,420,000")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            Text("Multi-sig, on-chain, internationally audited")
                                .font(.system(size: 11))
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            // Treasury split
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                TreasuryStat(label: "Genius Funding", value: "45%")
                                TreasuryStat(label: "Infrastructure", value: "30%")
                                TreasuryStat(label: "Operations", value: "15%")
                                TreasuryStat(label: "Reserves", value: "10%")
                            }
                            .padding(.top, 8)
                        }
                    }
                    
                    // Active Proposals Card
                    AGACard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Active Proposals")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            ProposalRow(
                                title: "Expand Pan-African Train Feasibility Study",
                                meta: "Closes in 3 days • Quorum: 68%",
                                yesPercent: 68,
                                noPercent: 32
                            )
                            
                            ProposalRow(
                                title: "Fund 200 Youth Genius Fellowships",
                                meta: "Closes in 7 days • Quorum: 41%",
                                yesPercent: 41,
                                noPercent: 59
                            )
                        }
                    }
                    
                    // CTA Buttons
                    HStack(spacing: 12) {
                        AGAButton(title: "View All Proposals", style: .primary) {
                            // View all action
                        }
                        
                        AGAButton(title: "Submit New Proposal", style: .outline) {
                            // Submit action
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Treasury Stat
struct TreasuryStat: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textBright)
        }
    }
}

// MARK: - Proposal Row
struct ProposalRow: View {
    let title: String
    let meta: String
    let yesPercent: Int
    let noPercent: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.textBright)
            
            Text(meta)
                .font(.system(size: 11))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            AGAProgressBar(
                progress: Double(yesPercent) / 100.0,
                color: yesPercent > 50 ? DesignSystem.Colors.primary : Color(hex: "6b7280")
            )
            
            Text("Yes \(yesPercent)% • No \(noPercent)%")
                .font(.system(size: 11))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding(10)
        .background(Color(hex: "0f172a").opacity(0.4))
        .cornerRadius(AppConstants.smallCornerRadius)
    }
}

#Preview {
    DAOView()
}

