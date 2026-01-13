//
//  AGAApp.swift
//  AGA
//
//  Created by Charles on 11/21/25.
//

import SwiftUI
import SwiftData

@main
struct AGAApp: App {
    @State private var authService = AuthService.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Post.self,
            Comment.self,
            Like.self,
            Vote.self,
            Election.self,
            Candidate.self,
            ElectionVote.self,
            Proposal.self,
            ProposalVote.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Load sample data on first launch
            let context = container.mainContext
            loadSampleDataIfNeeded(context: context)

            return container
        } catch {
            // If database is corrupted or schema changed, delete and recreate
            print("⚠️ SwiftData error: \(error). Attempting to reset database...")

            // Delete the existing store
            if let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let storeFiles = ["default.store", "default.store-shm", "default.store-wal"]
                for file in storeFiles {
                    let fileURL = storeURL.appendingPathComponent(file)
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }

            // Try again with fresh database
            do {
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                let context = container.mainContext
                loadSampleDataIfNeeded(context: context)
                print("✅ Database reset successful")
                return container
            } catch {
                fatalError("Could not create ModelContainer after reset: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environment(authService)
        }
        .modelContainer(sharedModelContainer)
    }

    // MARK: - Sample Data Loading

    private static func loadSampleDataIfNeeded(context: ModelContext) {
        // Check if data already exists
        let userDescriptor = FetchDescriptor<User>()

        do {
            let existingUsers = try context.fetch(userDescriptor)

            // Only load sample data if database is empty
            if existingUsers.isEmpty {
                print("📦 Loading sample data...")
                SampleData.loadAllSampleData(in: context)
                print("✅ Sample data loaded successfully!")
            } else {
                print("ℹ️ Sample data already exists (\(existingUsers.count) users)")
            }
        } catch {
            print("❌ Error checking for existing data: \(error)")
        }
    }
}
