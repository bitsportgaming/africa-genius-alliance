//
//  LoginView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSignUp = false
    @State private var animateContent = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient Background
                DesignSystem.Gradients.primary
                    .ignoresSafeArea()

                // Floating circles decoration
                GeometryReader { geometry in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .offset(x: -50, y: -100)
                        .blur(radius: 20)

                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 150, height: 150)
                        .offset(x: geometry.size.width - 100, y: geometry.size.height - 150)
                        .blur(radius: 20)
                }

                ScrollView {
                    VStack(spacing: 32) {
                        Spacer()
                            .frame(height: 60)

                        // Logo and Title
                        VStack(spacing: 16) {
                            Image("agas")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)

                            Text("Welcome Back")
                                .font(DesignSystem.Typography.largeTitle)
                                .fontWeight(.black)
                                .foregroundColor(.white)

                            Text("Sign in to continue your journey")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)

                        // Login Card
                        VStack(spacing: 24) {
                            VStack(spacing: 16) {
                                ModernTextField("Email", text: $email, icon: "envelope.fill")
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()

                                ModernTextField("Password", text: $password, icon: "lock.fill", isSecure: true)
                            }

                            if let errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text(errorMessage)
                                        .font(DesignSystem.Typography.footnote)
                                }
                                .foregroundColor(DesignSystem.Colors.error)
                                .padding(.horizontal)
                            }

                            ModernButton("Sign In", icon: "arrow.right", style: .accent) {
                                Task {
                                    await signIn()
                                }
                            }
                            .disabled(isLoading || email.isEmpty || password.isEmpty)
                            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)

                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .padding(AppConstants.largePadding)
                        .background(
                            RoundedRectangle(cornerRadius: AppConstants.largeCornerRadius)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal, AppConstants.padding)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)

                        // Sign Up Link
                        Button {
                            showSignUp = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Sign Up")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .font(DesignSystem.Typography.callout)
                        }
                        .opacity(animateContent ? 1 : 0)

                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                ModernSignUpView()
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                    animateContent = true
                }
            }
        }
    }
    
    private func signIn() async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await AuthService.shared.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    LoginView()
}

