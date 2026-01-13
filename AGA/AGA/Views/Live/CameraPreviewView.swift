//
//  CameraPreviewView.swift
//  AGA
//
//  Camera preview for live streaming
//
//  Created by AGA Team on 01/01/26.
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Camera Manager
class CameraManager: NSObject, ObservableObject {
    @Published var permissionGranted = false
    @Published var isSessionRunning = false
    @Published var error: String?
    
    let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        case .denied, .restricted:
            permissionGranted = false
            error = "Camera access denied. Please enable in Settings."
        @unknown default:
            break
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            error = "No front camera available"
            session.commitConfiguration()
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
        } catch {
            self.error = "Failed to setup camera: \(error.localizedDescription)"
            session.commitConfiguration()
            return
        }
        
        // Add audio input
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if session.canAddInput(audioInput) {
                    session.addInput(audioInput)
                }
            } catch {
                print("Could not add audio input: \(error)")
            }
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = self?.session.isRunning ?? false
            }
        }
    }
    
    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = false
            }
        }
    }
    
    func switchCamera() {
        session.beginConfiguration()
        
        // Remove current input
        if let currentInput = session.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) == true }) as? AVCaptureDeviceInput {
            session.removeInput(currentInput)
            
            // Get new camera position
            let newPosition: AVCaptureDevice.Position = currentInput.device.position == .front ? .back : .front
            
            if let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
               let newInput = try? AVCaptureDeviceInput(device: newDevice),
               session.canAddInput(newInput) {
                session.addInput(newInput)
            }
        }
        
        session.commitConfiguration()
    }
}

// MARK: - Camera Preview UIViewRepresentable
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}

class VideoPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - Camera Preview View (SwiftUI)
struct CameraPreviewView: View {
    @StateObject private var cameraManager = CameraManager()
    var onCameraReady: ((CameraManager) -> Void)?

    var body: some View {
        ZStack {
            if cameraManager.permissionGranted {
                CameraPreview(session: cameraManager.session)
                    .onAppear {
                        cameraManager.startSession()
                        onCameraReady?(cameraManager)
                    }
                    .onDisappear {
                        cameraManager.stopSession()
                    }

                // Camera switch button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { cameraManager.switchCamera() }) {
                            Image(systemName: "camera.rotate.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(12)
                    }
                    Spacer()
                }
            } else if let error = cameraManager.error {
                VStack(spacing: 16) {
                    Image(systemName: "video.slash.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "ef4444"))
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "94a3b8"))
                        .multilineTextAlignment(.center)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "10b981"))
                }
                .padding(20)
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Requesting camera access...")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "94a3b8"))
                }
            }
        }
        .background(Color(hex: "1e293b"))
    }
}

