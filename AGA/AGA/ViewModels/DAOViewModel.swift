//
//  DAOViewModel.swift
//  AGA
//
//  Created by AGA Team on 12/10/25.
//

import Foundation
import SwiftData
import Observation

@Observable
final class DAOViewModel {
    var proposals: [Proposal] = []
    var treasuryAmount: Double = 5_420_000
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    @MainActor
    func loadProposals() {
        isLoading = true
        errorMessage = nil

        do {
            let activeStatus = ProposalStatus.active
            let descriptor = FetchDescriptor<Proposal>(
                predicate: #Predicate { proposal in
                    proposal.status == activeStatus
                },
                sortBy: [SortDescriptor(\.closesAt, order: .forward)]
            )
            proposals = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "Failed to load proposals: \(error.localizedDescription)"
        }

        isLoading = false
    }
    
    @MainActor
    func voteOnProposal(_ proposalId: String, vote: Bool, userId: String) {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create vote record
            let proposalVote = ProposalVote(
                userId: userId,
                proposalId: proposalId,
                vote: vote
            )
            modelContext.insert(proposalVote)
            
            // Update proposal vote counts
            if let proposal = proposals.first(where: { $0.id == proposalId }) {
                if vote {
                    proposal.yesVotes += 1
                } else {
                    proposal.noVotes += 1
                }
            }
            
            try modelContext.save()
            
            // Reload proposals
            loadProposals()
        } catch {
            errorMessage = "Failed to vote on proposal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func createProposal(title: String, description: String, daysUntilClose: Int) {
        isLoading = true
        errorMessage = nil
        
        do {
            let closesAt = Calendar.current.date(byAdding: .day, value: daysUntilClose, to: Date()) ?? Date()
            
            let proposal = Proposal(
                title: title,
                proposalDescription: description,
                closesAt: closesAt
            )
            
            modelContext.insert(proposal)
            try modelContext.save()
            
            // Reload proposals
            loadProposals()
        } catch {
            errorMessage = "Failed to create proposal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    var treasuryAllocation: [String: Double] {
        return [
            "Genius Funding": 0.45,
            "Infrastructure": 0.30,
            "Operations": 0.15,
            "Reserves": 0.10
        ]
    }
}

