import { apiClient } from './client';
import type { APIResponse } from '@/types';

export interface LiveStream {
  _id: string;
  hostId: string;
  hostName: string;
  hostAvatar?: string;
  hostPosition?: string;
  title: string;
  description?: string;
  category?: string;
  status: 'scheduled' | 'live' | 'ended';
  viewerCount: number;
  peakViewerCount: number;
  totalViews: number;
  likesCount: number;
  likedBy: string[];
  currentViewers: string[];
  createdAt: string;
  actualStartTime?: string;
  endTime?: string;
}

export const liveAPI = {
  async getLiveStreams(params?: { status?: string; limit?: number }): Promise<APIResponse<LiveStream[]>> {
    const queryParams = new URLSearchParams();
    if (params?.status) queryParams.append('status', params.status);
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    const query = queryParams.toString();
    return apiClient.get(`/live${query ? `?${query}` : ''}`);
  },

  async getLiveStream(id: string): Promise<APIResponse<LiveStream>> {
    return apiClient.get(`/live/${id}`);
  },

  async joinStream(streamId: string, userId: string): Promise<APIResponse<LiveStream>> {
    return apiClient.post(`/live/${streamId}/join`, { userId });
  },

  async leaveStream(streamId: string, userId: string): Promise<APIResponse<LiveStream>> {
    return apiClient.post(`/live/${streamId}/leave`, { userId });
  },

  async likeStream(streamId: string, userId: string): Promise<APIResponse<{ data: LiveStream; liked: boolean }>> {
    return apiClient.post(`/live/${streamId}/like`, { userId });
  },

  async startStream(data: {
    hostId: string;
    hostName: string;
    hostAvatar?: string;
    hostPosition?: string;
    title: string;
    description?: string;
    category?: string;
  }): Promise<APIResponse<LiveStream>> {
    return apiClient.post('/live/start', data);
  },

  async stopStream(streamId: string): Promise<APIResponse<LiveStream>> {
    return apiClient.post(`/live/${streamId}/stop`);
  },
};

