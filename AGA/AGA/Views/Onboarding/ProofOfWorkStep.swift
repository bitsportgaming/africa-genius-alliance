//
//  ProofOfWorkStep.swift
//  AGA
//
//  Step 5: Upload credentials, links, PDFs, optional video
//

import SwiftUI

struct ProofOfWorkStep: View {
    @Binding var proofLinks: [String]
    @Binding var credentials: [String]
    @Binding var videoIntroURL: String?
    let isSubmitting: Bool
    let onSubmit: () -> Void
    let onBack: () -> Void

    @State private var newLink = ""
    @State private var newCredential = ""
    @State private var videoURL = ""

    private var isValid: Bool {
        !proofLinks.isEmpty || !credentials.isEmpty
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "f59e0b"))

                    Text("Prove Your Genius")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Add links, credentials, and evidence that demonstrate your expertise")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)

                // Proof Links Section
                proofLinksSection

                // Credentials Section
                credentialsSection

                // Video Introduction (Optional)
                videoSection

                // Submit Button
                VStack(spacing: 16) {
                    if !isValid {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle")
                            Text("Add at least one link or credential to continue")
                        }
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "fbbf24"))
                    }

                    HStack(spacing: 12) {
                        Button(action: onBack) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Back")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.3), lineWidth: 1))
                        }

                        Button(action: onSubmit) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .tint(Color(hex: "0a4d3c"))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Complete Profile")
                                }
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isValid ? Color(hex: "0a4d3c") : .white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 12).fill(isValid ? Color(hex: "f59e0b") : Color.white.opacity(0.2)))
                        }
                        .disabled(!isValid || isSubmitting)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Proof Links Section
    private var proofLinksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "link")
                    .foregroundColor(Color(hex: "f59e0b"))
                Text("Portfolio & Work Links")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text("Add links to your work, publications, or social profiles")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))

            // Existing links
            ForEach(proofLinks, id: \.self) { link in
                LinkRow(link: link) {
                    proofLinks.removeAll { $0 == link }
                }
            }

            // Add new link
            HStack {
                TextField("https://...", text: $newLink)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)

                Button(action: addLink) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(newLink.isEmpty ? Color.white.opacity(0.3) : Color(hex: "10b981"))
                }
                .disabled(newLink.isEmpty)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    // MARK: - Credentials Section
    private var credentialsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "rosette")
                    .foregroundColor(Color(hex: "f59e0b"))
                Text("Credentials & Qualifications")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text("List your degrees, certifications, or achievements")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))

            // Existing credentials
            ForEach(credentials, id: \.self) { credential in
                CredentialRow(credential: credential) {
                    credentials.removeAll { $0 == credential }
                }
            }

            // Add new credential
            HStack {
                TextField("e.g., PhD in Economics, MIT", text: $newCredential)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)

                Button(action: addCredential) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(newCredential.isEmpty ? Color.white.opacity(0.3) : Color(hex: "10b981"))
                }
                .disabled(newCredential.isEmpty)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    private func addCredential() {
        guard !newCredential.isEmpty else { return }
        credentials.append(newCredential)
        newCredential = ""
        HapticFeedback.impact(.light)
    }

    private func addLink() {
        guard !newLink.isEmpty else { return }
        proofLinks.append(newLink)
        newLink = ""
        HapticFeedback.impact(.light)
    }

    // MARK: - Video Section
    private var videoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "video.fill")
                    .foregroundColor(Color(hex: "f59e0b"))
                Text("Video Introduction")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text("Optional")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "9ca3af"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4)
            }

            Text("Add a YouTube or Vimeo link to introduce yourself")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))

            HStack {
                TextField("https://youtube.com/...", text: $videoURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)

                if !videoURL.isEmpty {
                    Button(action: {
                        videoIntroURL = videoURL
                        HapticFeedback.notification(.success)
                    }) {
                        Image(systemName: videoIntroURL != nil ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "10b981"))
                    }
                }
            }

            if let _ = videoIntroURL {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "10b981"))
                    Text("Video link saved")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "10b981"))
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Link Row
struct LinkRow: View {
    let link: String
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "link")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "60a5fa"))

            Text(link)
                .font(.system(size: 13))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color(hex: "ef4444").opacity(0.7))
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }
}

// MARK: - Credential Row
struct CredentialRow: View {
    let credential: String
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "rosette")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "f59e0b"))

            Text(credential)
                .font(.system(size: 13))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color(hex: "ef4444").opacity(0.7))
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }
}

#Preview {
    ZStack {
        Color(hex: "0a4d3c").ignoresSafeArea()
        ProofOfWorkStep(
            proofLinks: .constant(["https://linkedin.com/in/example"]),
            credentials: .constant(["PhD Economics"]),
            videoIntroURL: .constant(nil),
            isSubmitting: false,
            onSubmit: {},
            onBack: {}
        )
    }
}
