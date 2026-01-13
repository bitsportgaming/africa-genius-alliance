//
//  FeedView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI
import SwiftData

struct FeedView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: FeedViewModel?
    @State private var showCreatePost = false
    
    private let authService = AuthService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.isLoading {
                        ProgressView("Loading feed...")
                    } else if viewModel.posts.isEmpty {
                        emptyStateView
                    } else {
                        feedListView(viewModel: viewModel)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("AGA")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if authService.canCreatePost() {
                        Button {
                            showCreatePost = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = FeedViewModel(modelContext: modelContext)
                }
                Task {
                    await viewModel?.loadFeed()
                }
            }
            .refreshable {
                await viewModel?.refreshFeed()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Posts Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Be the first to share something!")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if authService.canCreatePost() {
                Button("Create Post") {
                    showCreatePost = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private func feedListView(viewModel: FeedViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    PostCardView(post: post, viewModel: viewModel)
                }
            }
            .padding()
        }
    }
}

#Preview {
    FeedView()
        .modelContainer(for: [Post.self, User.self, Comment.self, Like.self, Vote.self], inMemory: true)
}

