//
//  AGAComponents.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI

// MARK: - AGA Header
struct AGAHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            // Logo circle with emerald gradient
            ZStack {
                DesignSystem.Gradients.logo
                Text("AGA")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(Color(hex: "0f172a"))
                    .tracking(1)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Africa Genius Alliance")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(DesignSystem.Colors.textBright)

                Text("Meritocracy • Leadership • Africa First")
                    .font(.system(size: 11))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "0f172a").opacity(0.96),
                    Color(hex: "0f172a").opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppConstants.pillRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.pillRadius)
                .stroke(Color(hex: "94a3b8").opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - AGA Card
struct AGACard<Content: View>: View {
    let content: Content
    var isHero: Bool = false

    init(isHero: Bool = false, @ViewBuilder content: () -> Content) {
        self.isHero = isHero
        self.content = content()
    }

    var body: some View {
        content
            .padding(12)
            .background(
                Group {
                    if isHero {
                        DesignSystem.Gradients.heroCard
                    } else {
                        DesignSystem.Gradients.card
                    }
                }
            )
            .cornerRadius(AppConstants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .stroke(Color(hex: "94a3b8").opacity(0.4), lineWidth: 1)
            )
    }
}

// MARK: - AGA Button
struct AGAButton: View {
    enum Style {
        case primary
        case ghost
        case outline
    }

    let title: String
    let style: Style
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
        }
        .background(backgroundForStyle)
        .foregroundColor(textColorForStyle)
        .cornerRadius(AppConstants.pillRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.pillRadius)
                .stroke(borderColorForStyle, lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }

    private var backgroundForStyle: some ShapeStyle {
        switch style {
        case .primary:
            return AnyShapeStyle(DesignSystem.Gradients.primary)
        case .ghost, .outline:
            return AnyShapeStyle(Color.clear)
        }
    }

    private var textColorForStyle: Color {
        switch style {
        case .primary:
            return Color(hex: "022c22")
        case .ghost, .outline:
            return DesignSystem.Colors.textPrimary
        }
    }

    private var borderColorForStyle: Color {
        switch style {
        case .primary:
            return DesignSystem.Colors.primaryStrong
        case .ghost, .outline:
            return Color(hex: "94a3b8").opacity(style == .ghost ? 0.5 : 0.6)
        }
    }
}

// MARK: - AGA Pill
struct AGAPill: View {
    let text: String
    var isPrimary: Bool = false

    var body: some View {
        Text(text)
            .font(.system(size: 11))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isPrimary ? DesignSystem.Colors.primarySoft : Color(hex: "0f172a").opacity(0.8))
            .foregroundColor(isPrimary ? DesignSystem.Colors.primaryLight : DesignSystem.Colors.textTertiary)
            .cornerRadius(AppConstants.pillRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.pillRadius)
                    .stroke(isPrimary ? DesignSystem.Colors.primary : Color(hex: "94a3b8").opacity(0.5), lineWidth: 1)
            )
    }
}

// MARK: - AGA Chip (Filter Button)
struct AGAChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 11))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
        }
        .background(isSelected ? DesignSystem.Colors.primarySoft : Color(hex: "0f172a").opacity(0.7))
        .foregroundColor(isSelected ? DesignSystem.Colors.primaryLight : DesignSystem.Colors.textPrimary)
        .cornerRadius(AppConstants.pillRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.pillRadius)
                .stroke(isSelected ? DesignSystem.Colors.primary : Color(hex: "94a3b8").opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - AGA Input Field
struct AGAInput: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(.system(size: 15))
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(Color(hex: "0f172a").opacity(0.95))
        .foregroundColor(DesignSystem.Colors.textPrimary)
        .tint(DesignSystem.Colors.primary)
        .cornerRadius(AppConstants.smallCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.smallCornerRadius)
                .stroke(Color(hex: "94a3b8").opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - AGA Progress Bar
struct AGAProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "1f2937"))
                    .frame(height: 6)

                // Progress fill
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 6)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Africa Badge
struct AfricaBadge: View {
    var body: some View {
        HStack(spacing: 10) {
            // Africa map circle with conic gradient
            ZStack {
                DesignSystem.Gradients.africaMap
                Image(systemName: "globe.africa.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "0f172a"))
            }
            .frame(width: 36, height: 36)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Made for Africa")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("Pan-African • Digital • Sovereign")
                    .font(.system(size: 11))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }

            Spacer()
        }
        .padding(10)
        .background(Color(hex: "0f172a").opacity(0.6))
        .cornerRadius(AppConstants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                .stroke(Color(hex: "94a3b8").opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Genius Avatar
struct GeniusAvatar: View {
    let initials: String
    let size: CGFloat

    var body: some View {
        ZStack {
            DesignSystem.Gradients.geniusAvatar
            Text(initials)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - Profile Avatar Large
struct ProfileAvatarLarge: View {
    let initials: String
    var profileImageURL: String? = nil

    var body: some View {
        Group {
            if let imageURL = profileImageURL, !imageURL.isEmpty {
                Image(imageURL)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    DesignSystem.Gradients.profileAvatar
                    Text(initials)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color(hex: "0f172a"), lineWidth: 3)
        )
    }
}

// MARK: - Icon Button
struct AGAIconButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.accent)
        }
        .frame(width: 32, height: 32)
        .background(Color(hex: "0f172a").opacity(0.9))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color(hex: "94a3b8").opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - AGA Watermark Overlay
/// A diagonal watermark overlay that displays "AFRICA GENIUS ALLIANCE" text
/// Similar to official AGA letterhead watermarks
struct AGAWatermark: View {
    var opacity: Double = 0.08
    var fontSize: CGFloat = 32
    var color: Color = Color(hex: "0a4d3c")

    var body: some View {
        GeometryReader { geometry in
            let text = "AFRICA GENIUS ALLIANCE"
            let repeats = Int(max(geometry.size.height, geometry.size.width) / 150) + 3

            ZStack {
                ForEach(0..<repeats, id: \.self) { index in
                    Text(text)
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundColor(color.opacity(opacity))
                        .tracking(4)
                        .rotationEffect(.degrees(-35))
                        .offset(
                            x: CGFloat(index - repeats/2) * 80 - 50,
                            y: CGFloat(index) * 120 - geometry.size.height * 0.3
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - View Extension for Watermark
extension View {
    /// Adds an AGA watermark overlay to any view
    func agaWatermark(opacity: Double = 0.08, color: Color = Color(hex: "0a4d3c")) -> some View {
        self.overlay(
            AGAWatermark(opacity: opacity, color: color)
                .clipped()
        )
    }
}

