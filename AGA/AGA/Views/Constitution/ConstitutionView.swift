//
//  ConstitutionView.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI

struct ConstitutionView: View {
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
                    Text("AGA Constitution")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textBright)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    
                    // Preamble Card
                    AGACard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preamble")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            Text("We, the Africa Genius Alliance, establish this meritocratic political party to restore dignity, capacity and transparency to African governance in all 54 states and among the diaspora.")
                                .font(.system(size: 14))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineSpacing(3)
                        }
                    }
                    
                    // Table of Contents Card
                    AGACard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Table of Contents")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ChapterRow(number: 1, title: "Principles & Values")
                                ChapterRow(number: 2, title: "Party Structure & Leadership")
                                ChapterRow(number: 3, title: "Digital Governance & Blockchain")
                                ChapterRow(number: 4, title: "Economic & Rare-Earth Policy")
                                ChapterRow(number: 5, title: "Security, Defence & Non-Interference")
                                ChapterRow(number: 6, title: "Amendments & Reforms")
                            }
                        }
                    }
                    
                    // Highlight Card
                    AGACard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Highlight: Non-Interference Clause")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.textBright)
                            
                            Text("No government, politician or agency shall unlawfully interfere with, suppress or attempt to shut down the AGA platform, which is protected under international democratic and digital rights.")
                                .font(.system(size: 14))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineSpacing(3)
                        }
                        .padding(4)
                        .background(DesignSystem.Colors.primarySoft)
                        .cornerRadius(AppConstants.smallCornerRadius)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Chapter Row
struct ChapterRow: View {
    let number: Int
    let title: String
    
    var body: some View {
        Button(action: {
            // Navigate to chapter detail
        }) {
            HStack {
                Text("Chapter \(number) – \(title)")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ConstitutionView()
}

