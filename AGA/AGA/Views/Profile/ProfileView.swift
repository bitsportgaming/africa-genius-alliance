//
//  ProfileView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    var body: some View {
        ModernProfileView()
    }
}

// Keep old implementation for reference
struct LegacyProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var posts: [Post]

    private let authService = AuthService.shared

    @State private var showRoleSelector = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                    
                    if let user = authService.currentUser {
                        Text(user.displayName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Role Badge
                        HStack(spacing: 8) {
                            if user.role.isAdmin {
                                // Gold checkmark for admin/superadmin
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color(hex: "FFD700"))
                            } else if user.isGenius {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                            Text(user.role.displayName)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(user.role.isAdmin ? Color(hex: "FFD700").opacity(0.2) : (user.isGenius ? Color.yellow.opacity(0.2) : Color.blue.opacity(0.2)))
                        .clipShape(Capsule())
                        
                        if let bio = user.bio {
                            Text(bio)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        
                        // Stats
                        HStack(spacing: 40) {
                            VStack {
                                Text("\(userPosts.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Posts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(user.followersCount)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Followers")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(user.followingCount)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Following")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
                
                Divider()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        showRoleSelector = true
                    } label: {
                        Label("Change Role", systemImage: "person.badge.key")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        authService.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                
                Divider()
                
                // User's Posts
                if !userPosts.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("My Posts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 16) {
                            ForEach(userPosts) { post in
                                PostPreviewCard(post: post)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Select Role", isPresented: $showRoleSelector) {
            ForEach(UserRole.allCases, id: \.self) { role in
                Button(role.displayName) {
                    authService.updateUserRole(to: role)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose your role in the AGA community")
        }
    }
    
    private var userPosts: [Post] {
        guard let userId = authService.currentUser?.id else { return [] }
        return posts.filter { $0.author?.id == userId }
            .sorted { $0.createdAt > $1.createdAt }
    }
}

struct PostPreviewCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.content)
                .font(.body)
                .lineLimit(3)
            
            HStack {
                Label("\(post.likesCount)", systemImage: "heart")
                Label("\(post.commentsCount)", systemImage: "bubble.right")
                Label("\(post.votesCount)", systemImage: "arrow.up.arrow.down")
                
                Spacer()
                
                Text(post.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .modelContainer(for: [Post.self, User.self], inMemory: true)
    }
}

