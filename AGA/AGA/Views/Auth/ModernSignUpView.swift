//
//  ModernSignUpView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI

struct ModernSignUpView: View {
    @Environment(\.dismiss) private var dismiss

    // Accept initial role from onboarding
    var initialRole: UserRole = .regular

    @State private var username = ""
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole = .regular
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            DesignSystem.Gradients.accent
                .ignoresSafeArea()
            
            // Floating circles decoration
            GeometryReader { geometry in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 180, height: 180)
                    .offset(x: geometry.size.width - 120, y: -50)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .offset(x: -30, y: geometry.size.height - 100)
                    .blur(radius: 20)
            }
            
            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)

                        // Logo
                        Image("agas")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)

                        Text("Join AGA")
                            .font(DesignSystem.Typography.largeTitle)
                            .fontWeight(.black)
                            .foregroundColor(.white)

                        Text("Become part of the genius community")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : -20)
                    
                    // Form Card
                    VStack(spacing: 20) {
                        VStack(spacing: 16) {
                            ModernTextField("Username", text: $username, icon: "person.fill")
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            
                            ModernTextField("Display Name", text: $displayName, icon: "person.text.rectangle.fill")
                            
                            ModernTextField("Email", text: $email, icon: "envelope.fill")
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                            
                            ModernTextField("Password", text: $password, icon: "lock.fill", isSecure: true)
                            
                            ModernTextField("Confirm Password", text: $confirmPassword, icon: "lock.shield.fill", isSecure: true)
                        }
                        
                        // Role Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Your Role")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(Color(hex: "1f2937")) // Dark text for visibility

                            HStack(spacing: 12) {
                                RoleCard(
                                    role: .genius,
                                    isSelected: selectedRole == .genius,
                                    action: { selectedRole = .genius }
                                )

                                RoleCard(
                                    role: .regular,
                                    isSelected: selectedRole == .regular,
                                    action: { selectedRole = .regular }
                                )
                            }

                            Text(selectedRole == .genius ?
                                 "✨ Create posts and engage with the community" :
                                 "💬 Comment, like, vote and share genius content")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(Color(hex: "4b5563")) // Muted dark text
                                .padding(.top, 4)
                        }
                        
                        if let errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(errorMessage)
                                    .font(DesignSystem.Typography.footnote)
                            }
                            .foregroundColor(DesignSystem.Colors.error)
                        }

                        // Validation hint
                        if !isFormValid && !username.isEmpty {
                            Text(validationHint)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(Color(hex: "dc2626"))
                                .padding(.horizontal, 4)
                        }

                        ModernButton("Create Account", icon: "checkmark.circle.fill", style: .genius) {
                            Task {
                                await signUp()
                            }
                        }
                        .disabled(isLoading || !isFormValid)
                        
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .padding(AppConstants.largePadding)
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.largeCornerRadius)
                            .fill(Color(hex: "f59e0b").opacity(0.85)) // Warm amber background
                    )
                    .padding(.horizontal, AppConstants.padding)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Set the selected role from initial role passed from onboarding
            selectedRole = initialRole

            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }

    private var isFormValid: Bool {
        !username.isEmpty &&
        !displayName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= AppConstants.minPasswordLength
    }

    private var validationHint: String {
        if displayName.isEmpty { return "Please enter your display name" }
        if email.isEmpty { return "Please enter your email" }
        if password.isEmpty { return "Please enter a password" }
        if password.count < AppConstants.minPasswordLength { return "Password must be at least \(AppConstants.minPasswordLength) characters" }
        if password != confirmPassword { return "Passwords do not match" }
        return ""
    }

    private func signUp() async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await AuthService.shared.signUp(
                username: username,
                email: email,
                password: password,
                displayName: displayName,
                role: selectedRole
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Role Card Component (Redesigned with checkmark)
struct RoleCard: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void

    private var roleIcon: String {
        role == .genius ? "star.fill" : "heart.fill"
    }

    private var roleTitle: String {
        role == .genius ? "Genius" : "Supporter"
    }

    private var roleSubtitle: String {
        role == .genius ? "Create & Lead" : "Vote & Support"
    }

    private var selectedColor: Color {
        role == .genius ? Color(hex: "10b981") : Color(hex: "3b82f6")
    }

    var body: some View {
        Button(action: {
            HapticFeedback.impact(.light)
            action()
        }) {
            VStack(spacing: 8) {
                // Checkmark indicator at top right
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(isSelected ? selectedColor : Color(hex: "d1d5db"), lineWidth: 2)
                            .frame(width: 24, height: 24)

                        if isSelected {
                            Circle()
                                .fill(selectedColor)
                                .frame(width: 24, height: 24)

                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? selectedColor.opacity(0.15) : Color(hex: "f3f4f6"))
                        .frame(width: 56, height: 56)

                    Image(systemName: roleIcon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? selectedColor : Color(hex: "9ca3af"))
                }

                // Title
                Text(roleTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? Color(hex: "1f2937") : Color(hex: "6b7280"))

                // Subtitle
                Text(roleSubtitle)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color(hex: "4b5563") : Color(hex: "9ca3af"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? selectedColor : Color(hex: "e5e7eb"), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? selectedColor.opacity(0.2) : Color.black.opacity(0.03), radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    NavigationStack {
        ModernSignUpView()
    }
}

