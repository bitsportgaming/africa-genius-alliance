//
//  ProfileDetailsStep.swift
//  AGA
//
//  Step 3: Full name, country, biography
//

import SwiftUI

struct ProfileDetailsStep: View {
    @Binding var fullName: String
    @Binding var country: String
    @Binding var biography: String
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var showCountryPicker = false

    private var isValid: Bool {
        !fullName.isEmpty && !country.isEmpty && biography.count >= 50
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "f59e0b"))

                    Text("Tell Us About Yourself")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("This information will be visible on your public profile")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)

                // Form Fields
                VStack(spacing: 20) {
                    // Full Name
                    OnboardingTextField(
                        title: "Full Name",
                        placeholder: "Enter your full name",
                        text: $fullName,
                        icon: "person.fill"
                    )

                    // Country
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Country")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))

                        Button(action: { showCountryPicker = true }) {
                            HStack {
                                Image(systemName: "globe.africa.fill")
                                    .foregroundColor(Color(hex: "f59e0b"))

                                Text(country.isEmpty ? "Select your country" : country)
                                    .foregroundColor(country.isEmpty ? Color(hex: "9ca3af") : .white)

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color(hex: "9ca3af"))
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }

                    // Biography
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Short Biography")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))

                            Spacer()

                            Text("\(biography.count)/500")
                                .font(.system(size: 12))
                                .foregroundColor(biography.count >= 50 ? Color(hex: "10b981") : Color(hex: "9ca3af"))
                        }

                        TextEditor(text: $biography)
                            .frame(height: 120)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .onChange(of: biography) { _, newValue in
                                if newValue.count > 500 {
                                    biography = String(newValue.prefix(500))
                                }
                            }

                        if biography.count < 50 {
                            Text("Minimum 50 characters required")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "fbbf24"))
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Navigation Buttons
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

                    Button(action: onNext) {
                        HStack {
                            Text("Continue")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isValid ? Color(hex: "0a4d3c") : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 12).fill(isValid ? Color(hex: "f59e0b") : Color.white.opacity(0.2)))
                    }
                    .disabled(!isValid)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerSheet(selectedCountry: $country, isPresented: $showCountryPicker)
        }
    }
}

// MARK: - Onboarding Text Field
struct OnboardingTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: "f59e0b"))
                }

                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
            }
            .padding(16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Country Picker Sheet
struct CountryPickerSheet: View {
    @Binding var selectedCountry: String
    @Binding var isPresented: Bool
    @State private var searchText = ""

    private var filteredCountries: [String] {
        if searchText.isEmpty {
            return AfricanCountries.all
        }
        return AfricanCountries.all.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredCountries, id: \.self) { country in
                    Button(action: {
                        selectedCountry = country
                        isPresented = false
                        HapticFeedback.impact(.light)
                    }) {
                        HStack {
                            Text(country)
                                .foregroundColor(Color(hex: "1f2937"))

                            Spacer()

                            if selectedCountry == country {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "10b981"))
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search countries")
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "0a4d3c").ignoresSafeArea()
        ProfileDetailsStep(fullName: .constant(""), country: .constant(""), biography: .constant(""), onNext: {}, onBack: {})
    }
}
