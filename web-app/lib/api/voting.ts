import { apiClient } from './client';
import type { Election, Vote, APIResponse } from '@/types';

export interface CastVoteRequest {
  targetGeniusId: string;
  positionId?: string;
  weight: number; // 1-4
}

export const votingAPI = {
  async getElections(): Promise<APIResponse<Election[]>> {
    return apiClient.get('/voting/elections');
  },

  async getElection(electionId: string): Promise<APIResponse<Election>> {
    return apiClient.get(`/voting/elections/${electionId}`);
  },

  async castVote(data: CastVoteRequest): Promise<APIResponse<Vote>> {
    return apiClient.post('/voting/vote', data);
  },

  async getVoteHistory(userId: string): Promise<APIResponse<Vote[]>> {
    return apiClient.get(`/voting/history/${userId}`);
  },

  async getGeniusVotes(geniusId: string): Promise<APIResponse<{ totalVotes: number; voters: number }>> {
    return apiClient.get(`/voting/genius/${geniusId}`);
  },
};
