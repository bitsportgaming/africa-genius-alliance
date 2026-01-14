//
//  GeniusOnboardingView.swift
//  AGA
//
//  Multi-step onboarding flow for Geniuses
//

import SwiftUI

struct GeniusOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthService.self) private var authService
    
    @State private var currentStep = 1
    @State private var onboardingData = GeniusOnboardingData()
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let totalSteps = 5
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "0a4d3c"), Color(hex: "1a6b52")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Header
                    progressHeader
                    
                    // Step Content
                    TabView(selection: $currentStep) {
                        CategorySelectionStep(
                            selectedCategory: $onboardingData.category,
                            onNext: { nextStep() }
                        )
                        .tag(1)
                        
                        PositionSelectionStep(
                            category: onboardingData.category,
                            positionType: $onboardingData.positionType,
                            selectedPosition: $onboardingData.position,
                            customRole: $onboardingData.customRole,
                            sector: $onboardingData.sector,
                            location: $onboardingData.location,
                            onNext: { nextStep() },
                            onBack: { previousStep() }
                        )
                        .tag(2)
                        
                        ProfileDetailsStep(
                            fullName: $onboardingData.fullName,
                            country: $onboardingData.country,
                            biography: $onboardingData.biography,
                            onNext: { nextStep() },
                            onBack: { previousStep() }
                        )
                        .tag(3)
                        
                        PitchProblemStep(
                            whyGenius: $onboardingData.whyGenius,
                            problemSolved: $onboardingData.problemSolved,
                            onNext: { nextStep() },
                            onBack: { previousStep() }
                        )
                        .tag(4)
                        
                        ProofOfWorkStep(
                            proofLinks: $onboardingData.proofLinks,
                            credentials: $onboardingData.credentials,
                            videoIntroURL: $onboardingData.videoIntroURL,
                            isSubmitting: isSubmitting,
                            onSubmit: { submitOnboarding() },
                            onBack: { previousStep() }
                        )
                        .tag(5)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)
                }
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Progress Header
    private var progressHeader: some View {
        VStack(spacing: 16) {
            // Step indicators
            HStack(spacing: 8) {
                ForEach(1...totalSteps, id: \.self) { step in
                    Capsule()
                        .fill(step <= currentStep ? Color(hex: "f59e0b") : Color.white.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // Step title
            Text(stepTitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.bottom, 8)
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 1: return "Step 1 of 5 • Choose Your Category"
        case 2: return "Step 2 of 5 • Declare Your Position"
        case 3: return "Step 3 of 5 • Your Profile"
        case 4: return "Step 4 of 5 • Your Vision"
        case 5: return "Step 5 of 5 • Prove Your Genius"
        default: return ""
        }
    }
    
    // MARK: - Navigation
    private func nextStep() {
        if currentStep < totalSteps {
            withAnimation { currentStep += 1 }
        }
    }
    
    private func previousStep() {
        if currentStep > 1 {
            withAnimation { currentStep -= 1 }
        }
    }
    
    private func submitOnboarding() {
        isSubmitting = true
        
        Task {
            do {
                try await authService.completeGeniusOnboarding(data: onboardingData)
                await MainActor.run {
                    isSubmitting = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

