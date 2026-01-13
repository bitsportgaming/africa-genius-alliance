//
//  Extensions.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Date Extensions

extension Date {
    var timeAgoDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - String Extensions

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - View Extensions

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Add a card style with shadow
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.adaptiveSurface)
            .cornerRadius(AppConstants.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }

    /// Add haptic feedback on tap
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: style)
            impact.impactOccurred()
        }
    }

    /// Shimmer loading effect
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }

    /// Bounce animation on appear
    func bounceOnAppear() -> some View {
        self.modifier(BounceModifier())
    }

    /// Fade in animation
    func fadeIn(duration: Double = 0.5, delay: Double = 0) -> some View {
        self.modifier(FadeInModifier(duration: duration, delay: delay))
    }

    /// Slide in from bottom
    func slideInFromBottom(duration: Double = 0.5, delay: Double = 0) -> some View {
        self.modifier(SlideInModifier(duration: duration, delay: delay))
    }
}

// MARK: - Animation Modifiers

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

struct BounceModifier: ViewModifier {
    @State private var scale: CGFloat = 0.8

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
    }
}

struct FadeInModifier: ViewModifier {
    let duration: Double
    let delay: Double
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    opacity = 1.0
                }
            }
    }
}

struct SlideInModifier: ViewModifier {
    let duration: Double
    let delay: Double
    @State private var offset: CGFloat = 50
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: duration, dampingFraction: 0.8).delay(delay)) {
                    offset = 0
                    opacity = 1.0
                }
            }
    }
}

// MARK: - Haptic Feedback Helper

enum HapticFeedback {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

