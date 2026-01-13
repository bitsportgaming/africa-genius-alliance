//
//  CategorySelectionStep.swift
//  AGA
//
//  Step 1: Select genius category
//

import SwiftUI

struct CategorySelectionStep: View {
    @Binding var selectedCategory: GeniusCategory?
    let onNext: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "f59e0b"))
                    
                    Text("What Type of Genius Are You?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Select the category that best describes your expertise and vision for Africa")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                
                // Category Cards
                VStack(spacing: 16) {
                    ForEach(GeniusCategory.allCases) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = category
                            }
                            HapticFeedback.impact(.medium)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Continue Button
                Button(action: onNext) {
                    HStack {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(selectedCategory != nil ? Color(hex: "0a4d3c") : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(selectedCategory != nil ? Color(hex: "f59e0b") : Color.white.opacity(0.2))
                    )
                }
                .disabled(selectedCategory == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: GeniusCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: category.color).opacity(isSelected ? 1 : 0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : Color(hex: category.color))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : Color(hex: "1f2937"))
                    
                    Text(category.description)
                        .font(.system(size: 13))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Color(hex: "6b7280"))
                    
                    Text("\(category.positions.count) positions")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isSelected ? Color(hex: "f59e0b") : Color(hex: "9ca3af"))
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "f59e0b"))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(hex: category.color) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color(hex: "e5e7eb"), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color(hex: category.color).opacity(0.3) : .black.opacity(0.05), 
                    radius: isSelected ? 12 : 4, x: 0, y: isSelected ? 6 : 2)
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "0a4d3c").ignoresSafeArea()
        CategorySelectionStep(selectedCategory: .constant(.technical)) { }
    }
}

