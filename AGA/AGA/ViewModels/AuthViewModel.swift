//
//  AuthViewModel.swift
//  AGA
//
//  Created by AGA Team on 12/30/25.
//

import Foundation
import Combine

/// A wrapper around AuthService that provides ObservableObject conformance
/// for use with @EnvironmentObject in SwiftUI views
class AuthViewModel: ObservableObject {
    @Published var currentUser: UserInfo?
    @Published var isAuthenticated: Bool = false
    
    private var authService: AuthService?
    
    /// Initialize with an AuthService instance
    init(authService: AuthService? = nil) {
        self.authService = authService
        updateFromAuthService()
    }
    
    /// Update the view model from the auth service
    func updateFromAuthService() {
        guard let authService = authService else { return }

        if let user = authService.currentUser {
            self.currentUser = UserInfo(
                id: user.id,
                fullName: user.displayName,
                email: user.email,
                role: user.role,
                profileImageURL: user.profileImageURL
            )
            self.isAuthenticated = true
        } else {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }

    /// Convenience initializer for previews
    convenience init() {
        self.init(authService: nil)
        // Set up mock data for previews
        self.currentUser = UserInfo(
            id: "preview-user",
            fullName: "Preview User",
            email: "preview@example.com",
            role: .supporter,
            profileImageURL: nil
        )
        self.isAuthenticated = true
    }
}

/// A lightweight user info struct for the view model
struct UserInfo {
    var id: String
    var fullName: String
    var email: String
    var role: UserRole
    var profileImageURL: String?
}

