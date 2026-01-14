//
//  ContentView.swift
//  AGA
//
//  Created by Charles on 11/21/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(AuthService.self) private var authService
    @State private var selectedTab = 0

    // Create a single AuthViewModel to share across all views
    @State private var authViewModel: AuthViewModel?

    /// Determines if the current user is a Genius
    private var isGenius: Bool {
        authService.currentUser?.role.isGenius ?? false
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            if let viewModel = authViewModel {
                TabView(selection: $selectedTab) {
                    // Tab 0: Home (role-based, unchanged)
                    Group {
                        if isGenius {
                            GeniusHomeScreen()
                        } else {
                            SupporterHomeScreen()
                        }
                    }
                    .tag(0)

                    // Tab 1: Explore (renamed from Browse)
                    SupporterDashboardView()
                        .tag(1)

                    // Tab 2: Role-based - Vote for Supporters, Create for Geniuses
                    Group {
                        if isGenius {
                            CreateHubView()
                        } else {
                            VotingHubView()
                        }
                    }
                    .tag(2)

                    // Tab 3: Impact (renamed from Rank, role-based content)
                    Group {
                        if isGenius {
                            GeniusImpactView(onSwitchToCreateTab: {
                                selectedTab = 2 // Switch to Create tab
                            })
                        } else {
                            SupporterImpactView()
                        }
                    }
                    .tag(3)

                    // Tab 4: Profile (unchanged)
                    ProfileView()
                        .tag(4)
                }
                .toolbar(.hidden, for: .tabBar) // Hide default tab bar
                .environmentObject(viewModel)

                // Custom Tab Bar with role awareness
                CustomTabBar(selectedTab: $selectedTab, isGenius: isGenius)
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if authViewModel == nil {
                authViewModel = AuthViewModel(authService: authService)
            }
        }
    }
}

// MARK: - Custom Tab Bar (matching reference design)
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var isGenius: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            // Tab 0: Home
            TabBarItem(icon: "house.fill", label: "Home", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            // Tab 1: Explore (renamed from Browse)
            TabBarItem(icon: "safari.fill", label: "Explore", isSelected: selectedTab == 1) {
                selectedTab = 1
            }

            // Tab 2: Role-based - Create for Genius, Vote for Supporter
            if isGenius {
                TabBarItem(icon: "plus.circle.fill", label: "Create", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            } else {
                TabBarItem(icon: "checkmark.circle.fill", label: "Vote", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }

            // Tab 3: Impact (renamed from Rank)
            TabBarItem(icon: "chart.line.uptrend.xyaxis", label: "Impact", isSelected: selectedTab == 3) {
                selectedTab = 3
            }

            // Tab 4: Profile
            TabBarItem(icon: "person.fill", label: "Profile", isSelected: selectedTab == 4) {
                selectedTab = 4
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            LinearGradient(
                colors: [Color(hex: "fb923c"), Color(hex: "f59e0b")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false
    @State private var bounceScale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            // Trigger bounce animation
            withAnimation(FluidAnimation.bouncy) {
                bounceScale = 1.15
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(FluidAnimation.smooth) {
                    bounceScale = 1.0
                }
            }

            HapticFeedback.impact(.light)
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(hex: "0a4d3c") : .white.opacity(0.7))
                    .scaleEffect(isSelected ? bounceScale : 1.0)
                    .animation(FluidAnimation.smooth, value: isSelected)

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(hex: "0a4d3c") : .white.opacity(0.7))
                    .animation(FluidAnimation.smooth, value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.3))
                            .padding(.horizontal, 8)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(FluidAnimation.smooth, value: isSelected)
            )
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(FluidAnimation.snappy, value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Rounded Corner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Keep old ContentView for compatibility
struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    MainTabView()
        .environment(AuthService.shared)
        .modelContainer(for: [Post.self, User.self, Comment.self, Like.self, Vote.self], inMemory: true)
}
