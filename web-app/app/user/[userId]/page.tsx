'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { useAuth } from '@/lib/store/auth-store';
import { AGACard, AGAButton, AGAPill } from '@/components/ui';
import {
  Heart,
  MessageCircle,
  Share2,
  Users,
  Award,
  Eye,
  Loader2,
  FileText,
  UserPlus,
  UserCheck
} from 'lucide-react';
import { apiClient, postsAPI, usersAPI } from '@/lib/api';

interface UserProfile {
  userId: string;
  displayName: string;
  username: string;
  bio: string;
  country: string;
  profileImageURL?: string;
  role: string;
  positionTitle?: string;
  followersCount: number;
  followingCount: number;
  votesReceived: number;
  isVerified?: boolean;
}

interface Post {
  _id: string;
  authorId: string;
  authorName: string;
  authorAvatar?: string;
  authorPosition?: string;
  content: string;
  mediaURLs?: string[];
  likesCount: number;
  commentsCount: number;
  sharesCount: number;
  likedBy: string[];
  createdAt: string;
}

export default function UserProfilePage() {
  const params = useParams();
  const { user: currentUser } = useAuth();
  const userId = params.userId as string;

  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [postsLoading, setPostsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isFollowing, setIsFollowing] = useState(false);

  useEffect(() => {
    const fetchUserProfile = async () => {
      try {
        setLoading(true);
        setError(null);

        // Fetch user profile
        const response: any = await apiClient.get(`/users/${userId}/stats`);
        if (response.success && response.data?.profile) {
          setProfile(response.data.profile);

          // Check if current user is following this user
          if (currentUser?._id) {
            const followResponse: any = await apiClient.get(`/users/${currentUser._id}/stats`);
            if (followResponse.success && followResponse.data?.profile) {
              // Check if userId is in following array
              // This would need to be implemented in the API response
              setIsFollowing(false); // Placeholder
            }
          }
        }
      } catch (err: any) {
        console.error('Failed to fetch user profile:', err);
        setError(err.message || 'Failed to load profile');
      } finally {
        setLoading(false);
      }
    };

    fetchUserProfile();
  }, [userId, currentUser?._id]);

  useEffect(() => {
    const fetchUserPosts = async () => {
      try {
        setPostsLoading(true);
        const postsResponse = await postsAPI.getPosts({ authorId: userId, page: 1, limit: 20 });
        if (postsResponse.success && postsResponse.data) {
          setPosts(Array.isArray(postsResponse.data) ? postsResponse.data : []);
        }
      } catch (err) {
        console.error('Failed to fetch user posts:', err);
      } finally {
        setPostsLoading(false);
      }
    };

    if (userId) {
      fetchUserPosts();
    }
  }, [userId]);

  const handleFollow = async () => {
    if (!currentUser?._id) return;
    try {
      await apiClient.post(`/users/${userId}/follow`, { followerId: currentUser._id });
      setIsFollowing(!isFollowing);
      setProfile(prev => prev ? {
        ...prev,
        followersCount: prev.followersCount + (isFollowing ? -1 : 1)
      } : null);
    } catch (err) {
      console.error('Failed to follow/unfollow user:', err);
    }
  };

  const handleVote = async () => {
    if (!currentUser?._id) return;
    try {
      await apiClient.post(`/users/${userId}/vote`, { voterId: currentUser._id });
      setProfile(prev => prev ? {
        ...prev,
        votesReceived: prev.votesReceived + 1
      } : null);
    } catch (err) {
      console.error('Failed to vote for user:', err);
    }
  };

  const handleLike = async (postId: string) => {
    if (!currentUser?._id) return;
    try {
      const isLiked = posts.find(p => p._id === postId)?.likedBy.includes(currentUser._id);
      setPosts(prev => prev.map(post => {
        if (post._id === postId) {
          return {
            ...post,
            likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
            likedBy: isLiked
              ? post.likedBy.filter(id => id !== currentUser._id)
              : [...post.likedBy, currentUser._id],
          };
        }
        return post;
      }));
      await apiClient.post(`/posts/${postId}/like`, { userId: currentUser._id });
    } catch (err) {
      console.error('Failed to like post:', err);
    }
  };

  if (loading) {
    return (
      <ProtectedRoute>
        <DashboardLayout>
          <div className="flex items-center justify-center min-h-[60vh]">
            <div className="text-center">
              <Loader2 className="w-12 h-12 text-primary animate-spin mx-auto mb-4" />
              <p className="text-text-gray">Loading profile...</p>
            </div>
          </div>
        </DashboardLayout>
      </ProtectedRoute>
    );
  }

  if (error || !profile) {
    return (
      <ProtectedRoute>
        <DashboardLayout>
          <AGACard variant="elevated" padding="lg">
            <div className="text-center py-12">
              <p className="text-red-600 mb-4">{error || 'Profile not found'}</p>
              <AGAButton variant="primary" onClick={() => window.history.back()}>
                Go Back
              </AGAButton>
            </div>
          </AGACard>
        </DashboardLayout>
      </ProtectedRoute>
    );
  }

  const isOwnProfile = currentUser?.userId === userId || currentUser?._id === userId;
  const isGenius = profile.role === 'genius';

  return (
    <ProtectedRoute>
      <DashboardLayout>
        <div className="space-y-6">
          {/* Profile Header */}
          <AGACard variant="elevated" padding="lg">
            <div className="flex flex-col md:flex-row gap-6">
              {/* Profile Image */}
              <div className="flex-shrink-0">
                <div className="w-32 h-32 rounded-full bg-gradient-accent flex items-center justify-center text-white text-4xl font-bold">
                  {profile.displayName?.charAt(0).toUpperCase() || 'U'}
                </div>
              </div>

              {/* Profile Info */}
              <div className="flex-1">
                <div className="flex items-start justify-between mb-4">
                  <div>
                    <div className="flex items-center gap-3 mb-2">
                      <h1 className="text-3xl font-black text-text-dark">{profile.displayName}</h1>
                      {isGenius && (
                        <AGAPill variant="secondary" size="sm">
                          Genius
                        </AGAPill>
                      )}
                      {profile.isVerified && (
                        <AGAPill variant="primary" size="sm">
                          Verified
                        </AGAPill>
                      )}
                    </div>
                    <p className="text-lg text-text-gray mb-1">@{profile.username}</p>
                    {profile.positionTitle && (
                      <p className="text-md text-primary font-medium">{profile.positionTitle}</p>
                    )}
                  </div>

                  {!isOwnProfile && (
                    <div className="flex gap-2">
                      <AGAButton
                        variant={isFollowing ? 'outline' : 'primary'}
                        onClick={handleFollow}
                      >
                        {isFollowing ? (
                          <>
                            <UserCheck className="w-4 h-4 mr-2" />
                            Following
                          </>
                        ) : (
                          <>
                            <UserPlus className="w-4 h-4 mr-2" />
                            Follow
                          </>
                        )}
                      </AGAButton>
                      {isGenius && (
                        <AGAButton variant="secondary" onClick={handleVote}>
                          <Award className="w-4 h-4 mr-2" />
                          Vote
                        </AGAButton>
                      )}
                    </div>
                  )}
                </div>

                <p className="text-text-dark mb-4">{profile.bio || 'No bio available'}</p>

                {/* Stats */}
                <div className="flex gap-6">
                  <div>
                    <span className="text-2xl font-bold text-text-dark">
                      {profile.followersCount.toLocaleString()}
                    </span>
                    <p className="text-sm text-text-gray">Followers</p>
                  </div>
                  <div>
                    <span className="text-2xl font-bold text-text-dark">
                      {profile.followingCount.toLocaleString()}
                    </span>
                    <p className="text-sm text-text-gray">Following</p>
                  </div>
                  {isGenius && (
                    <div>
                      <span className="text-2xl font-bold text-text-dark">
                        {profile.votesReceived.toLocaleString()}
                      </span>
                      <p className="text-sm text-text-gray">Votes</p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </AGACard>

          {/* Posts Section */}
          <div>
            <h2 className="text-2xl font-bold text-text-dark mb-4">
              {isOwnProfile ? 'Your Posts' : `Posts by ${profile.displayName}`}
            </h2>

            {postsLoading ? (
              <div className="flex justify-center py-12">
                <Loader2 className="w-8 h-8 text-primary animate-spin" />
              </div>
            ) : posts.length === 0 ? (
              <AGACard variant="elevated" padding="lg">
                <div className="text-center py-12">
                  <FileText className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                  <h3 className="text-lg font-bold text-text-dark mb-2">No posts yet</h3>
                  <p className="text-text-gray">
                    {isOwnProfile
                      ? 'Share your first update with your supporters!'
                      : `${profile.displayName} hasn't posted anything yet`}
                  </p>
                </div>
              </AGACard>
            ) : (
              <div className="space-y-4">
                {posts.map((post) => (
                  <AGACard key={post._id} variant="elevated" padding="lg" hoverable>
                    {/* Post Header */}
                    <div className="flex items-start gap-4 mb-4">
                      <div className="w-12 h-12 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold flex-shrink-0">
                        {post.authorName?.charAt(0).toUpperCase() || 'A'}
                      </div>
                      <div className="flex-1 min-w-0">
                        <h3 className="font-bold text-text-dark">{post.authorName}</h3>
                        <p className="text-sm text-text-gray">{post.authorPosition}</p>
                        <p className="text-xs text-text-gray mt-1">
                          {new Date(post.createdAt).toLocaleDateString('en-US', {
                            year: 'numeric',
                            month: 'short',
                            day: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit'
                          })}
                        </p>
                      </div>
                    </div>

                    {/* Post Content */}
                    <p className="text-text-dark mb-4 whitespace-pre-wrap">{post.content}</p>

                    {/* Post Images */}
                    {post.mediaURLs && post.mediaURLs.length > 0 && (
                      <div className={`grid gap-2 mb-4 ${post.mediaURLs.length > 1 ? 'grid-cols-2' : 'grid-cols-1'}`}>
                        {post.mediaURLs.map((url, index) => (
                          <img
                            key={index}
                            src={`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'}${url}`}
                            alt={`Post media ${index + 1}`}
                            className="w-full h-64 object-cover rounded-aga"
                          />
                        ))}
                      </div>
                    )}

                    {/* Engagement Stats & Actions */}
                    <div className="flex items-center gap-6 pt-4 border-t border-gray-100">
                      <button
                        onClick={() => handleLike(post._id)}
                        className={`flex items-center gap-2 transition-colors ${
                          post.likedBy.includes(currentUser?._id || '')
                            ? 'text-red-500'
                            : 'text-text-gray hover:text-red-500'
                        }`}
                      >
                        <Heart
                          className={`w-5 h-5 ${post.likedBy.includes(currentUser?._id || '') ? 'fill-current' : ''}`}
                        />
                        <span className="text-sm font-medium">{post.likesCount}</span>
                      </button>
                      <button className="flex items-center gap-2 text-text-gray hover:text-primary transition-colors">
                        <MessageCircle className="w-5 h-5" />
                        <span className="text-sm font-medium">{post.commentsCount}</span>
                      </button>
                      <button className="flex items-center gap-2 text-text-gray hover:text-secondary transition-colors">
                        <Share2 className="w-5 h-5" />
                        <span className="text-sm font-medium">{post.sharesCount}</span>
                      </button>
                    </div>
                  </AGACard>
                ))}
              </div>
            )}
          </div>
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}
