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

// MARK: - UIImage Extensions

extension UIImage {
    /// Add "Africa Genius Alliance" watermark to image
    func withWatermark() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Draw original image
            draw(at: .zero)

            // Configure watermark text
            let watermarkText = "Africa Genius Alliance"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.15)
            ]

            // Calculate text size
            let attributedString = NSAttributedString(string: watermarkText, attributes: attributes)
            let textSize = attributedString.size()

            // Position watermark at bottom right
            let padding: CGFloat = 20
            let x = size.width - textSize.width - padding
            let y = size.height - textSize.height - padding
            let textRect = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)

            // Draw watermark
            watermarkText.draw(in: textRect, withAttributes: attributes)
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

// MARK: - Fluid Animation Utilities

/// Fluid spring animation presets for consistent app-wide animations
enum FluidAnimation {
    /// Quick, snappy spring for button presses and micro-interactions
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0)

    /// Smooth spring for card expansions and transitions
    static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0)

    /// Bouncy spring for playful elements and emphasis
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)

    /// Gentle spring for subtle movements
    static let gentle = Animation.spring(response: 0.6, dampingFraction: 0.85, blendDuration: 0)

    /// Quick ease for simple transitions
    static let quick = Animation.easeOut(duration: 0.2)

    /// Smooth ease for longer transitions
    static let easeSmooth = Animation.easeInOut(duration: 0.35)

    /// Interactive spring that responds to gesture velocity
    static func interactive(velocity: CGFloat = 0) -> Animation {
        .interpolatingSpring(stiffness: 300, damping: 30, initialVelocity: velocity)
    }
}

// MARK: - Press State Modifier

/// A view modifier that adds press state animation with haptic feedback
struct PressableModifier: ViewModifier {
    let scaleAmount: CGFloat
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle?
    let action: () -> Void

    @State private var isPressed = false

    init(
        scale: CGFloat = 0.97,
        haptic: UIImpactFeedbackGenerator.FeedbackStyle? = .light,
        action: @escaping () -> Void
    ) {
        self.scaleAmount = scale
        self.hapticStyle = haptic
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scaleAmount : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(FluidAnimation.snappy, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            if let style = hapticStyle {
                                HapticFeedback.impact(style)
                            }
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}

extension View {
    /// Add press state animation with optional haptic feedback
    func pressable(
        scale: CGFloat = 0.97,
        haptic: UIImpactFeedbackGenerator.FeedbackStyle? = .light,
        action: @escaping () -> Void = {}
    ) -> some View {
        self.modifier(PressableModifier(scale: scale, haptic: haptic, action: action))
    }

    /// Add simple press scale effect without action
    func pressableStyle(scale: CGFloat = 0.97) -> some View {
        self.modifier(PressScaleModifier(scale: scale))
    }
}

struct PressScaleModifier: ViewModifier {
    let scale: CGFloat
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(FluidAnimation.snappy, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Scroll Fluid Effects

/// Modifier for scroll-aware opacity and scale
struct ScrollFadeModifier: ViewModifier {
    let threshold: CGFloat
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        let opacityValue: Double = max(0, min(1, Double(1.0 - (offset / threshold))))
        return content
            .opacity(opacityValue)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geo.frame(in: .named("scroll")).minY
                    )
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                offset = -value
            }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    /// Fade out as user scrolls down
    func scrollFade(threshold: CGFloat = 100) -> some View {
        self.modifier(ScrollFadeModifier(threshold: threshold))
    }
}

// MARK: - Staggered Animation Modifier

struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(
                FluidAnimation.smooth.delay(Double(index) * baseDelay),
                value: isVisible
            )
            .onAppear {
                isVisible = true
            }
    }
}

extension View {
    /// Staggered appearance animation for list items
    func staggeredAppear(index: Int, baseDelay: Double = 0.05) -> some View {
        self.modifier(StaggeredAppearModifier(index: index, baseDelay: baseDelay))
    }
}

// MARK: - Smooth Scroll Snap

struct ScrollSnapModifier: ViewModifier {
    let itemWidth: CGFloat
    let spacing: CGFloat

    func body(content: Content) -> some View {
        content
            .scrollTargetLayout()
    }
}

// MARK: - Parallax Effect

struct ParallaxModifier: ViewModifier {
    let amount: CGFloat
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(y: offset * amount)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geo.frame(in: .global).minY
                    )
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                offset = value / 100
            }
    }
}

extension View {
    /// Add parallax scrolling effect
    func parallax(amount: CGFloat = 0.3) -> some View {
        self.modifier(ParallaxModifier(amount: amount))
    }
}

// MARK: - Rubber Band Effect

struct RubberBandModifier: ViewModifier {
    @State private var dragOffset: CGFloat = 0
    let resistance: CGFloat

    init(resistance: CGFloat = 0.5) {
        self.resistance = resistance
    }

    func body(content: Content) -> some View {
        content
            .offset(y: rubberBand(offset: dragOffset))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { _ in
                        withAnimation(FluidAnimation.bouncy) {
                            dragOffset = 0
                        }
                    }
            )
    }

    private func rubberBand(offset: CGFloat) -> CGFloat {
        let sign = offset >= 0 ? 1.0 : -1.0
        let absOffset = abs(offset)
        return sign * (1 - (1 / (absOffset * resistance / 100 + 1))) * 100
    }
}

extension View {
    /// Add rubber band overscroll effect
    func rubberBand(resistance: CGFloat = 0.5) -> some View {
        self.modifier(RubberBandModifier(resistance: resistance))
    }
}

// MARK: - Smooth Scale on Scroll

struct ScaleOnScrollModifier: ViewModifier {
    let minScale: CGFloat
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geo.frame(in: .named("scroll")).minY
                    )
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let progress = max(0, min(1, value / 200))
                withAnimation(FluidAnimation.quick) {
                    scale = minScale + (1 - minScale) * progress
                }
            }
    }
}

extension View {
    /// Scale down as element scrolls up
    func scaleOnScroll(minScale: CGFloat = 0.8) -> some View {
        self.modifier(ScaleOnScrollModifier(minScale: minScale))
    }
}

// MARK: - Smooth Transition Helpers

extension AnyTransition {
    /// Smooth scale and fade transition
    static var smoothScale: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        )
    }

    /// Slide from bottom with fade
    static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }

    /// Slide from right with fade
    static var slideFromTrailing: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

