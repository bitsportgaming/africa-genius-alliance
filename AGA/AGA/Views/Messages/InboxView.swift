//
//  InboxView.swift
//  AGA
//
//  Created by AGA Team on 01/01/26.
//

import SwiftUI

struct InboxView: View {
    @Environment(AuthService.self) private var authService
    @State private var conversations: [APIConversation] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedConversation: APIConversation?
    
    private var currentUserId: String {
        authService.currentUser?.id ?? "currentUser"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "f9fafb").ignoresSafeArea()
                
                if isLoading && conversations.isEmpty {
                    ProgressView("Loading messages...")
                        .foregroundColor(Color(hex: "6b7280"))
                } else if let error = errorMessage, conversations.isEmpty {
                    errorView(message: error)
                } else if conversations.isEmpty {
                    emptyView
                } else {
                    conversationsList
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color(hex: "10b981"))
                    }
                }
            }
            .navigationDestination(item: $selectedConversation) { conversation in
                ChatView(conversation: conversation, currentUserId: currentUserId)
            }
        }
        .task {
            await loadConversations()
        }
    }
    
    // MARK: - Conversations List
    private var conversationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(conversations) { conversation in
                    ConversationRow(
                        conversation: conversation,
                        currentUserId: currentUserId
                    )
                    .onTapGesture {
                        selectedConversation = conversation
                    }
                    
                    Divider()
                        .padding(.leading, 76)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(16)
        }
        .refreshable {
            await loadConversations()
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "9ca3af"))
            Text("No messages yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "6b7280"))
            Text("Start a conversation with a Genius")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "9ca3af"))
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "9ca3af"))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6b7280"))
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task { await loadConversations() }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(hex: "10b981"))
            .cornerRadius(20)
        }
        .padding()
    }
    
    private func loadConversations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            conversations = try await MessagingService.shared.getConversations(userId: currentUserId)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: APIConversation
    let currentUserId: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(DesignSystem.Gradients.genius)
                .frame(width: 52, height: 52)
                .overlay(
                    Text(initials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))
                    
                    Spacer()
                    
                    Text(timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "9ca3af"))
                }
                
                HStack {
                    Text(lastMessageText)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6b7280"))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "10b981"))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    private var otherName: String {
        conversation.getOtherParticipantName(currentUserId: currentUserId)
    }
    
    private var initials: String {
        let parts = otherName.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (first + last).uppercased()
    }
    
    private var lastMessageText: String {
        conversation.lastMessage?.content ?? "No messages yet"
    }
    
    private var unreadCount: Int {
        conversation.getUnreadCount(for: currentUserId)
    }
    
    private var timeAgo: String {
        guard let timestampStr = conversation.lastMessage?.timestamp else { return "" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: timestampStr) else { return "" }
        
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "now" }
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        return "\(Int(interval / 86400))d"
    }
}

