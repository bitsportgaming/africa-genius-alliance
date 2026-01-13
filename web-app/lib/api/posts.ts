import { apiClient } from './client';
import type { Post, APIResponse, PaginatedResponse } from '@/types';

export interface CreatePostRequest {
  content: string;
  files?: File[];
  postType?: 'text' | 'image' | 'video' | 'liveAnnouncement';
}

export const postsAPI = {
  async getPosts(params?: { page?: number; limit?: number; authorId?: string }): Promise<APIResponse<Post[]>> {
    const page = params?.page || 1;
    const limit = params?.limit || 20;
    let url = `/posts?page=${page}&limit=${limit}`;
    if (params?.authorId) url += `&authorId=${params.authorId}`;
    return apiClient.get(url);
  },

  async getFeed(page = 1, limit = 20): Promise<PaginatedResponse<Post>> {
    return apiClient.get(`/posts?page=${page}&limit=${limit}`);
  },

  async getPost(postId: string): Promise<APIResponse<Post>> {
    return apiClient.get(`/posts/${postId}`);
  },

  async createPost(data: CreatePostRequest): Promise<APIResponse<Post>> {
    const formData = new FormData();
    formData.append('content', data.content);

    if (data.postType) {
      formData.append('postType', data.postType);
    }

    if (data.files && data.files.length > 0) {
      data.files.forEach((file) => {
        formData.append('files', file);
      });
    }

    return apiClient.uploadFile('/posts', formData);
  },

  async likePost(postId: string): Promise<APIResponse<{ liked: boolean; likesCount: number }>> {
    return apiClient.post(`/posts/${postId}/like`);
  },

  async deletePost(postId: string): Promise<APIResponse<void>> {
    return apiClient.delete(`/posts/${postId}`);
  },

  async getUserPosts(userId: string, page = 1, limit = 20): Promise<PaginatedResponse<Post>> {
    return apiClient.get(`/posts/user/${userId}?page=${page}&limit=${limit}`);
  },
};
