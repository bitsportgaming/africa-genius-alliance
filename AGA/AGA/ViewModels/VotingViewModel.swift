//
//  VotingViewModel.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import Foundation
import SwiftData
import Observation

@Observable
final class VotingViewModel {
    var currentElection: Election?
    var candidates: [Candidate] = []
    var selectedVoteCount: Int = 1
    var maxVotes: Int = 4
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    @MainActor
    func loadCurrentElection() {
        isLoading = true
        errorMessage = nil

        do {
            let activeStatus = ElectionStatus.active
            let descriptor = FetchDescriptor<Election>(
                predicate: #Predicate { election in
                    election.status == activeStatus
                },
                sortBy: [SortDescriptor(\.startDate, order: .reverse)]
            )
            let elections = try modelContext.fetch(descriptor)
            currentElection = elections.first

            if let election = currentElection {
                loadCandidates(for: election.id)
            }
        } catch {
            errorMessage = "Failed to load election: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadCandidates(for electionId: String) {
        do {
            let descriptor = FetchDescriptor<Candidate>(
                predicate: #Predicate { $0.electionId == electionId },
                sortBy: [SortDescriptor(\.votesReceived, order: .reverse)]
            )
            candidates = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to load candidates: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func castVote(for candidateId: String, userId: String) {
        guard let election = currentElection else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Create vote record
            let vote = ElectionVote(
                userId: userId,
                electionId: election.id,
                candidateId: candidateId,
                voteCount: selectedVoteCount
            )
            modelContext.insert(vote)
            
            // Update candidate vote count
            if let candidate = candidates.first(where: { $0.id == candidateId }) {
                candidate.votesReceived += selectedVoteCount
            }
            
            try modelContext.save()
            
            // Reload candidates to update percentages
            loadCandidates(for: election.id)
            
            // Reset vote count
            selectedVoteCount = 1
        } catch {
            errorMessage = "Failed to cast vote: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func getCandidatePercentage(_ candidate: Candidate) -> Double {
        let totalVotes = candidates.reduce(0) { $0 + $1.votesReceived }
        guard totalVotes > 0 else { return 0 }
        return Double(candidate.votesReceived) / Double(totalVotes)
    }
}

