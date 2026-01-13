//
//  CreatePostView.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import SwiftUI
import SwiftData

struct CreatePostView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: PostViewModel?
    @State private var showError = false
    
    private let authService = AuthService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // User Info
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text(authService.currentUser?.displayName ?? "User")
                                        .fontWeight(.semibold)
                                    
                                    if authService.currentUser?.isGenius == true {
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .font(.caption)
                                            Text("Genius")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.yellow)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Content TextField
                            TextEditor(text: Binding(
                                get: { viewModel.content },
                                set: { viewModel.content = $0 }
                            ))
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                            
                            // Image Previews
                            if !viewModel.selectedImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, imageURL in
                                            ZStack(alignment: .topTrailing) {
                                                AsyncImage(url: URL(string: imageURL)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } placeholder: {
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.3))
                                                }
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                
                                                Button {
                                                    viewModel.removeImage(at: index)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                                }
                                                .padding(4)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Add Image Button
                            Button {
                                // TODO: Implement image picker
                                viewModel.addImage("https://via.placeholder.com/400")
                            } label: {
                                Label("Add Image", systemImage: "photo")
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        Task {
                            await createPost()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel?.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = PostViewModel(modelContext: modelContext)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel?.errorMessage ?? "Failed to create post")
            }
        }
    }
    
    private func createPost() async {
        guard let viewModel, let user = authService.currentUser else { return }
        
        do {
            try await viewModel.createPost(by: user)
            dismiss()
        } catch {
            showError = true
        }
    }
}

#Preview {
    CreatePostView()
        .modelContainer(for: [Post.self, User.self], inMemory: true)
}

