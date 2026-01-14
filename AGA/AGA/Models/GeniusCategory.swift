//
//  GeniusCategory.swift
//  AGA
//
//  Defines genius categories and positions for onboarding
//

import Foundation

// MARK: - Genius Category
enum GeniusCategory: String, CaseIterable, Identifiable {
    case political = "Political / Governance"
    case oversight = "Oversight & Accountability"
    case technical = "Technical & Nation Builders"
    case civic = "Civic & Cultural"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .political: return "building.columns.fill"
        case .oversight: return "eye.fill"
        case .technical: return "hammer.fill"
        case .civic: return "person.3.fill"
        }
    }
    
    var description: String {
        switch self {
        case .political: return "Lead governance and policy-making"
        case .oversight: return "Ensure transparency and accountability"
        case .technical: return "Build infrastructure and systems"
        case .civic: return "Shape culture and community"
        }
    }
    
    var color: String {
        switch self {
        case .political: return "0a4d3c"
        case .oversight: return "dc2626"
        case .technical: return "2563eb"
        case .civic: return "7c3aed"
        }
    }
    
    var positions: [GeniusPosition] {
        switch self {
        case .political:
            return [
                GeniusPosition(title: "President", icon: "star.fill", isElectoral: true),
                GeniusPosition(title: "Vice President", icon: "star.lefthalf.fill", isElectoral: true),
                GeniusPosition(title: "Governor", icon: "building.2.fill", isElectoral: true),
                GeniusPosition(title: "Senator", icon: "person.text.rectangle", isElectoral: true),
                GeniusPosition(title: "Minister", icon: "briefcase.fill", isElectoral: false),
                GeniusPosition(title: "Mayor", icon: "building.fill", isElectoral: true),
                GeniusPosition(title: "Local Council Leader", icon: "person.badge.shield.checkmark", isElectoral: true)
            ]
        case .oversight:
            return [
                GeniusPosition(title: "Genius Journalist", icon: "newspaper.fill", isElectoral: false),
                GeniusPosition(title: "Investigative Reporter", icon: "magnifyingglass", isElectoral: false),
                GeniusPosition(title: "Historian", icon: "book.closed.fill", isElectoral: false),
                GeniusPosition(title: "Policy Analyst", icon: "doc.text.magnifyingglass", isElectoral: false),
                GeniusPosition(title: "Government Contract Analyst", icon: "doc.badge.gearshape", isElectoral: false, sector: "Energy Sector"),
                GeniusPosition(title: "National Property & Asset Tracker", icon: "map.fill", isElectoral: false),
                GeniusPosition(title: "National Infrastructure Auditor", icon: "building.columns.fill", isElectoral: false),
                GeniusPosition(title: "Anti-Corruption Researcher", icon: "shield.lefthalf.filled", isElectoral: false),
                GeniusPosition(title: "Public Data Auditor", icon: "chart.bar.doc.horizontal", isElectoral: false)
            ]
        case .technical:
            return [
                GeniusPosition(title: "Software Engineer", icon: "chevron.left.forwardslash.chevron.right", isElectoral: false),
                GeniusPosition(title: "Infrastructure Planner", icon: "road.lanes", isElectoral: false),
                GeniusPosition(title: "Transport Systems Engineer", icon: "tram.fill", isElectoral: false),
                GeniusPosition(title: "Energy Specialist", icon: "bolt.fill", isElectoral: false, sector: "Energy Sector"),
                GeniusPosition(title: "Agriculture Expert", icon: "leaf.fill", isElectoral: false, sector: "Agriculture"),
                GeniusPosition(title: "Health Systems Expert", icon: "cross.case.fill", isElectoral: false, sector: "Healthcare"),
                GeniusPosition(title: "Education Reformer", icon: "graduationcap.fill", isElectoral: false, sector: "Education")
            ]
        case .civic:
            return [
                GeniusPosition(title: "Economist", icon: "chart.line.uptrend.xyaxis", isElectoral: false),
                GeniusPosition(title: "Philosopher", icon: "brain.head.profile", isElectoral: false),
                GeniusPosition(title: "Legal Scholar", icon: "scale.3d", isElectoral: false),
                GeniusPosition(title: "Community Organizer", icon: "person.3.sequence.fill", isElectoral: false),
                GeniusPosition(title: "Diplomat", icon: "globe.americas.fill", isElectoral: false),
                GeniusPosition(title: "Pan-African Strategist", icon: "globe.africa.fill", isElectoral: false)
            ]
        }
    }

    // Separate electoral and non-electoral positions
    var electoralPositions: [GeniusPosition] {
        positions.filter { $0.isElectoral }
    }

    var nonElectoralPositions: [GeniusPosition] {
        positions.filter { !$0.isElectoral }
    }
}

// MARK: - Position Type
enum PositionType: String, CaseIterable {
    case electoral = "Electoral Position"
    case nonElectoral = "Non-Electoral Role"

    var description: String {
        switch self {
        case .electoral: return "Running for an elected office"
        case .nonElectoral: return "Serving in a specialized role"
        }
    }

    var icon: String {
        switch self {
        case .electoral: return "checkmark.seal.fill"
        case .nonElectoral: return "person.badge.key.fill"
        }
    }
}

// MARK: - Genius Position
struct GeniusPosition: Identifiable, Hashable {
    let title: String
    let icon: String
    let isElectoral: Bool
    let sector: String?

    var id: String { title }

    init(title: String, icon: String, isElectoral: Bool = false, sector: String? = nil) {
        self.title = title
        self.icon = icon
        self.isElectoral = isElectoral
        self.sector = sector
    }
}

// MARK: - African Countries
struct AfricanCountries {
    static let all: [String] = [
        "Algeria", "Angola", "Benin", "Botswana", "Burkina Faso",
        "Burundi", "Cabo Verde", "Cameroon", "Central African Republic", "Chad",
        "Comoros", "Congo (Brazzaville)", "Congo (DRC)", "Côte d'Ivoire", "Djibouti",
        "Egypt", "Equatorial Guinea", "Eritrea", "Eswatini", "Ethiopia",
        "Gabon", "Gambia", "Ghana", "Guinea", "Guinea-Bissau",
        "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar",
        "Malawi", "Mali", "Mauritania", "Mauritius", "Morocco",
        "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda",
        "São Tomé and Príncipe", "Senegal", "Seychelles", "Sierra Leone", "Somalia",
        "South Africa", "South Sudan", "Sudan", "Tanzania", "Togo",
        "Tunisia", "Uganda", "Zambia", "Zimbabwe"
    ]
}

// MARK: - Onboarding Data Model
struct GeniusOnboardingData {
    var fullName: String = ""
    var country: String = ""
    var category: GeniusCategory?
    var positionType: PositionType = .nonElectoral
    var position: GeniusPosition?
    var customRole: String = ""  // For custom non-electoral roles
    var sector: String = ""      // Sector specialization (e.g., "Energy Sector")
    var location: String = ""    // Geographic location (e.g., "Ogun State", "Lagos", "Ward 3")
    var biography: String = ""
    var whyGenius: String = ""
    var problemSolved: String = ""
    var proofLinks: [String] = []
    var credentials: [String] = []
    var videoIntroURL: String?
    var verificationStatus: VerificationStatus = .pending
    var profileImageData: Data?  // For photo upload

    // Computed property for display title
    var positionTitle: String {
        if let position = position {
            var title = position.title
            // Add location for electoral positions
            if position.isElectoral && !location.isEmpty {
                title += " for \(location)"
            }
            // Add sector if available
            if let sector = position.sector {
                title += " – \(sector)"
            }
            return title
        } else if !customRole.isEmpty {
            var title = customRole
            // Add location if specified
            if !location.isEmpty {
                title += " for \(location)"
            }
            // Add sector if available
            if !sector.isEmpty {
                title += " – \(sector)"
            }
            return title
        }
        return ""
    }

    var isStep1Complete: Bool {
        category != nil
    }

    var isStep2Complete: Bool {
        position != nil || !customRole.isEmpty
    }

    var isStep3Complete: Bool {
        !fullName.isEmpty && !country.isEmpty && !biography.isEmpty && biography.count >= 50
    }

    var isStep4Complete: Bool {
        !whyGenius.isEmpty && whyGenius.count >= 50 && !problemSolved.isEmpty && problemSolved.count >= 30
    }

    var isStep5Complete: Bool {
        !proofLinks.isEmpty || !credentials.isEmpty
    }
}

// MARK: - Sectors for Custom Roles
struct Sectors {
    static let all: [String] = [
        "Agriculture",
        "Education",
        "Energy Sector",
        "Finance & Banking",
        "Healthcare",
        "Infrastructure",
        "Justice & Legal",
        "Mining & Resources",
        "Security & Defense",
        "Technology",
        "Trade & Commerce",
        "Transportation",
        "Water & Sanitation",
        "Youth & Sports",
        "Other"
    ]
}

