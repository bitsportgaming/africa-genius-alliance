//
//  ModernButton.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI

struct ModernButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled
    @State private var isPressed = false

    enum ButtonStyle {
        case primary
        case secondary
        case accent
        case genius
        case outline
        case ghost

        var gradient: LinearGradient {
            switch self {
            case .primary:
                return DesignSystem.Gradients.primary
            case .secondary:
                return LinearGradient(colors: [DesignSystem.Colors.textSecondary], startPoint: .leading, endPoint: .trailing)
            case .accent:
                return DesignSystem.Gradients.accent
            case .genius:
                return DesignSystem.Gradients.genius
            case .outline, .ghost:
                return LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .secondary, .accent, .genius:
                return .white
            case .outline:
                return DesignSystem.Colors.primary
            case .ghost:
                return DesignSystem.Colors.textSecondary
            }
        }
    }

    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(DesignSystem.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if style == .outline {
                        RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                            .stroke(DesignSystem.Colors.primary, lineWidth: 2)
                    } else if style == .ghost {
                        Color.clear
                    } else {
                        style.gradient
                    }
                }
            )
            .foregroundColor(style.foregroundColor)
            .cornerRadius(AppConstants.cornerRadius)
            .shadow(color: style == .ghost ? .clear : .black.opacity(0.1), radius: isPressed ? 8 : 12, x: 0, y: isPressed ? 2 : 4)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .allowsHitTesting(isEnabled)
    }
}

struct ModernTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    var isSecure: Bool = false

    init(_ placeholder: String, text: Binding<String>, icon: String? = nil, isSecure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
    }

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "6b7280")) // Gray icon
                    .frame(width: 20)
            }

            ZStack(alignment: .leading) {
                // Custom placeholder with visible color
                if text.isEmpty {
                    Text(placeholder)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(Color(hex: "9ca3af")) // Medium gray for visibility
                }

                if isSecure {
                    SecureField("", text: $text)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(Color(hex: "1f2937")) // Dark text
                        .tint(Color(hex: "0a4d3c"))
                } else {
                    TextField("", text: $text)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(Color(hex: "1f2937")) // Dark text
                        .tint(Color(hex: "0a4d3c"))
                }
            }
        }
        .padding(.horizontal, AppConstants.padding)
        .frame(height: 56)
        .background(Color.white) // White background for visibility
        .cornerRadius(AppConstants.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                .stroke(Color(hex: "d1d5db"), lineWidth: 1) // Light gray border
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        ModernButton("Primary Button", icon: "star.fill", style: .primary) {}
        ModernButton("Accent Button", icon: "heart.fill", style: .accent) {}
        ModernButton("Genius Button", icon: "sparkles", style: .genius) {}
        ModernButton("Outline Button", style: .outline) {}
    }
    .padding()
}

