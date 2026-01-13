import { apiClient } from './client';
import type { User, APIResponse, PaginatedResponse, GeniusCategory } from '@/types';

export interface GetGeniusesParams {
  category?: GeniusCategory;
  country?: string;
  limit?: number;
  page?: number;
}

// Helper function to get current user ID from localStorage
function getCurrentUserId(): string | undefined {
  if (typeof window === 'undefined') return undefined;

  // Try the Zustand auth storage first
  const authStorage = localStorage.getItem('aga-auth-storage');
  if (authStorage) {
    try {
      const parsed = JSON.parse(authStorage);
      const user = parsed?.state?.user;
      if (user) {
        return user.userId || user._id;
      }
    } catch (e) {
      // Ignore parse errors
    }
  }

  // Fallback to legacy storage
  const userData = localStorage.getItem('aga_user_data');
  if (userData) {
    try {
      const user = JSON.parse(userData);
      return user.userId || user._id;
    } catch (e) {
      // Ignore parse errors
    }
  }

  return undefined;
}

export const usersAPI = {
  async getGeniuses(params?: GetGeniusesParams): Promise<PaginatedResponse<User>> {
    const queryParams = new URLSearchParams();

    if (params?.category) queryParams.append('category', params.category);
    if (params?.country) queryParams.append('country', params.country);
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.page) queryParams.append('page', params.page.toString());

    const query = queryParams.toString();
    return apiClient.get(`/users/geniuses${query ? `?${query}` : ''}`);
  },

  async getUser(userId: string): Promise<APIResponse<User>> {
    return apiClient.get(`/users/${userId}`);
  },

  async followUser(userId: string, followerId?: string): Promise<APIResponse<{ following: boolean }>> {
    const actualFollowerId = followerId || getCurrentUserId();
    return apiClient.post(`/users/${userId}/follow`, { followerId: actualFollowerId });
  },

  async unfollowUser(userId: string, followerId?: string): Promise<APIResponse<{ following: boolean }>> {
    const actualFollowerId = followerId || getCurrentUserId();
    return apiClient.post(`/users/${userId}/follow`, { followerId: actualFollowerId });
  },

  async getFollowers(userId: string): Promise<APIResponse<User[]>> {
    return apiClient.get(`/users/${userId}/followers`);
  },

  async getFollowing(userId: string): Promise<APIResponse<User[]>> {
    return apiClient.get(`/users/${userId}/following`);
  },

  async searchGeniuses(query: string, limit = 20): Promise<APIResponse<User[]>> {
    return apiClient.get(`/users/search?q=${encodeURIComponent(query)}&limit=${limit}`);
  },

  async voteForGenius(userId: string, voterId?: string): Promise<APIResponse<{ votesReceived: number; message: string }>> {
    const actualVoterId = voterId || getCurrentUserId();
    return apiClient.post(`/users/${userId}/vote`, { voterId: actualVoterId });
  },
};
