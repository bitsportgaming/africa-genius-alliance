import { apiClient } from './client';
import type { User, APIResponse } from '@/types';

export interface RegisterRequest {
  username: string;
  email: string;
  password: string;
  displayName: string;
  role: 'genius' | 'regular';
  country?: string;
  bio?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface AuthResponse {
  user: User;
  token?: string;
}

export const authAPI = {
  async register(data: RegisterRequest): Promise<APIResponse<AuthResponse>> {
    return apiClient.post('/auth/register', data);
  },

  async login(data: LoginRequest): Promise<APIResponse<AuthResponse>> {
    return apiClient.post('/auth/login', data);
  },

  async getProfile(userId: string): Promise<APIResponse<User>> {
    return apiClient.get(`/auth/profile/${userId}`);
  },

  async updateProfile(userId: string, data: Partial<User>): Promise<APIResponse<User>> {
    return apiClient.put(`/auth/profile/${userId}`, data);
  },

  async completeGeniusOnboarding(
    userId: string,
    data: {
      geniusCategory: string;
      geniusPosition: string;
      manifestoShort: string;
      sector?: string;
      isElectoralPosition?: boolean;
    }
  ): Promise<APIResponse<User>> {
    return apiClient.put(`/auth/profile/${userId}/genius`, data);
  },

  async uploadProfileImage(userId: string, file: File): Promise<APIResponse<{ imageUrl: string }>> {
    const formData = new FormData();
    formData.append('image', file);
    return apiClient.uploadFile(`/auth/profile/${userId}/image`, formData);
  },
};
