//
//  ProjectAPIService.swift
//  AGA
//
//  Created by AGA Team on 1/4/26.
//

import Foundation

// MARK: - Project Models
struct ProjectRecord: Codable, Identifiable {
    let id: String
    let projectId: String
    let title: String
    let description: String
    let category: String
    let creatorId: String
    let creatorName: String
    let fundingGoal: Double
    let fundingRaised: Double
    let currency: String
    let status: String
    let imageURL: String?
    let votesCount: Int
    let supportersCount: Int
    let isNationalProject: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case projectId, title, description, category, creatorId, creatorName
        case fundingGoal, fundingRaised, currency, status, imageURL
        case votesCount, supportersCount, isNationalProject, createdAt
    }
    
    var fundingProgress: Double {
        guard fundingGoal > 0 else { return 0 }
        return min(fundingRaised / fundingGoal, 1.0)
    }
    
    var fundingPercentage: Int {
        Int(fundingProgress * 100)
    }
}

struct ProjectsResponse: Codable {
    let success: Bool
    let data: [ProjectRecord]?
    let error: String?
}

struct SingleProjectResponse: Codable {
    let success: Bool
    let data: ProjectRecord?
    let error: String?
}

// MARK: - Project API Service
class ProjectAPIService {
    static let shared = ProjectAPIService()
    private let baseURL = Config.apiBaseURL
    
    private init() {}
    
    // MARK: - Get All Projects
    func getProjects(category: String? = nil, status: String? = nil, limit: Int = 20) async throws -> [ProjectRecord] {
        var components = URLComponents(string: "\(baseURL)/projects")!
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "limit", value: "\(limit)")]
        if let category = category { queryItems.append(URLQueryItem(name: "category", value: category)) }
        if let status = status { queryItems.append(URLQueryItem(name: "status", value: status)) }
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidURL }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ProjectsResponse.self, from: data)
        
        if response.success, let projects = response.data {
            return projects
        }
        throw APIError.custom(response.error ?? "Failed to get projects")
    }
    
    // MARK: - Get National Projects
    func getNationalProjects() async throws -> [ProjectRecord] {
        guard let url = URL(string: "\(baseURL)/projects/national") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ProjectsResponse.self, from: data)
        
        if response.success, let projects = response.data {
            return projects
        }
        throw APIError.custom(response.error ?? "Failed to get projects")
    }
    
    // MARK: - Get Single Project
    func getProject(projectId: String) async throws -> ProjectRecord {
        guard let url = URL(string: "\(baseURL)/projects/\(projectId)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(SingleProjectResponse.self, from: data)
        
        if response.success, let project = response.data {
            return project
        }
        throw APIError.custom(response.error ?? "Project not found")
    }
    
    // MARK: - Get User's Projects
    func getUserProjects(userId: String) async throws -> [ProjectRecord] {
        guard let url = URL(string: "\(baseURL)/projects/user/\(userId)") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ProjectsResponse.self, from: data)
        
        if response.success, let projects = response.data {
            return projects
        }
        throw APIError.custom(response.error ?? "Failed to get projects")
    }
    
    // MARK: - Create Project
    func createProject(title: String, description: String, category: String, creatorId: String, creatorName: String, fundingGoal: Double, isNational: Bool = false) async throws -> ProjectRecord {
        guard let url = URL(string: "\(baseURL)/projects") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "title": title,
            "description": description,
            "category": category,
            "creatorId": creatorId,
            "creatorName": creatorName,
            "fundingGoal": fundingGoal,
            "isNationalProject": isNational
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(SingleProjectResponse.self, from: data)
        
        if response.success, let project = response.data {
            return project
        }
        throw APIError.custom(response.error ?? "Failed to create project")
    }
}

