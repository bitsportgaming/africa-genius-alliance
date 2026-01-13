//
//  AGAProfileView.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI

struct AGAProfileView: View {
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
                    Text("AGA Official Profile")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textBright)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    
                    // AGA Header Card
                    AGACard {
                        HStack(spacing: 16) {
                            // AGA Logo Circle
                            ZStack {
                                Circle()
                                    .fill(DesignSystem.Gradients.agaLogo)
                                    .frame(width: 60, height: 60)
                                
                                Text("AGA")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Africa Genius Alliance (AGA)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textBright)
                                
                                Text("Meritocratic Political Party • Pan-African")
                                    .font(.system(size: 12))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                
                                Text("Verified • International Registration")
                                    .font(.system(size: 11))
                                    .foregroundColor(DesignSystem.Colors.primary)
                            }
                        }
                    }
                    
                    // Mission Card
                    AGACard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Our Mission")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            Text("To identify, elevate and protect Africa's most capable leaders using transparent digital tools, and to transform our continent through meritocracy, rare-earth sovereignty and connected infrastructure.")
                                .font(.system(size: 14))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineSpacing(3)
                        }
                    }
                    
                    // Core Pillars Card
                    AGACard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Core Pillars")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                PillarRow(text: "Meritocracy over patronage and tribal politics.")
                                PillarRow(text: "Digital transparency powered by blockchain.")
                                PillarRow(text: "Economic sovereignty through value-for-value rare-earth deals.")
                                PillarRow(text: "Continental integration via a Pan-African train network.")
                            }
                        }
                    }
                    
                    // CTA Buttons
                    HStack(spacing: 12) {
                        AGAButton(title: "Read Constitution", style: .primary) {
                            // Navigate to constitution
                        }
                        
                        AGAButton(title: "View AGA Projects", style: .outline) {
                            // Navigate to projects
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Pillar Row
struct PillarRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

#Preview {
    AGAProfileView()
}

