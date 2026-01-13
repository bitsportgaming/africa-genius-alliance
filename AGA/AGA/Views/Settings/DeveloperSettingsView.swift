//
//  DeveloperSettingsView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI
import SwiftData

struct DeveloperSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showClearDataAlert = false
    @State private var showSampleDataAlert = false
    @State private var actionMessage: String?
    
    var body: some View {
        NavigationStack {
            List {
                Section("Data Management") {
                    Button {
                        showSampleDataAlert = true
                    } label: {
                        Label("Load Sample Data", systemImage: "tray.and.arrow.down")
                    }
                    
                    Button(role: .destructive) {
                        showClearDataAlert = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                }
                
                Section("App Info") {
                    LabeledContent("App Name", value: AppConstants.appName)
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")
                    LabeledContent("Environment", value: Config.isDevelopment ? "Development" : "Production")
                }
                
                Section("Feature Flags") {
                    LabeledContent("Backend Sync", value: Config.enableBackendSync ? "Enabled" : "Disabled")
                    LabeledContent("Push Notifications", value: Config.enablePushNotifications ? "Enabled" : "Disabled")
                    LabeledContent("Analytics", value: Config.enableAnalytics ? "Enabled" : "Disabled")
                }
                
                if let actionMessage {
                    Section {
                        Text(actionMessage)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Developer Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Load Sample Data", isPresented: $showSampleDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Load") {
                    loadSampleData()
                }
            } message: {
                Text("This will create sample users, posts, and comments for testing.")
            }
            .alert("Clear All Data", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all data. This action cannot be undone.")
            }
        }
    }
    
    private func loadSampleData() {
        SampleData.createSampleData(in: modelContext)
        actionMessage = "✅ Sample data loaded successfully"
        
        // Clear message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            actionMessage = nil
        }
    }
    
    private func clearAllData() {
        SampleData.clearAllData(in: modelContext)
        actionMessage = "✅ All data cleared successfully"
        
        // Clear message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            actionMessage = nil
        }
    }
}

#Preview {
    DeveloperSettingsView()
        .modelContainer(for: [User.self, Post.self], inMemory: true)
}

