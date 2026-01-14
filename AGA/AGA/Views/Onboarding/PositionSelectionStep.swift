//
//  PositionSelectionStep.swift
//  AGA
//
//  Step 2: Select position (electoral) or role (non-electoral)
//

import SwiftUI

struct PositionSelectionStep: View {
    let category: GeniusCategory?
    @Binding var positionType: PositionType
    @Binding var selectedPosition: GeniusPosition?
    @Binding var customRole: String
    @Binding var sector: String
    @Binding var location: String
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var showSectorPicker = false

    private var electoralPositions: [GeniusPosition] {
        category?.electoralPositions ?? []
    }

    private var nonElectoralPositions: [GeniusPosition] {
        category?.nonElectoralPositions ?? []
    }

    private var isValid: Bool {
        if positionType == .electoral {
            return selectedPosition != nil
        } else {
            return selectedPosition != nil || !customRole.isEmpty
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                headerSection

                // Position Type Selector
                positionTypeSelector

                // Content based on position type
                if positionType == .electoral {
                    electoralPositionsSection
                } else {
                    nonElectoralRolesSection
                }

                // Navigation Buttons
                navigationButtons
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            if let category = category {
                ZStack {
                    Circle()
                        .fill(Color(hex: category.color))
                        .frame(width: 64, height: 64)

                    Image(systemName: category.icon)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }

            Text("Declare Your Position")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Are you running for office or serving in a specialized role?")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
        .padding(.horizontal, 24)
    }

    // MARK: - Position Type Selector
    private var positionTypeSelector: some View {
        HStack(spacing: 12) {
            ForEach(PositionType.allCases, id: \.self) { type in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        positionType = type
                        selectedPosition = nil
                        customRole = ""
                    }
                    HapticFeedback.impact(.light)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: type.icon)
                            .font(.system(size: 24))

                        Text(type.rawValue)
                            .font(.system(size: 13, weight: .semibold))

                        Text(type.description)
                            .font(.system(size: 11))
                            .opacity(0.8)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundColor(positionType == type ? Color(hex: "0a4d3c") : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(positionType == type ? Color(hex: "f59e0b") : Color.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(positionType == type ? Color(hex: "f59e0b") : Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Electoral Positions
    private var electoralPositionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Position You're Running For")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            if electoralPositions.isEmpty {
                Text("No electoral positions available in this category")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 20)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(electoralPositions) { position in
                        PositionCard(
                            position: position,
                            isSelected: selectedPosition == position,
                            categoryColor: category?.color ?? "0a4d3c"
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPosition = position
                                customRole = "" // Clear custom role when selecting predefined
                            }
                            HapticFeedback.impact(.light)
                        }
                    }

                    // Other button
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPosition = nil
                        }
                        HapticFeedback.impact(.light)
                    }) {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(selectedPosition == nil && !customRole.isEmpty ? Color(hex: category?.color ?? "0a4d3c") : Color(hex: category?.color ?? "0a4d3c").opacity(0.1))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "pencil")
                                    .font(.system(size: 18))
                                    .foregroundColor(selectedPosition == nil && !customRole.isEmpty ? .white : Color(hex: category?.color ?? "0a4d3c"))
                            }

                            Text("Other")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedPosition == nil && !customRole.isEmpty ? .white : Color(hex: "374151"))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedPosition == nil && !customRole.isEmpty ? Color(hex: category?.color ?? "0a4d3c") : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedPosition == nil && !customRole.isEmpty ? Color.clear : Color(hex: "e5e7eb"), lineWidth: 1)
                        )
                        .shadow(color: selectedPosition == nil && !customRole.isEmpty ? Color(hex: category?.color ?? "0a4d3c").opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)

                // Custom electoral position input - shown when "Other" is active
                if selectedPosition == nil {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Specify Your Electoral Position")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Examples: \"Senator\", \"Mayor\", \"Councilor\"")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))

                        TextField("Enter your position title", text: $customRole)
                            .textInputAutocapitalization(.words)
                            .foregroundColor(.white)
                            .padding(14)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(!customRole.isEmpty ? Color(hex: "f59e0b").opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }

                // Location input for electoral positions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Geographic Location")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Specify the state, region, or local government area")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))

                    TextField("e.g., Ogun State, Lagos, Ward 3", text: $location)
                        .textInputAutocapitalization(.words)
                        .foregroundColor(.white)
                        .padding(14)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(!location.isEmpty ? Color(hex: "f59e0b").opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Non-Electoral Roles
    private var nonElectoralRolesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Predefined roles section
            VStack(alignment: .leading, spacing: 12) {
                Text("Select a Role")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(nonElectoralPositions) { position in
                        PositionCard(
                            position: position,
                            isSelected: selectedPosition == position,
                            categoryColor: category?.color ?? "0a4d3c"
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPosition = position
                                customRole = ""  // Clear custom if selecting predefined
                            }
                            HapticFeedback.impact(.light)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            // Divider
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 1)
                Text("OR")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 1)
            }
            .padding(.horizontal, 20)

            // Custom role input
            customRoleSection
        }
    }

    // MARK: - Custom Role Input
    private var customRoleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Define a Custom Role")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)

            Text("Examples: \"National Infrastructure Auditor\", \"Government Contract Analyst\"")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))

            TextField("Enter your role title", text: $customRole)
                .textInputAutocapitalization(.words)
                .foregroundColor(.white)
                .padding(14)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(!customRole.isEmpty ? Color(hex: "f59e0b").opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                )
                .onChange(of: customRole) { _, _ in
                    if !customRole.isEmpty {
                        selectedPosition = nil  // Clear predefined if typing custom
                    }
                }

            // Sector picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Sector (Optional)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                Button(action: { showSectorPicker = true }) {
                    HStack {
                        Text(sector.isEmpty ? "Select a sector..." : sector)
                            .foregroundColor(sector.isEmpty ? .white.opacity(0.5) : .white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showSectorPicker) {
            SectorPickerSheet(selectedSector: $sector, isPresented: $showSectorPicker)
        }
    }

    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
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

// MARK: - Position Card
struct PositionCard: View {
    let position: GeniusPosition
    let isSelected: Bool
    let categoryColor: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: categoryColor) : Color(hex: categoryColor).opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: position.icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .white : Color(hex: categoryColor))
                }

                VStack(spacing: 4) {
                    Text(position.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? .white : Color(hex: "374151"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    // Show electoral badge
                    if position.isElectoral {
                        HStack(spacing: 2) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 8))
                            Text("Electoral")
                                .font(.system(size: 9, weight: .medium))
                        }
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Color(hex: "10b981"))
                    }

                    // Show sector if available
                    if let sector = position.sector {
                        Text(sector)
                            .font(.system(size: 10))
                            .foregroundColor(isSelected ? .white.opacity(0.7) : Color(hex: "6b7280"))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color(hex: categoryColor) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.clear : Color(hex: "e5e7eb"), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color(hex: categoryColor).opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Sector Picker Sheet
struct SectorPickerSheet: View {
    @Binding var selectedSector: String
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            List {
                ForEach(Sectors.all, id: \.self) { sector in
                    Button(action: {
                        selectedSector = sector
                        isPresented = false
                        HapticFeedback.impact(.light)
                    }) {
                        HStack {
                            Text(sector)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedSector == sector {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "10b981"))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Sector")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "0a4d3c").ignoresSafeArea()
        PositionSelectionStep(
            category: .oversight,
            positionType: .constant(.nonElectoral),
            selectedPosition: .constant(nil),
            customRole: .constant(""),
            sector: .constant(""),
            location: .constant(""),
            onNext: {},
            onBack: {}
        )
    }
}
