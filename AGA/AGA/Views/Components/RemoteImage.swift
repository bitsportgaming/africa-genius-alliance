//
//  RemoteImage.swift
//  AGA
//
//  Created by AGA Team on 1/1/26.
//

import SwiftUI

// MARK: - Remote Image View
/// A custom image loader that properly handles remote images with caching and error states
struct RemoteImage: View {
    let urlString: String

    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var errorText = ""

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else if isLoading {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "f3f4f6"))
                    .overlay(
                        VStack {
                            ProgressView()
                            Text("Loading...")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "e5e7eb"))
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: "9ca3af"))
                            Text(errorText)
                                .font(.system(size: 8))
                                .foregroundColor(.red)
                                .lineLimit(2)
                                .padding(.horizontal, 4)
                        }
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        print("🔍 RemoteImage: urlString = \(urlString)")

        // Build full URL
        let fullURLString: String
        if urlString.hasPrefix("http") {
            fullURLString = urlString
        } else {
            // Construct full URL manually
            let base = "https://api.globalgeniusalliance.org"
            let path = urlString.hasPrefix("/") ? urlString : "/\(urlString)"
            fullURLString = "\(base)\(path)"
        }

        print("📸 Full URL: \(fullURLString)")

        guard let url = URL(string: fullURLString) else {
            print("❌ Invalid URL string: \(fullURLString)")
            isLoading = false
            hasError = true
            errorText = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    hasError = true
                    errorText = error.localizedDescription
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ No HTTP response")
                    hasError = true
                    errorText = "No response"
                    return
                }

                print("📡 HTTP Status: \(httpResponse.statusCode)")

                guard httpResponse.statusCode == 200 else {
                    print("❌ HTTP error: \(httpResponse.statusCode)")
                    hasError = true
                    errorText = "HTTP \(httpResponse.statusCode)"
                    return
                }

                guard let data = data else {
                    print("❌ No data received")
                    hasError = true
                    errorText = "No data"
                    return
                }

                print("📦 Data size: \(data.count) bytes")

                guard let loadedImage = UIImage(data: data) else {
                    print("❌ Failed to decode image")
                    hasError = true
                    errorText = "Decode failed"
                    return
                }

                print("✅ Image loaded: \(loadedImage.size)")
                self.image = loadedImage
            }
        }.resume()
    }
}

#Preview {
    VStack(spacing: 20) {
        RemoteImage(urlString: "/uploads/test.jpg")
            .frame(width: 300, height: 200)
            .cornerRadius(12)
    }
    .padding()
}

