//
//  ComposeMessageView.swift
//  AGA
//
//  Created by AGA Team on 02/08/26.
//

import SwiftUI

struct ComposeMessageView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [TrendingGenius] = []
    @State private var isSearching = false
    @State private var isCreatingConversation = false
    @State private var errorMessage: String?
    
    var onConversationCreated: (APIConversation) -> Void
    
    private var currentUserId: String {
        authService.currentUser?.id ?? ""
    }
    
    private var currentUserName: String {
        authService.currentUser?.displayName ?? "You"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Content
                if isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    errorView(message: error)
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    emptyResultsView
                } else if searchResults.isEmpty {
                    promptView
                } else {
                    searchResultsList
                }
            }
            .background(Color(hex: "f9fafb"))
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "10b981"))
                }
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(hex: "9ca3af"))

            TextField("Search by name or username...", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundColor(Color(hex: "1f2937"))
                .tint(Color(hex: "10b981"))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: searchText) { _, newValue in
                    performSearch(query: newValue)
                }

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "9ca3af"))
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "e5e7eb"), lineWidth: 1)
        )
        .padding(16)
    }
    
    // MARK: - Search Results List
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchResults, id: \.id) { user in
                    UserSearchRow(user: user, isLoading: isCreatingConversation)
                        .onTapGesture {
                            selectUser(user)
                        }
                    
                    Divider()
                        .padding(.leading, 76)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Empty/Prompt Views
    private var promptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "d1d5db"))
            
            Text("Search for someone to message")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "6b7280"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.slash.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "d1d5db"))
            
            Text("No users found")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "6b7280"))
            
            Text("Try a different search term")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "9ca3af"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "ef4444"))

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6b7280"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Actions
    private func performSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }

        Task {
            isSearching = true
            errorMessage = nil

            do {
                let results = try await GeniusAPIService.shared.searchGeniuses(query: trimmed, limit: 20)
                // Filter out current user from results
                searchResults = results.filter { $0.id != currentUserId }
                isSearching = false
            } catch {
                errorMessage = "Search failed: \(error.localizedDescription)"
                isSearching = false
            }
        }
    }

    private func selectUser(_ user: TrendingGenius) {
        guard !isCreatingConversation else { return }

        isCreatingConversation = true
        errorMessage = nil

        Task {
            do {
                let conversation = try await MessagingService.shared.createConversation(
                    participants: [currentUserId, user.id],
                    participantNames: [currentUserName, user.name]
                )

                await MainActor.run {
                    isCreatingConversation = false
                    dismiss()
                    onConversationCreated(conversation)
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to start conversation: \(error.localizedDescription)"
                    isCreatingConversation = false
                }
            }
        }
    }
}

// MARK: - User Search Row
struct UserSearchRow: View {
    let user: TrendingGenius
    let isLoading: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let avatarURL = user.avatarURL, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    avatarPlaceholder
                }
                .frame(width: 52, height: 52)
                .clipShape(Circle())
            } else {
                avatarPlaceholder
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))

                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "10b981"))
                    }
                }

                if !user.positionTitle.isEmpty {
                    Text(user.positionTitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6b7280"))
                        .lineLimit(1)
                }

                if !user.country.isEmpty {
                    Text(user.country)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "9ca3af"))
                }
            }

            Spacer()

            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "d1d5db"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .contentShape(Rectangle())
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(DesignSystem.Gradients.genius)
            .frame(width: 52, height: 52)
            .overlay(
                Text(initials)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            )
    }

    private var initials: String {
        let parts = user.name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (first + last).uppercased()
    }
}

