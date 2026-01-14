'use client';

import { useAuth } from '@/lib/store/auth-store';
import { AGACard, AGAButton, AGAPill, AGAChip, ShareMenu } from '@/components/ui';
import Link from 'next/link';
import {
  Vote,
  Users,
  DollarSign,
  TrendingUp,
  Heart,
  MessageCircle,
  Share2,
  ShieldCheck,
  Loader2,
  Radio,
  Eye
} from 'lucide-react';
import { useState, useEffect, useCallback } from 'react';
import { apiClient, usersAPI, postsAPI, liveAPI, LiveStream } from '@/lib/api';

interface SupporterStats {
  supporterStats: {
    votesCast: number;
    followsTotal: number;
    donationsTotal: number;
  };
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
  isAdminPost?: boolean;
}

export function SupporterDashboard() {
  const { user } = useAuth();
  const [feedFilter, setFeedFilter] = useState<'forYou' | 'following' | 'trending'>('forYou');
  const [stats, setStats] = useState<SupporterStats | null>(null);
  const [trendingGeniuses, setTrendingGeniuses] = useState<any[]>([]);
  const [feedPosts, setFeedPosts] = useState<Post[]>([]);
  const [liveStreams, setLiveStreams] = useState<LiveStream[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [followingUsers, setFollowingUsers] = useState<Set<string>>(new Set());
  const [page, setPage] = useState(1);
  const [loadingMore, setLoadingMore] = useState(false);

  useEffect(() => {
    const fetchDashboardData = async () => {
      if (!user?._id) return;

      try {
        setLoading(true);
        setError(null);

        // Fetch supporter stats
        const statsResponse: any = await apiClient.get(`/users/${user._id}/stats`);
        if (statsResponse.success && statsResponse.data) {
          setStats(statsResponse.data);
        }

        // Fetch trending geniuses
        const geniusesResponse = await usersAPI.getGeniuses({ limit: 3 });
        if (geniusesResponse.data) {
          setTrendingGeniuses(geniusesResponse.data);
        }

        // Fetch live streams
        try {
          const liveResponse = await liveAPI.getLiveStreams({ status: 'live', limit: 2 });
          if (liveResponse.success && liveResponse.data) {
            setLiveStreams(liveResponse.data);
          }
        } catch (e) {
          console.log('No live streams available');
        }

        // Fetch feed posts
        const postsResponse = await postsAPI.getPosts({ page: 1, limit: 10 });
        if (postsResponse.success && postsResponse.data) {
          // Add admin welcome post at the top
          const adminPost: Post = {
            _id: 'admin-welcome',
            authorId: 'aga-admin',
            authorName: 'AGA Official',
            authorAvatar: undefined,
            authorPosition: 'Africa Genius Alliance',
            content: '🌍 Welcome to Africa Genius Alliance! Together, we are building a platform where merit drives leadership. Every vote counts, every voice matters. Join us in shaping Africa\'s future!',
            likesCount: 892,
            commentsCount: 156,
            sharesCount: 78,
            likedBy: [],
            createdAt: new Date().toISOString(),
            isAdminPost: true,
          };
          setFeedPosts([adminPost as Post, ...(Array.isArray(postsResponse.data) ? postsResponse.data : [])]);
        }
      } catch (err: any) {
        console.error('Failed to fetch dashboard data:', err);
        setError(err.message || 'Failed to load dashboard');
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
    const interval = setInterval(fetchDashboardData, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, [user?._id]);

  // Refetch posts when filter changes
  useEffect(() => {
    const fetchFilteredPosts = async () => {
      if (!user?._id) return;
      try {
        const params: any = { page: 1, limit: 10 };
        if (feedFilter === 'following') {
          params.userId = user._id;
          params.feedType = 'following';
        } else if (feedFilter === 'trending') {
          params.sort = 'trending';
        }
        const postsResponse = await postsAPI.getPosts(params);
        if (postsResponse.success && postsResponse.data) {
          const adminPost: Post = {
            _id: 'admin-welcome',
            authorId: 'aga-admin',
            authorName: 'AGA Official',
            authorAvatar: undefined,
            authorPosition: 'Africa Genius Alliance',
            content: '🌍 Welcome to Africa Genius Alliance! Together, we are building a platform where merit drives leadership. Every vote counts, every voice matters. Join us in shaping Africa\'s future!',
            likesCount: 892,
            commentsCount: 156,
            sharesCount: 78,
            likedBy: [],
            createdAt: new Date().toISOString(),
            isAdminPost: true,
          };
          setFeedPosts([adminPost, ...(Array.isArray(postsResponse.data) ? postsResponse.data : [])]);
          setPage(1);
        }
      } catch (err) {
        console.error('Failed to fetch filtered posts:', err);
      }
    };
    fetchFilteredPosts();
  }, [feedFilter, user?._id]);

  const quickStats = {
    votesCast: stats?.supporterStats?.votesCast || 0,
    following: stats?.supporterStats?.followsTotal || 0,
    donated: stats?.supporterStats?.donationsTotal || 0,
  };

  const categories = [
    { name: 'Political', icon: '🏛️' },
    { name: 'Oversight', icon: '👁️' },
    { name: 'Technical', icon: '⚙️' },
    { name: 'Civic', icon: '🤝' },
  ];

  // Handle like action
  const handleLike = useCallback(async (postId: string) => {
    if (!user?._id || postId === 'admin-welcome') return;
    try {
      // Optimistically update UI
      const isLiked = feedPosts.find(p => p._id === postId)?.likedBy.includes(user._id);
      setFeedPosts(prev => prev.map(post => {
        if (post._id === postId) {
          return {
            ...post,
            likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
            likedBy: isLiked
              ? post.likedBy.filter(id => id !== user._id)
              : [...post.likedBy, user._id],
          };
        }
        return post;
      }));

      // Send request to backend
      await apiClient.post(`/posts/${postId}/like`, { userId: user._id });
    } catch (err) {
      console.error('Failed to like post:', err);
      // Revert optimistic update on error
      setFeedPosts(prev => prev.map(post => {
        if (post._id === postId) {
          const isLiked = post.likedBy.includes(user._id);
          return {
            ...post,
            likesCount: isLiked ? post.likesCount + 1 : post.likesCount - 1,
            likedBy: isLiked
              ? [...post.likedBy, user._id]
              : post.likedBy.filter(id => id !== user._id),
          };
        }
        return post;
      }));
    }
  }, [user?._id, feedPosts]);

  // Handle follow action
  const handleFollow = useCallback(async (userId: string) => {
    if (!user?._id) return;
    try {
      const isFollowing = followingUsers.has(userId);
      if (isFollowing) {
        await usersAPI.unfollowUser(userId);
        setFollowingUsers(prev => {
          const next = new Set(prev);
          next.delete(userId);
          return next;
        });
      } else {
        await usersAPI.followUser(userId);
        setFollowingUsers(prev => new Set(prev).add(userId));
      }
    } catch (err) {
      console.error('Failed to follow/unfollow:', err);
    }
  }, [user?._id, followingUsers]);

  // Handle load more
  const handleLoadMore = useCallback(async () => {
    if (loadingMore) return;
    try {
      setLoadingMore(true);
      const nextPage = page + 1;
      const response = await postsAPI.getPosts({ page: nextPage, limit: 10 });
      if (response.success && response.data && Array.isArray(response.data)) {
        const newPosts = response.data as Post[];
        setFeedPosts(prev => [...prev, ...newPosts]);
        setPage(nextPage);
      }
    } catch (err) {
      console.error('Failed to load more posts:', err);
    } finally {
      setLoadingMore(false);
    }
  }, [page, loadingMore]);

  // Handle share
  const handleShare = useCallback(async (post: Post) => {
    const shareUrl = `${window.location.origin}/post/${post._id}`;
    const shareText = `Check out this post by ${post.authorName} on Africa Genius Alliance!`;

    if (navigator.share) {
      try {
        await navigator.share({
          title: 'Africa Genius Alliance',
          text: shareText,
          url: shareUrl,
        });
      } catch (err) {
        // User cancelled or error
      }
    } else {
      // Fallback: copy to clipboard
      try {
        await navigator.clipboard.writeText(shareUrl);
        alert('Link copied to clipboard!');
      } catch (err) {
        console.error('Failed to copy:', err);
      }
    }
  }, []);

  if (loading && !stats) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <Loader2 className="w-12 h-12 text-primary animate-spin mx-auto mb-4" />
          <p className="text-text-gray">Loading your dashboard...</p>
        </div>
      </div>
    );
  }

  if (error && !stats) {
    return (
      <div className="max-w-2xl mx-auto mt-12">
        <AGACard variant="elevated" padding="lg">
          <div className="text-center py-8">
            <p className="text-red-600 mb-4">{error}</p>
            <AGAButton variant="primary" onClick={() => window.location.reload()}>
              Retry
            </AGAButton>
          </div>
        </AGACard>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Welcome Section */}
      <div>
        <h1 className="text-4xl font-black text-text-dark mb-2">
          Welcome back, {user?.displayName || user?.email?.split('@')[0] || 'there'}!
        </h1>
        <p className="text-lg text-text-gray">
          Discover leaders, cast votes, and shape Africa's future
        </p>
      </div>

      {/* Quick Stats */}
      <section>
        <h2 className="text-2xl font-bold text-text-dark mb-4">Your Impact</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <AGACard variant="elevated" padding="lg">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                <Vote className="w-6 h-6 text-primary" />
              </div>
              <div>
                <h3 className="text-3xl font-black text-text-dark">
                  {quickStats.votesCast}
                </h3>
                <p className="text-sm text-text-gray mt-1">Votes Cast</p>
              </div>
            </div>
          </AGACard>

          <AGACard variant="elevated" padding="lg">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-xl bg-secondary/10 flex items-center justify-center">
                <Users className="w-6 h-6 text-secondary" />
              </div>
              <div>
                <h3 className="text-3xl font-black text-text-dark">
                  {quickStats.following}
                </h3>
                <p className="text-sm text-text-gray mt-1">Following</p>
              </div>
            </div>
          </AGACard>

          <AGACard variant="elevated" padding="lg">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center">
                <DollarSign className="w-6 h-6 text-green-600" />
              </div>
              <div>
                <h3 className="text-3xl font-black text-text-dark">
                  ${quickStats.donated.toLocaleString()}
                </h3>
                <p className="text-sm text-text-gray mt-1">Donated</p>
              </div>
            </div>
          </AGACard>
        </div>
      </section>

      {/* Live Now */}
      {liveStreams.length > 0 && (
        <section>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-2xl font-bold text-text-dark flex items-center gap-2">
              <Radio className="w-6 h-6 text-red-500 animate-pulse" />
              Live Now
            </h2>
            <Link href="/live">
              <AGAButton variant="ghost" size="sm">View All</AGAButton>
            </Link>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {liveStreams.map((stream) => (
              <Link key={stream._id} href={`/live/${stream._id}`}>
                <AGACard variant="elevated" padding="lg" hoverable className="relative overflow-hidden">
                  <div className="absolute top-4 left-4 flex items-center gap-2 px-3 py-1 bg-red-500 text-white text-xs font-bold rounded-full">
                    <span className="w-2 h-2 bg-white rounded-full animate-pulse" />
                    LIVE
                  </div>
                  <div className="pt-8">
                    <div className="flex items-center gap-4">
                      <div className="w-14 h-14 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-xl">
                        {stream.hostName?.[0]?.toUpperCase() || 'G'}
                      </div>
                      <div className="flex-1">
                        <h3 className="font-bold text-text-dark">{stream.title}</h3>
                        <p className="text-sm text-text-gray">{stream.hostName}</p>
                      </div>
                      <div className="flex items-center gap-1 text-text-gray">
                        <Eye className="w-4 h-4" />
                        <span className="text-sm font-semibold">{stream.viewerCount || 0}</span>
                      </div>
                    </div>
                  </div>
                </AGACard>
              </Link>
            ))}
          </div>
        </section>
      )}

      {/* Trending Geniuses */}
      {trendingGeniuses.length > 0 && (
        <section>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-2xl font-bold text-text-dark">Trending Geniuses</h2>
            <Link href="/explore">
              <AGAButton variant="ghost" size="sm">Explore All</AGAButton>
            </Link>
          </div>
          <div className="flex gap-4 overflow-x-auto pb-4">
            {trendingGeniuses.map((genius, index) => (
              <AGACard
                key={genius.userId || index}
                variant="elevated"
                padding="lg"
                hoverable
                className="flex-shrink-0 w-72"
              >
                <div className="text-center">
                  <div className="w-20 h-20 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-2xl mx-auto mb-4">
                    {genius.displayName?.[0]?.toUpperCase() || 'G'}
                  </div>
                  <h3 className="font-bold text-text-dark mb-1">
                    {genius.displayName || 'Genius'}
                  </h3>
                  <p className="text-sm text-text-gray mb-3">
                    {genius.positionTitle || 'Leader'}
                  </p>
                  <div className="flex items-center justify-center gap-2 mb-4">
                    <TrendingUp className="w-4 h-4 text-green-500" />
                    <span className="text-sm font-semibold text-text-dark">
                      {genius.votesReceived?.toLocaleString() || 0} votes
                    </span>
                  </div>
                  <Link href={`/genius/${genius.userId}`}>
                    <AGAButton variant="primary" size="sm" fullWidth>
                      Follow
                    </AGAButton>
                  </Link>
                </div>
              </AGACard>
            ))}
          </div>
        </section>
      )}

      {/* Category Browse */}
      <section>
        <h2 className="text-2xl font-bold text-text-dark mb-4">
          Browse by Category
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {categories.map((category, index) => (
            <Link key={index} href={`/explore?category=${category.name.toLowerCase()}`}>
              <AGACard variant="elevated" padding="md" hoverable className="text-center">
                <div className="text-4xl mb-2">{category.icon}</div>
                <h3 className="font-bold text-text-dark mb-1">
                  {category.name}
                </h3>
                <p className="text-sm text-text-gray">
                  Explore Leaders
                </p>
              </AGACard>
            </Link>
          ))}
        </div>
      </section>

      {/* Feed */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-2xl font-bold text-text-dark">Your Feed</h2>
          <div className="flex gap-2">
            <AGAChip
              selected={feedFilter === 'forYou'}
              onClick={() => setFeedFilter('forYou')}
            >
              For You
            </AGAChip>
            <AGAChip
              selected={feedFilter === 'following'}
              onClick={() => setFeedFilter('following')}
            >
              Following
            </AGAChip>
            <AGAChip
              selected={feedFilter === 'trending'}
              onClick={() => setFeedFilter('trending')}
            >
              Trending
            </AGAChip>
          </div>
        </div>

        {/* Compact Twitter-style feed container */}
        <div className="max-w-2xl mx-auto">
          <div className="space-y-4">
            {feedPosts.map((post) => (
              <div
                key={post._id}
                className={`bg-white rounded-xl border transition-all hover:bg-gray-50 ${
                  post.isAdminPost
                    ? 'border-yellow-300 bg-gradient-to-r from-yellow-50/30 to-amber-50/30'
                    : 'border-gray-100'
                }`}
              >
                {/* Admin Post Badge */}
                {post.isAdminPost && (
                  <div className="flex items-center gap-2 px-4 py-2 border-b border-yellow-200/50">
                    <div className="flex items-center gap-1.5 px-2 py-0.5 bg-gradient-to-r from-yellow-400 to-amber-500 rounded-full">
                      <ShieldCheck className="w-3 h-3 text-white" />
                      <span className="text-[10px] font-bold text-white">Official AGA Announcement</span>
                    </div>
                  </div>
                )}

                <div className="p-4">
                  {/* Post Header - Compact */}
                  <div className="flex items-start gap-3 mb-3">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center text-white font-semibold text-sm flex-shrink-0 ${
                      post.isAdminPost
                        ? 'bg-gradient-to-br from-yellow-400 to-amber-600'
                        : 'bg-gradient-accent'
                    }`}>
                      {post.isAdminPost ? '✦' : (post.authorName?.[0]?.toUpperCase() || 'U')}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-1.5 flex-wrap">
                        <h3 className="font-semibold text-text-dark text-sm">{post.authorName}</h3>
                        {post.isAdminPost && (
                          <div className="flex items-center" title="Verified Admin">
                            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none">
                              <path d="M9 12l2 2 4-4" stroke="#EAB308" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" fill="#FBBF24" stroke="#EAB308" strokeWidth="1"/>
                            </svg>
                          </div>
                        )}
                        <span className="text-text-gray text-xs">·</span>
                        <span className="text-text-gray text-xs">{post.authorPosition}</span>
                        <span className="text-text-gray text-xs">·</span>
                        <span className="text-text-gray text-xs">
                          {new Date(post.createdAt).toLocaleDateString()}
                        </span>
                      </div>
                    </div>
                    {!post.isAdminPost && (
                      <button
                        onClick={() => handleFollow(post.authorId)}
                        className={`text-xs font-semibold px-3 py-1 rounded-full transition-colors ${
                          followingUsers.has(post.authorId)
                            ? 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                            : 'bg-primary text-white hover:bg-primary/90'
                        }`}
                      >
                        {followingUsers.has(post.authorId) ? 'Following' : 'Follow'}
                      </button>
                    )}
                  </div>

                  {/* Post Content - Compact */}
                  <p className="text-text-dark text-sm leading-relaxed mb-3">
                    {post.content}
                  </p>

                  {/* Post Images */}
                  {post.mediaURLs && post.mediaURLs.length > 0 && (
                    <div className="mb-3 rounded-lg overflow-hidden border border-gray-100">
                      {post.mediaURLs.length === 1 ? (
                        <div className="relative">
                          <img
                            src={`${process.env.NEXT_PUBLIC_API_URL || 'https://africageniusalliance.com'}${post.mediaURLs[0]}`}
                            alt="Post image"
                            className="w-full h-auto max-h-[450px] object-cover"
                          />
                          <div className="absolute bottom-2 right-2 text-white/20 font-semibold text-sm pointer-events-none select-none">
                            Africa Genius Alliance
                          </div>
                        </div>
                      ) : (
                        <div className="grid grid-cols-2 gap-0.5">
                          {post.mediaURLs.slice(0, 4).map((url, index) => (
                            <div key={index} className="relative">
                              <img
                                src={`${process.env.NEXT_PUBLIC_API_URL || 'https://africageniusalliance.com'}${url}`}
                                alt={`Post image ${index + 1}`}
                                className="w-full h-48 object-cover"
                              />
                              {index === 3 && post.mediaURLs!.length > 4 && (
                                <div className="absolute inset-0 bg-black/60 flex items-center justify-center text-white text-lg font-bold">
                                  +{post.mediaURLs!.length - 4}
                                </div>
                              )}
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  )}

                  {/* Post Actions - Compact Twitter-style */}
                  <div className="flex items-center justify-between pt-2 border-t border-gray-100">
                    <button
                      onClick={() => handleLike(post._id)}
                      className={`flex items-center gap-1.5 px-2 py-1 rounded-full transition-colors ${
                        post.likedBy.includes(user?._id || '')
                          ? 'text-red-500 bg-red-50'
                          : 'text-text-gray hover:text-red-500 hover:bg-red-50'
                      }`}
                    >
                      <Heart className={`w-4 h-4 ${post.likedBy.includes(user?._id || '') ? 'fill-current' : ''}`} />
                      <span className="text-xs font-medium">{post.likesCount}</span>
                    </button>
                    <Link
                      href={`/post/${post._id}`}
                      className="flex items-center gap-1.5 px-2 py-1 rounded-full text-text-gray hover:text-primary hover:bg-primary/10 transition-colors"
                    >
                      <MessageCircle className="w-4 h-4" />
                      <span className="text-xs font-medium">{post.commentsCount}</span>
                    </Link>
                    <div className="flex items-center gap-1.5 px-2 py-1 rounded-full text-text-gray hover:text-green-500 hover:bg-green-50 transition-colors">
                      <ShareMenu
                        postId={post._id}
                        postContent={post.content}
                        authorName={post.authorName}
                      />
                      <span className="text-xs font-medium">{post.sharesCount}</span>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {feedPosts.length > 0 && (
            <div className="mt-6 text-center">
              <AGAButton variant="outline" onClick={handleLoadMore} loading={loadingMore}>
                {loadingMore ? 'Loading...' : 'Load More Posts'}
              </AGAButton>
            </div>
          )}
        </div>
      </section>
    </div>
  );
}
