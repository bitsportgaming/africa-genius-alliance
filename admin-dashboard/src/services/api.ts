import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || '/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('adminToken');
      localStorage.removeItem('adminUser');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: (email: string, password: string) =>
    api.post('/admin/login', { email, password }),
};

// Users API
export const usersAPI = {
  getAll: (params?: { page?: number; limit?: number; role?: string; status?: string; search?: string }) =>
    api.get('/admin/users', { params }),
  
  update: (userId: string, data: Partial<User>) =>
    api.put(`/admin/users/${userId}`, data),
  
  delete: (userId: string) =>
    api.delete(`/admin/users/${userId}`),
};

// Posts API
export const postsAPI = {
  getAll: (params?: { page?: number; limit?: number; status?: string; search?: string }) =>
    api.get('/admin/posts', { params }),

  create: (data: { content: string; mediaURLs?: string[] }) =>
    api.post('/admin/posts', data),

  update: (postId: string, data: { isFeatured?: boolean; isFlagged?: boolean; status?: string }) =>
    api.put(`/admin/posts/${postId}`, data),

  delete: (postId: string) =>
    api.delete(`/admin/posts/${postId}`),
};

// Elections API
export const electionsAPI = {
  getAll: (params?: { page?: number; limit?: number; status?: string }) =>
    api.get('/admin/elections', { params }),
  
  create: (data: CreateElectionData) =>
    api.post('/admin/elections', data),
  
  update: (electionId: string, data: Partial<Election>) =>
    api.put(`/admin/elections/${electionId}`, data),
  
  delete: (electionId: string) =>
    api.delete(`/admin/elections/${electionId}`),
};

// Stats API
export const statsAPI = {
  getDashboard: () => api.get('/admin/stats'),
};

// Types
export interface User {
  userId: string;
  username: string;
  displayName: string;
  email: string;
  role: 'regular' | 'genius' | 'admin' | 'superadmin';
  status: 'active' | 'suspended' | 'banned' | 'pending';
  isVerified: boolean;
  followersCount: number;
  votesReceived: number;
  createdAt: string;
  profileImageURL?: string;
  country?: string;
}

export interface Post {
  _id: string;
  postId?: string;
  authorId: string;
  authorName: string;
  content: string;
  mediaURLs: string[];
  likesCount: number;
  commentsCount: number;
  isFeatured: boolean;
  isFlagged: boolean;
  isAdminPost?: boolean;
  authorRole?: 'regular' | 'genius' | 'admin' | 'superadmin';
  status: 'active' | 'hidden' | 'removed';
  createdAt: string;
}

export interface Election {
  electionId: string;
  title: string;
  description: string;
  position: string;
  country: string;
  region?: string;
  status: 'upcoming' | 'active' | 'completed';
  startDate: string;
  endDate: string;
  candidates: Candidate[];
  totalVotes: number;
  totalVoters: number;
  blockchain?: {
    electionIdOnChain: number;
    isDeployed: boolean;
    deployTxHash: string;
    chainId: number;
  };
}

export interface Candidate {
  candidateId: string;
  userId: string;
  name: string;
  party: string;
  bio: string;
  manifesto: string;
  avatarURL: string;
  votesReceived: number;
}

export interface CreateElectionData {
  title: string;
  description: string;
  position: string;
  country?: string;
  region?: string;
  startDate: string;
  endDate: string;
  candidates: {
    name: string;
    party?: string;
    bio?: string;
    manifesto?: string;
    userId?: string;
  }[];
}

export default api;

