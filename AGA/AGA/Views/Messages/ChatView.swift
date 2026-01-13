//
//  ChatView.swift
//  AGA
//
//  Created by AGA Team on 01/01/26.
//

import SwiftUI

struct ChatView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    
    let conversation: APIConversation
    let currentUserId: String
    
    @State private var messages: [APIMessage] = []
    @State private var newMessage = ""
    @State private var isLoading = true
    @State private var isSending = false
    @FocusState private var isInputFocused: Bool
    
    private var otherName: String {
        conversation.getOtherParticipantName(currentUserId: currentUserId)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == currentUserId
                            )
                            .id(message.id)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Bar
            inputBar
        }
        .background(Color(hex: "f9fafb"))
        .navigationTitle(otherName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadMessages()
            await markAsRead()
        }
    }
    
    // MARK: - Input Bar
    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                TextField("Type a message...", text: $newMessage, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(hex: "f3f4f6"))
                    .cornerRadius(20)
                    .focused($isInputFocused)
                    .lineLimit(1...5)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(canSend ? Color(hex: "10b981") : Color(hex: "d1d5db"))
                        )
                }
                .disabled(!canSend || isSending)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
    }
    
    private var canSend: Bool {
        !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func loadMessages() async {
        isLoading = true
        do {
            messages = try await MessagingService.shared.getMessages(conversationId: conversation.id)
            isLoading = false
        } catch {
            print("Error loading messages: \(error)")
            isLoading = false
        }
    }
    
    private func markAsRead() async {
        try? await MessagingService.shared.markAsRead(
            conversationId: conversation.id,
            userId: currentUserId
        )
    }
    
    private func sendMessage() {
        guard canSend else { return }
        
        let content = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let senderName = authService.currentUser?.displayName ?? "You"
        
        isSending = true
        newMessage = ""
        
        Task {
            do {
                let message = try await MessagingService.shared.sendMessage(
                    conversationId: conversation.id,
                    senderId: currentUserId,
                    senderName: senderName,
                    content: content
                )
                
                await MainActor.run {
                    messages.append(message)
                    isSending = false
                }
            } catch {
                print("Error sending message: \(error)")
                await MainActor.run {
                    newMessage = content // Restore message on failure
                    isSending = false
                }
            }
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: APIMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 60) }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(isFromCurrentUser ? .white : Color(hex: "1f2937"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isFromCurrentUser
                            ? Color(hex: "10b981")
                            : Color.white
                    )
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                Text(formattedTime)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
            
            if !isFromCurrentUser { Spacer(minLength: 60) }
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.createdDate)
    }
}

// MARK: - Preview
#Preview {
    ChatView(
        conversation: APIConversation(
            _id: "1",
            participants: ["currentUser", "user1"],
            participantNames: ["You", "Amara Okonkwo"],
            participantAvatars: nil,
            lastMessage: nil,
            unreadCount: nil,
            isGroup: false,
            groupName: nil,
            createdAt: "",
            updatedAt: ""
        ),
        currentUserId: "currentUser"
    )
    .environment(AuthService.shared)
}

