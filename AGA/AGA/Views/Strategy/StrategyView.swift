//
//  StrategyView.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI

struct StrategyView: View {
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
                    Text("Trains & Rare-Earth Strategy")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textBright)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    
                    // Value-for-Value Card
                    AGACard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Value-for-Value Doctrine")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            Text("AGA rejects selling Africa's rare earth minerals for weak fiat. Instead, we trade directly for hard infrastructure: rail, power, refineries, ports and digital networks.")
                                .font(.system(size: 14))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineSpacing(3)
                        }
                    }
                    
                    // Strategic Pillars Card
                    AGACard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Strategic Pillars")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                StrategyPillarRow(text: "Tokenized infrastructure ownership for citizens.")
                                StrategyPillarRow(text: "Pan-African high-speed and cargo rail map.")
                                StrategyPillarRow(text: "Transparent, on-chain contracts for every deal.")
                            }
                        }
                    }
                    
                    // Impact Card
                    AGACard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Impact on AGA App")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            Text("The app becomes the public window into every deal: who benefits, what is built, and how rail and infrastructure link to geniuses, jobs, and long-term sovereignty.")
                                .font(.system(size: 14))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineSpacing(3)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Strategy Pillar Row
struct StrategyPillarRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

#Preview {
    StrategyView()
}

