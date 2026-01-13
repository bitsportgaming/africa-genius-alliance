//
//  UserRole.swift
//  AGA
//
//  Created by AGA Team on 11/21/25.
//

import Foundation

enum UserRole: String, Codable, CaseIterable {
    case genius = "genius"
    case regular = "regular"
    case supporter = "supporter"
    case admin = "admin"
    case superadmin = "superadmin"

    var displayName: String {
        switch self {
        case .genius:
            return "Genius"
        case .regular, .supporter:
            return "Supporter"
        case .admin:
            return "Admin"
        case .superadmin:
            return "Super Admin"
        }
    }

    /// Returns true if this is a supporter role (regular or supporter)
    var isSupporter: Bool {
        return self == .regular || self == .supporter
    }

    /// Returns true if this is a genius role
    var isGenius: Bool {
        return self == .genius
    }

    /// Returns true if this is an admin role (admin or superadmin)
    var isAdmin: Bool {
        return self == .admin || self == .superadmin
    }

    /// Returns true if this is a superadmin
    var isSuperAdmin: Bool {
        return self == .superadmin
    }

    var canCreatePosts: Bool {
        // Geniuses and admins can create posts
        return self == .genius || self == .admin || self == .superadmin
    }

    var canComment: Bool {
        return true
    }

    var canLike: Bool {
        return true
    }

    var canVote: Bool {
        return true
    }

    var canShare: Bool {
        return true
    }

    /// Badge color for verification checkmark
    var badgeColor: String {
        switch self {
        case .superadmin:
            return "FFD700" // Gold
        case .admin:
            return "FFD700" // Gold
        case .genius:
            return "10b981" // Emerald/Green
        case .regular, .supporter:
            return "6b7280" // Gray
        }
    }

    /// Whether user should show a special verification badge
    var hasSpecialBadge: Bool {
        return self == .admin || self == .superadmin || self == .genius
    }

    /// Roles available for signup (excludes admin roles)
    static var signupRoles: [UserRole] {
        return [.genius, .regular]
    }
}

