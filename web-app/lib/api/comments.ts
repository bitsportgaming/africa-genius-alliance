import { apiClient } from './client';
import type { Comment, APIResponse } from '@/types';

export interface CreateCommentRequest {
  postId: string;
  content: string;
  authorId: string;
  authorName: string;
  authorAvatar?: string;
  parentId?: string;
}

export const commentsAPI = {
  async getPostComments(postId: string): Promise<APIResponse<Comment[]>> {
    return apiClient.get(`/comments/${postId}`);
  },

  async createComment(data: CreateCommentRequest): Promise<APIResponse<Comment>> {
    const { postId, ...body } = data;
    return apiClient.post(`/comments/${postId}`, body);
  },

  async likeComment(postId: string, commentId: string, userId: string): Promise<APIResponse<{ liked: boolean; likesCount: number }>> {
    return apiClient.post(`/comments/${postId}/${commentId}/like`, { userId });
  },

  async deleteComment(postId: string, commentId: string, authorId: string): Promise<APIResponse<void>> {
    return apiClient.delete(`/comments/${postId}/${commentId}`, { data: { authorId } });
  },
};
