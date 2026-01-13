// Core Type Definitions - Matching Backend/Mobile App

export enum UserRole {
  GENIUS = 'genius',
  SUPPORTER = 'regular',
  ADMIN = 'admin',
  SUPERADMIN = 'superadmin',
}

export enum VerificationStatus {
  UNVERIFIED = 'unverified',
  PENDING = 'pending',
  VERIFIED = 'verified',
}

export enum GeniusCategory {
  POLITICAL = 'Political',
  OVERSIGHT = 'Oversight',
  TECHNICAL = 'Technical',
  CIVIC = 'Civic',
}

export enum PostType {
  TEXT = 'text',
  IMAGE = 'image',
  VIDEO = 'video',
  LIVE_ANNOUNCEMENT = 'liveAnnouncement',
}

export enum MediaType {
  NONE = 'none',
  IMAGE = 'image',
  VIDEO = 'video',
}

export enum LiveStatus {
  OFFLINE = 'offline',
  LIVE = 'live',
}

export interface User {
  _id: string;
  userId?: string;  // Custom user ID field from backend
  username: string;
  email: string;
  displayName: string;
  profileImageURL?: string;
  bio?: string;
  country?: string;
  age?: number;
  role: UserRole;
  verificationStatus: VerificationStatus;

  // Genius-specific fields
  geniusCategory?: GeniusCategory;
  geniusPosition?: string;
  sector?: string;
  isElectoralPosition?: boolean;
  manifestoShort?: string;

  // Stats
  followersCount: number;
  followingCount: number;
  votesReceived: number;
  postsCount: number;
  likesCount: number;
  donationsTotal: number;
  rank?: number;

  // Timestamps
  createdAt: string;
  updatedAt: string;
}

export interface Post {
  _id: string;
  content: string;
  authorId: string;
  authorName: string;
  authorAvatar?: string;
  authorPosition?: string;
  authorRole?: UserRole;

  mediaURLs: string[];
  mediaType: MediaType;
  postType: PostType;

  likesCount: number;
  commentsCount: number;
  sharesCount: number;
  votesCount: number;

  likedBy: string[];
  isActive: boolean;
  isFeatured: boolean;
  isFlagged: boolean;
  isAdminPost?: boolean;

  createdAt: string;
  updatedAt: string;
}

export interface Comment {
  _id: string;
  postId: string;
  authorId: string;
  authorName: string;
  authorAvatar?: string;
  content: string;
  parentCommentId?: string;
  likesCount: number;
  createdAt: string;
}

export interface GeniusProfile {
  userId: string;
  positionCategory: GeniusCategory;
  positionTitle: string;
  manifestoShort?: string;
  verifiedStatus: VerificationStatus;

  rank: number;
  votesTotal: number;
  followersTotal: number;
  likesTotal: number;
  donationsTotal: number;

  liveStatus: LiveStatus;
  stats24h: {
    votes: number;
    followers: number;
    profileViews: number;
  };
  weeklyVotes: number[];
}

export interface Vote {
  _id: string;
  voterId: string;
  targetGeniusId: string;
  positionId?: string;
  weight: number; // 1-4
  timestamp: string;
  transactionHash?: string;
}

export interface Election {
  _id: string;
  electionName: string;
  description: string;
  positions: string[];
  candidates: ElectionCandidate[];
  startDate: string;
  endDate: string;
  country?: string;
  region?: string;
  isActive: boolean;
}

export interface ElectionCandidate {
  userId: string;
  name: string;
  avatar?: string;
  position: string;
  votes: number;
}

export interface LiveStream {
  _id: string;
  streamerId: string;
  streamerName: string;
  streamerAvatar?: string;
  title: string;
  description?: string;
  viewerCount: number;
  startedAt: string;
  isActive: boolean;
}

export interface Notification {
  _id: string;
  userId: string;
  type: 'vote' | 'follow' | 'comment' | 'like' | 'donation' | 'system';
  title: string;
  message: string;
  isRead: boolean;
  actionUrl?: string;
  createdAt: string;
}

export interface APIResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  pagination?: {
    currentPage: number;
    totalPages: number;
    totalItems: number;
    itemsPerPage: number;
  };
  error?: string;
}

export interface ImpactStats {
  totalVotes: number;
  totalFollowers: number;
  rank: number;
  profileViews24h: number;
  delta24h: {
    votes: number;
    followers: number;
    rank: number;
    profileViews: number;
  };
  delta7d: {
    votes: number;
    followers: number;
  };
  weeklyVotesChart: number[];
  weeklyFollowersChart: number[];
}

export interface SupporterStats {
  votesCast: number;
  following: number;
  donated: number;
}
