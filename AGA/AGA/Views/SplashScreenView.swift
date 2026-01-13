//
//  SplashScreenView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI

struct SplashScreenView: View {
    @Environment(AuthService.self) private var authService
    @State private var isActive = false
    @State private var showOnboarding = false
    @State private var opacity = 0.0
    @State private var scale = 0.8

    var body: some View {
        if isActive {
            // Main app content based on authentication
            if authService.isAuthenticated {
                if authService.needsGeniusOnboarding {
                    // Genius needs to complete onboarding
                    GeniusOnboardingView()
                } else {
                    MainTabView()
                }
            } else {
                OnboardingView()
            }
        } else if showOnboarding {
            // Welcome screen with "Get Started" button
            WelcomeView(onGetStarted: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isActive = true
                }
            })
        } else {
            ZStack {
                // Background color to match image edges
                Color.black
                    .ignoresSafeArea()

                // Full screen splash image - scaledToFit to prevent cropping
                Image("splash_01")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Overlay content for animation
                VStack {
                    Spacer()

                    // Animated logo overlay (subtle)
                    Image("Aga")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .scaleEffect(scale)
                        .opacity(opacity * 0.8)

                    Spacer()
                    Spacer()
                }
            }
            .ignoresSafeArea()
            .onAppear {
                // Animate logo
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    scale = 1.0
                }

                withAnimation(.easeIn(duration: 0.6)) {
                    opacity = 1.0
                }

                // Show welcome screen after splash
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showOnboarding = true
                    }
                }
            }
        }
    }
}

// MARK: - Welcome View (Get Started Screen)
struct WelcomeView: View {
    let onGetStarted: () -> Void
    @State private var animateContent = false

    var body: some View {
        ZStack {
            // Background color to match image edges
            Color.black
                .ignoresSafeArea()

            // Full screen splash image
            Image("splash_aga")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            // Semi-transparent overlay for better button visibility
            VStack {
                Spacer()

                // Get Started button (orange) at bottom
                Button(action: onGetStarted) {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "0a4d3c"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(hex: "f59e0b"))
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 40)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 30)

                Spacer()
                    .frame(height: 80)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateContent = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}

