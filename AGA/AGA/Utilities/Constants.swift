//
//  Constants.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftUI

enum AppConstants {
    // MARK: - App Info
    static let appName = "AGA"
    static let appFullName = "Africa Genius Alliance"

    // MARK: - Validation
    static let minPasswordLength = 6
    static let maxPostLength = 5000
    static let maxCommentLength = 1000
    static let maxBioLength = 200

    // MARK: - UI
    static let cornerRadius: CGFloat = 14  // Card radius
    static let smallCornerRadius: CGFloat = 10
    static let largeCornerRadius: CGFloat = 18  // Screen wrapper radius
    static let pillRadius: CGFloat = 999  // Fully rounded
    static let padding: CGFloat = 12
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 16

    // MARK: - Images
    static let maxImagesPerPost = 10
    static let placeholderImageURL = "https://via.placeholder.com/400"

    // MARK: - Animation
    static let animationDuration: Double = 0.3
    static let springResponse: Double = 0.5
    static let springDamping: Double = 0.7
}

// MARK: - Design System
struct DesignSystem {
    // MARK: - Colors
    struct Colors {
        // Primary Brand Colors (Deep Emerald Green - from reference)
        static let primary = Color(hex: "0a4d3c")  // Deep emerald green
        static let primarySoft = Color(hex: "0a4d3c").opacity(0.15)
        static let primaryStrong = Color(hex: "064e3b")  // Darker emerald
        static let primaryLight = Color(hex: "10b981")  // Lighter emerald

        // Accent Colors (Orange/Amber - from reference)
        static let accent = Color(hex: "f59e0b")  // Warm orange/amber
        static let accentSoft = Color(hex: "f59e0b").opacity(0.12)
        static let accentOrange = Color(hex: "fb923c")  // Lighter orange
        static let accentDark = Color(hex: "d97706")  // Darker orange

        // Background Colors (from reference)
        static let background = Color(hex: "0a4d3c")  // Deep emerald for backgrounds
        static let backgroundSoft = Color(hex: "064e3b")  // Slightly darker
        static let backgroundElevated = Color(hex: "065f46")  // Card background
        static let backgroundCream = Color(hex: "fef9e7")  // Cream/beige for light sections
        static let backgroundOrange = Color(hex: "f59e0b")  // Orange backgrounds

        // Surface Colors
        static let surface = Color(hex: "064e3b").opacity(0.95)
        static let surfaceSecondary = Color(hex: "064e3b").opacity(0.8)
        static let border = Color(hex: "10b981").opacity(0.3)  // Emerald border
        static let borderSoft = Color(hex: "065f46")
        static let borderOrange = Color(hex: "fb923c").opacity(0.5)  // Orange border

        // Text Colors (Adaptive for dark/light backgrounds)
        static let textPrimary = Color(hex: "1f2937")  // Dark text for light backgrounds
        static let textSecondary = Color(hex: "4b5563")  // Muted dark text
        static let textTertiary = Color(hex: "6b7280")  // Soft dark text
        static let textBright = Color(hex: "ffffff")  // White text for dark backgrounds
        static let textLight = Color(hex: "f9fafb")  // Light text

        // Semantic Colors
        static let success = Color(hex: "10b981")
        static let error = Color(hex: "ef4444")
        static let warning = Color(hex: "f59e0b")
        static let info = Color(hex: "3b82f6")

        // Genius/Orange Colors (from reference)
        static let genius = Color(hex: "f59e0b")  // Orange
        static let geniusLight = Color(hex: "fef3c7")  // Light cream
        static let geniusDark = Color(hex: "d97706")  // Dark orange

        // Adaptive Colors (for light/dark mode support)
        static var adaptiveBackground: Color {
            background
        }

        static var adaptiveSurface: Color {
            surface
        }

        static var adaptiveText: Color {
            textPrimary
        }
    }

    // MARK: - Gradients
    struct Gradients {
        // Primary emerald gradient (for green backgrounds)
        static let primary = LinearGradient(
            colors: [Color(hex: "0a4d3c"), Color(hex: "064e3b")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Accent orange gradient (for buttons and highlights)
        static let accent = LinearGradient(
            colors: [Color(hex: "f59e0b"), Color(hex: "d97706")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Genius gradient (orange - from reference)
        static let genius = LinearGradient(
            colors: [Color(hex: "fb923c"), Color(hex: "f59e0b")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Background gradient (deep emerald - from reference)
        static let background = LinearGradient(
            colors: [Color(hex: "0a4d3c"), Color(hex: "064e3b"), Color(hex: "022c22")],
            startPoint: .top,
            endPoint: .bottom
        )

        // Orange background gradient (for profile/menu screens)
        static let orangeBackground = LinearGradient(
            colors: [Color(hex: "fb923c"), Color(hex: "f59e0b"), Color(hex: "d97706")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Card gradient (subtle emerald)
        static let card = LinearGradient(
            colors: [Color(hex: "065f46").opacity(0.95), Color(hex: "064e3b").opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Hero card gradient (with orange accent)
        static let heroCard = RadialGradient(
            colors: [Color(hex: "f59e0b").opacity(0.2), Color(hex: "0a4d3c").opacity(0.95)],
            center: .topLeading,
            startRadius: 0,
            endRadius: 300
        )

        // Logo gradient (yellow to emerald - Africa map colors)
        static let logo = RadialGradient(
            colors: [Color(hex: "fbbf24"), Color(hex: "f59e0b"), Color(hex: "0a4d3c")],
            center: UnitPoint(x: 0.5, y: 0.5),
            startRadius: 0,
            endRadius: 40
        )

        // Genius avatar gradient (orange tones)
        static let geniusAvatar = RadialGradient(
            colors: [Color(hex: "fbbf24"), Color(hex: "fb923c"), Color(hex: "d97706")],
            center: UnitPoint(x: 0.3, y: 0),
            startRadius: 0,
            endRadius: 36
        )

        // Profile avatar gradient (circular image background)
        static let profileAvatar = RadialGradient(
            colors: [Color(hex: "fb923c"), Color(hex: "f59e0b"), Color(hex: "d97706")],
            center: .center,
            startRadius: 0,
            endRadius: 100
        )

        // AGA logo gradient (conic)
        static let agaLogo = AngularGradient(
            colors: [Color(hex: "22c55e"), Color(hex: "facc15"), Color(hex: "0ea5e9"), Color(hex: "22c55e")],
            center: .center,
            startAngle: .degrees(180),
            endAngle: .degrees(540)
        )

        // Africa map gradient (conic green)
        static let africaMap = AngularGradient(
            colors: [Color(hex: "bbf7d0"), Color(hex: "22c55e"), Color(hex: "22c55e"), Color(hex: "a3e635"), Color(hex: "bbf7d0")],
            center: .center,
            startAngle: .degrees(160),
            endAngle: .degrees(520)
        )
    }

    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 4)
        static let large = Shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 8)
        static let card = Shadow(color: Colors.primary.opacity(0.1), radius: 20, x: 0, y: 10)
    }

    // MARK: - Typography
    struct Typography {
        // Sizes match uiref.css (converted from rem/px to points)
        static let largeTitle = Font.system(size: 28, weight: .bold, design: .default)  // 1.3rem
        static let title1 = Font.system(size: 24, weight: .bold, design: .default)  // 1.15rem
        static let title2 = Font.system(size: 20, weight: .semibold, design: .default)  // 1.1rem
        static let title3 = Font.system(size: 18, weight: .semibold, design: .default)  // 0.95rem
        static let headline = Font.system(size: 16, weight: .semibold, design: .default)  // 0.85rem
        static let body = Font.system(size: 15, weight: .regular, design: .default)  // 0.8rem
        static let callout = Font.system(size: 14, weight: .regular, design: .default)  // 0.75rem
        static let subheadline = Font.system(size: 13, weight: .regular, design: .default)  // 0.7rem
        static let footnote = Font.system(size: 12, weight: .regular, design: .default)  // 0.65rem
        static let caption = Font.system(size: 11, weight: .regular, design: .default)  // 0.6rem

        // Special styles
        static let eyebrow = Font.system(size: 11, weight: .medium, design: .default)  // 0.7rem uppercase
    }
}

// MARK: - View Modifiers
extension View {
    func eyebrowStyle() -> some View {
        self
            .font(DesignSystem.Typography.eyebrow)
            .textCase(.uppercase)
            .tracking(2.5)  // Letter spacing
            .foregroundColor(DesignSystem.Colors.accent)
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

