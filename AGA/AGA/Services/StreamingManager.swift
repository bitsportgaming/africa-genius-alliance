//
//  StreamingManager.swift
//  AGA
//
//  Manages live streaming state and signaling
//  Uses polling for now - can be upgraded to WebRTC later
//

import Foundation
import Combine
import AVFoundation

// MARK: - Streaming Manager
class StreamingManager: NSObject, ObservableObject {
    static let shared = StreamingManager()
    
    // Published state
    @Published var isStreaming = false
    @Published var isWatching = false
    @Published var currentStreamId: String?
    @Published var viewerCount: Int = 0
    @Published var error: String?
    
    // Polling timer for viewer updates
    private var pollingTimer: Timer?
    private let pollingInterval: TimeInterval = 3.0
    
    private let liveStreamService = LiveStreamService.shared
    
    // Callbacks
    var onStreamEnded: (() -> Void)?
    var onViewerCountUpdated: ((Int) -> Void)?
    
    override private init() {
        super.init()
    }
    
    // MARK: - Broadcasting (Host)
    func startBroadcast(
        hostId: String,
        hostName: String,
        hostAvatar: String?,
        hostPosition: String?,
        title: String,
        description: String?
    ) async throws -> APILiveStream {
        let stream = try await liveStreamService.startStream(
            hostId: hostId,
            hostName: hostName,
            hostAvatar: hostAvatar,
            hostPosition: hostPosition,
            title: title,
            description: description
        )
        
        await MainActor.run {
            self.currentStreamId = stream.id
            self.isStreaming = true
            self.viewerCount = stream.viewerCount
        }
        
        // Start polling for viewer count updates
        startPolling()
        
        return stream
    }
    
    func endBroadcast() async throws {
        guard let streamId = currentStreamId else { return }
        
        _ = try await liveStreamService.stopStream(streamId: streamId)
        
        await MainActor.run {
            self.stopPolling()
            self.isStreaming = false
            self.currentStreamId = nil
            self.viewerCount = 0
        }
    }
    
    // MARK: - Viewing
    func joinStream(streamId: String, userId: String) async throws -> APILiveStream {
        let stream = try await liveStreamService.joinStream(streamId: streamId, userId: userId)
        
        await MainActor.run {
            self.currentStreamId = streamId
            self.isWatching = true
            self.viewerCount = stream.viewerCount
        }
        
        // Start polling to check if stream is still active
        startPolling()
        
        return stream
    }
    
    func leaveStream(userId: String) async throws {
        guard let streamId = currentStreamId else { return }
        
        _ = try await liveStreamService.leaveStream(streamId: streamId, userId: userId)
        
        await MainActor.run {
            self.stopPolling()
            self.isWatching = false
            self.currentStreamId = nil
        }
    }
    
    // MARK: - Polling
    private func startPolling() {
        stopPolling()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.pollingTimer = Timer.scheduledTimer(withTimeInterval: self.pollingInterval, repeats: true) { [weak self] _ in
                self?.pollStreamStatus()
            }
        }
    }
    
    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    private func pollStreamStatus() {
        guard let streamId = currentStreamId else { return }
        
        Task {
            do {
                if let stream = try await liveStreamService.getStream(id: streamId) {
                    await MainActor.run {
                        if stream.status == "ended" {
                            self.handleStreamEnded()
                        } else {
                            self.viewerCount = stream.viewerCount
                            self.onViewerCountUpdated?(stream.viewerCount)
                        }
                    }
                } else {
                    await MainActor.run { self.handleStreamEnded() }
                }
            } catch {
                print("Polling error: \(error)")
            }
        }
    }
    
    private func handleStreamEnded() {
        stopPolling()
        isWatching = false
        isStreaming = false
        currentStreamId = nil
        onStreamEnded?()
    }
}

