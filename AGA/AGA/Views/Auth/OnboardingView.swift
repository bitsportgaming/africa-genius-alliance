//
//  OnboardingView.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AuthService.self) private var authService
    @State private var navigateToSignUp = false
    @State private var navigateToLogin = false
    @State private var selectedRole: UserRole?
    @State private var animateContent = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Deep emerald green background
                Color(hex: "0a4d3c")
                    .ignoresSafeArea()

                // Subtle pattern overlay (optional decorative element)
                GeometryReader { geometry in
                    // Decorative circles in background
                    Circle()
                        .stroke(Color.white.opacity(0.03), lineWidth: 1)
                        .frame(width: 300, height: 300)
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.15)

                    Circle()
                        .stroke(Color.white.opacity(0.02), lineWidth: 1)
                        .frame(width: 200, height: 200)
                        .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3)
                }

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 60)

                    // Logo and Title Section
                    HStack(alignment: .center, spacing: 16) {
                        // Africa map logo
                        Image("Aga")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 120)

                        // Title text
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Africa")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "d4a853")) // Golden color
                            Text("Genius")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "d4a853"))
                            Text("Alliance")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "d4a853"))
                        }
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : -20)

                    Spacer()
                        .frame(height: 60)

                    // Buttons Section
                    VStack(spacing: 20) {
                        // "I am a Genius" button - cream/beige filled
                        Button(action: {
                            selectedRole = .genius
                            navigateToSignUp = true
                        }) {
                            Text("I am a Genius")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "1a1a1a"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "f5f0e1")) // Cream/beige
                                )
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                        // "I am a Supporter" button - text only
                        Button(action: {
                            selectedRole = .regular
                            navigateToSignUp = true
                        }) {
                            Text("I am a Supporter")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "f5f0e1"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)

                        // Login option for existing users
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            HStack(spacing: 6) {
                                Text("Already have an account?")
                                    .foregroundColor(Color(hex: "f5f0e1").opacity(0.7))
                                Text("Log In")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "f59e0b")) // Golden orange
                            }
                            .font(.system(size: 15))
                        }
                        .padding(.top, 8)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 35)
                    }
                    .padding(.horizontal, 40)

                    Spacer()

                    // Bottom avatar section with play button
                    ZStack(alignment: .bottomTrailing) {
                        // Avatar image - try onboarding_08 first, fallback to avatar_female
                        Image("onboarding_08")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 280)
                            .clipped()
                            .mask(
                                LinearGradient(
                                    colors: [.clear, .black.opacity(0.3), .black],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )

                        // Play button
                        Button(action: {
                            // Play intro video action
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "f59e0b"))
                                    .frame(width: 56, height: 56)

                                Image(systemName: "play.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color(hex: "0a4d3c"))
                                    .offset(x: 2) // Slight offset for visual centering
                            }
                        }
                        .offset(x: -30, y: -40)
                        .opacity(animateContent ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                    animateContent = true
                }
            }
            .navigationDestination(isPresented: $navigateToSignUp) {
                ModernSignUpView(initialRole: selectedRole ?? .regular)
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AuthService.shared)
}

