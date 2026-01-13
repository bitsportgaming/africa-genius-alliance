//
//  Config.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation

enum Config {
    // MARK: - Backend Configuration

    // Production API (Africa Genius Alliance)
    static let apiBaseURL = "https://africageniusalliance.com/api"
    static let socketURL = "https://africageniusalliance.com"

    // For local development - uncomment these and comment production URLs above:
    // static let apiBaseURL = "http://192.168.1.128:3000/api"
    // static let socketURL = "http://192.168.1.128:3000"
    // For simulator only:
    // static let apiBaseURL = "http://localhost:3000/api"
    // static let socketURL = "http://localhost:3000"

    static let supabaseURL = "https://your-project.supabase.co"
    static let supabaseAnonKey = "your-anon-key-here"

    // MARK: - Feature Flags

    static let enableBackendSync = true
    static let enablePushNotifications = false
    static let enableAnalytics = false

    // MARK: - Development

    static let isDevelopment: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    static let useMockData = !enableBackendSync

    // MARK: - Upload Configuration
    static let maxImageSize: Int = 10 * 1024 * 1024  // 10MB
    static let maxVideoSize: Int = 50 * 1024 * 1024  // 50MB
}

