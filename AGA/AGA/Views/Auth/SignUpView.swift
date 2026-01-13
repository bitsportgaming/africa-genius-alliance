//
//  SignUpView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole = .regular
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // Username
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                // Display Name
                TextField("Display Name", text: $displayName)
                    .textFieldStyle(.roundedBorder)
                
                // Email
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                
                // Password
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                // Confirm Password
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                
                // Role Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select Your Role")
                        .font(.headline)

                    Picker("Role", selection: $selectedRole) {
                        ForEach(UserRole.signupRoles, id: \.self) { role in
                            HStack {
                                Text(role.displayName)
                                if role == .genius {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            .tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if selectedRole == .genius {
                        Text("Geniuses can create posts and interact with content")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Users can comment, like, vote, and share posts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical)
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                // Sign Up Button
                Button {
                    Task {
                        await signUp()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || !isFormValid)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !displayName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
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

#Preview {
    NavigationStack {
        SignUpView()
    }
}

