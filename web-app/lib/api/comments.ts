import { apiClient } from './client';
import type { Comment, APIResponse } from '@/types';

export interface CreateCommentRequest {
  postId: string;
  content: string;
  parentCommentId?: string;
}

export const commentsAPI = {
  async getPostComments(postId: string): Promise<APIResponse<Comment[]>> {
    return apiClient.get(`/posts/${postId}/comments`);
  },

  async createComment(data: CreateCommentRequest): Promise<APIResponse<Comment>> {
    return apiClient.post('/comments', data);
  },

  async likeComment(commentId: string): Promise<APIResponse<{ liked: boolean; likesCount: number }>> {
    return apiClient.post(`/comments/${commentId}/like`);
  },

  async deleteComment(commentId: string): Promise<APIResponse<void>> {
    return apiClient.delete(`/comments/${commentId}`);
  },
};
