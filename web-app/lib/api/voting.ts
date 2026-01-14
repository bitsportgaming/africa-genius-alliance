import { apiClient } from './client';
import type { Election, Vote, APIResponse } from '@/types';

export interface CastVoteRequest {
  userId: string;
  candidateId: string;
}

export interface VoteResponse {
  vote: Vote;
  election: Election;
  message: string;
}

export interface CheckVoteResponse {
  hasVoted: boolean;
  vote?: {
    candidateId: string;
    votedAt: string;
    blockchain: {
      transactionHash: string;
      blockNumber: number;
      status: string;
    };
  };
}

export interface ElectionResults {
  election: Election;
  results: Array<{
    candidateId: string;
    name: string;
    party: string;
    votesReceived: number;
    percentage: number;
  }>;
  totalVotes: number;
  totalVoters: number;
}

export const votingAPI = {
  // Get all elections
  async getElections(params?: { status?: string; country?: string }): Promise<APIResponse<Election[]>> {
    const queryParams = new URLSearchParams();
    if (params?.status) queryParams.set('status', params.status);
    if (params?.country) queryParams.set('country', params.country);
    const query = queryParams.toString();
    return apiClient.get(`/elections${query ? `?${query}` : ''}`);
  },

  // Get active elections
  async getActiveElections(): Promise<APIResponse<Election[]>> {
    return apiClient.get('/elections/active');
  },

  // Get single election
  async getElection(electionId: string): Promise<APIResponse<Election>> {
    return apiClient.get(`/elections/${electionId}`);
  },

  // Get election results
  async getResults(electionId: string): Promise<APIResponse<ElectionResults>> {
    return apiClient.get(`/elections/${electionId}/results`);
  },

  // Cast a vote (classic: 1 vote per user per election)
  async castVote(electionId: string, data: CastVoteRequest): Promise<APIResponse<VoteResponse>> {
    return apiClient.post(`/elections/${electionId}/vote`, data);
  },

  // Check if user has voted in an election
  async checkVote(electionId: string, userId: string): Promise<APIResponse<CheckVoteResponse>> {
    return apiClient.get(`/elections/${electionId}/check-vote/${userId}`);
  },

  // Verify vote on blockchain
  async verifyVote(electionId: string, txHash: string): Promise<APIResponse<{ verified: boolean; vote: Vote; explorerUrl: string }>> {
    return apiClient.get(`/elections/${electionId}/verify/${txHash}`);
  },

  // Get all votes for an election (transparency)
  async getElectionVotes(electionId: string, page = 1): Promise<APIResponse<Vote[]>> {
    return apiClient.get(`/elections/${electionId}/votes?page=${page}`);
  },
};
