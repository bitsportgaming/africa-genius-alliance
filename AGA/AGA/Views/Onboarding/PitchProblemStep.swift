//
//  PitchProblemStep.swift
//  AGA
//
//  Step 4: Why I Am a Genius + What problem they solve
//

import SwiftUI

struct PitchProblemStep: View {
    @Binding var whyGenius: String
    @Binding var problemSolved: String
    let onNext: () -> Void
    let onBack: () -> Void
    
    private var isValid: Bool {
        whyGenius.count >= 50 && problemSolved.count >= 30
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "f59e0b"))
                    
                    Text("Share Your Vision")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Help supporters understand what makes you a genius and the change you want to create")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                
                // Form Fields
                VStack(spacing: 24) {
                    // Why I Am a Genius
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Why I Am a Genius")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(whyGenius.count)/1000")
                                .font(.system(size: 12))
                                .foregroundColor(whyGenius.count >= 50 ? Color(hex: "10b981") : Color(hex: "9ca3af"))
                        }
                        
                        Text("Your core pitch - what unique perspective or ability do you bring?")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextEditor(text: $whyGenius)
                            .frame(height: 140)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(whyGenius.count >= 50 ? Color(hex: "10b981").opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .onChange(of: whyGenius) { _, newValue in
                                if newValue.count > 1000 {
                                    whyGenius = String(newValue.prefix(1000))
                                }
                            }
                        
                        if whyGenius.count < 50 && !whyGenius.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle")
                                Text("Minimum 50 characters (\(50 - whyGenius.count) more needed)")
                            }
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "fbbf24"))
                        }
                    }
                    
                    // What Problem They Solve
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("What Problem Do You Solve?")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(problemSolved.count)/800")
                                .font(.system(size: 12))
                                .foregroundColor(problemSolved.count >= 30 ? Color(hex: "10b981") : Color(hex: "9ca3af"))
                        }
                        
                        Text("Describe the specific problem you're addressing for Africa")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextEditor(text: $problemSolved)
                            .frame(height: 120)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(problemSolved.count >= 30 ? Color(hex: "10b981").opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .onChange(of: problemSolved) { _, newValue in
                                if newValue.count > 800 {
                                    problemSolved = String(newValue.prefix(800))
                                }
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
    }
}

#Preview {
    ZStack {
        Color(hex: "0a4d3c").ignoresSafeArea()
        PitchProblemStep(whyGenius: .constant(""), problemSolved: .constant(""), onNext: {}, onBack: {})
    }
}

