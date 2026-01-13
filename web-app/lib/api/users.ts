import { apiClient } from './client';
import type { User, APIResponse, PaginatedResponse, GeniusCategory } from '@/types';

export interface GetGeniusesParams {
  category?: GeniusCategory;
  country?: string;
  limit?: number;
  page?: number;
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

  async followUser(userId: string): Promise<APIResponse<{ following: boolean }>> {
    return apiClient.post(`/users/${userId}/follow`);
  },

  async unfollowUser(userId: string): Promise<APIResponse<{ following: boolean }>> {
    return apiClient.post(`/users/${userId}/unfollow`);
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
};
