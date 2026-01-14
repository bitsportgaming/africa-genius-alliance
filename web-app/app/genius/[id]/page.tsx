'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { AGACard, AGAButton, AGAPill } from '@/components/ui';
import { usersAPI, postsAPI } from '@/lib/api';
import { useAuth } from '@/lib/store/auth-store';
import {
  ArrowLeft, MapPin, Calendar, TrendingUp, Users, Award,
  Heart, MessageCircle, Share2, Loader2, ShieldCheck, Vote
} from 'lucide-react';
import Link from 'next/link';

interface GeniusProfile {
  _id: string;
  userId: string;
  displayName: string;
  email?: string;
  country?: string;
  bio?: string;
  positionTitle?: string;
  geniusCategory?: string;
  profileImageURL?: string;
  votesReceived?: number;
  followersCount?: number;
  followingCount?: number;
  rank?: number;
  verificationStatus?: string;
  createdAt?: string;
}

interface Post {
  _id: string;
  content: string;
  likesCount: number;
  commentsCount: number;
  sharesCount: number;
  createdAt: string;
}

export default function GeniusProfilePage() {
  const params = useParams();
  const router = useRouter();
  const { user } = useAuth();
  const geniusId = params.id as string;
  
  const [genius, setGenius] = useState<GeniusProfile | null>(null);
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isFollowing, setIsFollowing] = useState(false);
  const [isVoting, setIsVoting] = useState(false);

  useEffect(() => {
    const fetchGeniusProfile = async () => {
      if (!geniusId) return;
      try {
        setLoading(true);
        const response: any = await usersAPI.getUser(geniusId);
        if (response.success && response.data) {
          setGenius(response.data);
          // Check if current user follows this genius
          if (response.data.followers?.includes(user?._id)) {
            setIsFollowing(true);
          }
        } else {
          setError('Genius not found');
        }
        
        // Fetch genius posts
        const postsResponse = await postsAPI.getPosts({ authorId: geniusId, limit: 10 });
        if (postsResponse.success && postsResponse.data) {
          setPosts(Array.isArray(postsResponse.data) ? postsResponse.data : []);
        }
      } catch (err: any) {
        console.error('Failed to fetch genius:', err);
        setError(err.message || 'Failed to load profile');
      } finally {
        setLoading(false);
      }
    };

    fetchGeniusProfile();
  }, [geniusId, user?._id]);

  const handleFollow = async () => {
    if (!geniusId) return;
    try {
      if (isFollowing) {
        await usersAPI.unfollowUser(geniusId);
      } else {
        await usersAPI.followUser(geniusId);
      }
      setIsFollowing(!isFollowing);
      if (genius) {
        setGenius({
          ...genius,
          followersCount: (genius.followersCount || 0) + (isFollowing ? -1 : 1),
        });
      }
    } catch (err) {
      console.error('Failed to follow/unfollow:', err);
    }
  };

  const handleVote = async () => {
    if (!geniusId || isVoting) return;
    try {
      setIsVoting(true);
      const response: any = await usersAPI.voteForGenius(geniusId);
      if (response.success && genius) {
        setGenius({
          ...genius,
          votesReceived: response.data.votesReceived,
        });
      }
    } catch (err) {
      console.error('Failed to vote:', err);
    } finally {
      setIsVoting(false);
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

  if (error || !genius) {
    return (
      <ProtectedRoute>
        <DashboardLayout>
          <div className="max-w-2xl mx-auto mt-12">
            <AGACard variant="elevated" padding="lg">
              <div className="text-center py-8">
                <Users className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                <h2 className="text-xl font-bold text-text-dark mb-2">Genius Not Found</h2>
                <p className="text-text-gray mb-4">{error || 'This profile doesn\'t exist.'}</p>
                <Link href="/explore">
                  <AGAButton variant="primary">Explore Geniuses</AGAButton>
                </Link>
              </div>
            </AGACard>
          </div>
        </DashboardLayout>
      </ProtectedRoute>
    );
  }

  return (
    <ProtectedRoute>
      <DashboardLayout>
        <div className="max-w-4xl mx-auto space-y-6">
          {/* Back Button */}
          <button onClick={() => router.back()} className="flex items-center gap-2 text-text-gray hover:text-text-dark transition-colors">
            <ArrowLeft className="w-5 h-5" />
            <span>Back</span>
          </button>

          {/* Profile Header */}
          <AGACard variant="hero" padding="lg">
            <div className="flex flex-col md:flex-row gap-6 items-start">
              <div className="w-28 h-28 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-4xl">
                {genius.displayName?.[0]?.toUpperCase() || 'G'}
              </div>
              
              <div className="flex-1">
                <div className="flex items-start justify-between gap-4 flex-wrap">
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <h1 className="text-3xl font-black text-text-dark">{genius.displayName}</h1>
                      {genius.verificationStatus === 'verified' && (
                        <ShieldCheck className="w-6 h-6 text-green-500" />
                      )}
                    </div>
                    <p className="text-lg text-text-gray">{genius.positionTitle || 'Genius'}</p>
                    {genius.geniusCategory && (
                      <AGAPill variant="secondary" size="sm" className="mt-2">{genius.geniusCategory}</AGAPill>
                    )}
                  </div>
                  
                  <div className="flex gap-3">
                    <AGAButton variant={isFollowing ? 'outline' : 'primary'} onClick={handleFollow}>
                      {isFollowing ? 'Following' : 'Follow'}
                    </AGAButton>
                    <AGAButton
                      variant="secondary"
                      leftIcon={<Vote className="w-5 h-5" />}
                      onClick={handleVote}
                      disabled={isVoting}
                    >
                      {isVoting ? 'Voting...' : 'Vote'}
                    </AGAButton>
                  </div>
                </div>

                <div className="flex flex-wrap gap-4 mt-4 text-text-gray text-sm">
                  {genius.country && (
                    <div className="flex items-center gap-1"><MapPin className="w-4 h-4" />{genius.country}</div>
                  )}
                  {genius.createdAt && (
                    <div className="flex items-center gap-1">
                      <Calendar className="w-4 h-4" />
                      Joined {new Date(genius.createdAt).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}
                    </div>
                  )}
                </div>

                {genius.bio && <p className="mt-4 text-text-dark">{genius.bio}</p>}
              </div>
            </div>
          </AGACard>

          {/* Stats */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <AGACard variant="elevated" padding="md">
              <div className="text-center">
                <TrendingUp className="w-8 h-8 text-primary mx-auto mb-2" />
                <div className="text-2xl font-black text-text-dark">{genius.votesReceived?.toLocaleString() || 0}</div>
                <div className="text-xs text-text-gray">Votes</div>
              </div>
            </AGACard>
            <AGACard variant="elevated" padding="md">
              <div className="text-center">
                <Users className="w-8 h-8 text-secondary mx-auto mb-2" />
                <div className="text-2xl font-black text-text-dark">{genius.followersCount?.toLocaleString() || 0}</div>
                <div className="text-xs text-text-gray">Followers</div>
              </div>
            </AGACard>
            <AGACard variant="elevated" padding="md">
              <div className="text-center">
                <Users className="w-8 h-8 text-green-500 mx-auto mb-2" />
                <div className="text-2xl font-black text-text-dark">{genius.followingCount?.toLocaleString() || 0}</div>
                <div className="text-xs text-text-gray">Following</div>
              </div>
            </AGACard>
            <AGACard variant="elevated" padding="md">
              <div className="text-center">
                <Award className="w-8 h-8 text-yellow-500 mx-auto mb-2" />
                <div className="text-2xl font-black text-text-dark">#{genius.rank || '—'}</div>
                <div className="text-xs text-text-gray">Rank</div>
              </div>
            </AGACard>
          </div>

          {/* Posts */}
          <section>
            <h2 className="text-2xl font-bold text-text-dark mb-4">Posts</h2>
            {/* Compact Twitter-style posts container */}
            <div className="max-w-2xl">
              {posts.length > 0 ? (
                <div className="space-y-3">
                  {posts.map((post) => (
                    <div
                      key={post._id}
                      className="bg-white rounded-xl border border-gray-100 p-4 transition-all hover:bg-gray-50"
                    >
                      <p className="text-text-dark text-sm leading-relaxed mb-3">{post.content}</p>
                      <div className="flex items-center justify-between pt-2 border-t border-gray-100">
                        <span className="flex items-center gap-1.5 px-2 py-1 rounded-full text-text-gray hover:text-red-500 hover:bg-red-50 transition-colors text-xs">
                          <Heart className="w-4 h-4" />{post.likesCount}
                        </span>
                        <span className="flex items-center gap-1.5 px-2 py-1 rounded-full text-text-gray hover:text-primary hover:bg-primary/10 transition-colors text-xs">
                          <MessageCircle className="w-4 h-4" />{post.commentsCount}
                        </span>
                        <span className="flex items-center gap-1.5 px-2 py-1 rounded-full text-text-gray hover:text-green-500 hover:bg-green-50 transition-colors text-xs">
                          <Share2 className="w-4 h-4" />{post.sharesCount}
                        </span>
                        <span className="text-text-gray text-xs">{new Date(post.createdAt).toLocaleDateString()}</span>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="bg-white rounded-xl border border-gray-100 p-6 text-center text-text-gray">
                  <p className="text-sm">No posts yet</p>
                </div>
              )}
            </div>
          </section>
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}

