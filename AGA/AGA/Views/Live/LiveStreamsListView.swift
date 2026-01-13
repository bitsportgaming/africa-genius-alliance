//
//  LiveStreamsListView.swift
//  AGA
//
//  List of active live streams for supporters to browse
//
//  Created by AGA Team on 01/01/26.
//

import SwiftUI

struct LiveStreamsListView: View {
    @State private var streams: [APILiveStream] = []
    @State private var isLoading = true
    @State private var selectedStream: APILiveStream?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "f9fafb").ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else if streams.isEmpty {
                    emptyState
                } else {
                    streamsList
                }
            }
            .navigationTitle("Live Now")
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await loadStreams() }
            .fullScreenCover(item: $selectedStream) { stream in
                LiveStreamViewerView(stream: stream)
            }
        }
        .task { await loadStreams() }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.slash")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "9ca3af"))
            
            Text("No Live Streams")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "1f2937"))
            
            Text("Check back later to see geniuses streaming live")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "6b7280"))
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
    
    // MARK: - Streams List
    private var streamsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(streams) { stream in
                    LiveStreamCard(stream: stream)
                        .onTapGesture { selectedStream = stream }
                }
            }
            .padding(16)
        }
    }
    
    // MARK: - Load Streams
    private func loadStreams() async {
        do {
            let fetched = try await LiveStreamService.shared.getActiveStreams()
            await MainActor.run {
                streams = fetched
                isLoading = false
            }
        } catch {
            print("Error loading streams: \(error)")
            await MainActor.run { isLoading = false }
        }
    }
}

// MARK: - Live Stream Card
struct LiveStreamCard: View {
    let stream: APILiveStream
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [Color(hex: "1e293b"), Color(hex: "334155")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 180)
                
                // Live badge
                VStack {
                    HStack {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: "ef4444"))
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                        
                        Spacer()
                        
                        // Viewers
                        HStack(spacing: 4) {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 10))
                            Text("\(stream.viewerCount)")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    }
                    .padding(12)
                    
                    Spacer()
                }
                
                // Play icon
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Host info
            HStack(spacing: 10) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "10b981"), Color(hex: "059669")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(initials(from: stream.hostName))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(stream.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1f2937"))
                        .lineLimit(1)
                    
                    Text(stream.hostName)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6b7280"))
                }
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

