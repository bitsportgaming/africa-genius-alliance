'use client';

import { useState, useCallback, useEffect } from 'react';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { AGACard, AGAButton, AGAPill, AGAChip } from '@/components/ui';
import { Search, Filter, TrendingUp, Users, MapPin, Grid, List, Loader2, ThumbsUp } from 'lucide-react';
import Link from 'next/link';
import { usersAPI, apiClient } from '@/lib/api';
import { useAuth } from '@/lib/store/auth-store';

interface Genius {
  id: string;
  name: string;
  avatar: string;
  position: string;
  category: string;
  country: string;
  votes: number;
  followers: number;
  rank: number;
  bio: string;
  verified: boolean;
}

export default function ExplorePage() {
  const { user } = useAuth();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [selectedCountry, setSelectedCountry] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [followingUsers, setFollowingUsers] = useState<Set<string>>(new Set());
  const [followLoading, setFollowLoading] = useState<string | null>(null);
  const [voteLoading, setVoteLoading] = useState<string | null>(null);
  const [votedGeniuses, setVotedGeniuses] = useState<Set<string>>(new Set());
  const [geniuses, setGeniuses] = useState<Genius[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  // Fetch geniuses from API
  useEffect(() => {
    const fetchGeniuses = async () => {
      setLoading(true);
      try {
        const params: any = { limit: 12, page };
        if (selectedCategory) params.category = selectedCategory;
        if (selectedCountry) params.country = selectedCountry;
        if (searchQuery) params.search = searchQuery;

        const response = await usersAPI.getGeniuses(params);
        if (response.success && response.data) {
          const mappedGeniuses = response.data.map((g: any, index: number) => ({
            id: g.userId || g._id,
            name: g.displayName || 'Genius',
            avatar: g.displayName?.[0]?.toUpperCase() || 'G',
            position: g.positionTitle || 'Leader',
            category: g.geniusCategory || 'Political',
            country: g.country || 'Africa',
            votes: g.votesReceived || 0,
            followers: g.followersCount || 0,
            rank: index + 1 + (page - 1) * 12,
            bio: g.bio || '',
            verified: g.verificationStatus === 'verified',
          }));
          setGeniuses(mappedGeniuses);
          setTotalPages(response.pagination?.totalPages || 1);
        }
      } catch (err) {
        console.error('Failed to fetch geniuses:', err);
      } finally {
        setLoading(false);
      }
    };
    fetchGeniuses();
  }, [selectedCategory, selectedCountry, searchQuery, page]);

  // Handle follow action
  const handleFollow = useCallback(async (geniusId: string) => {
    if (!user?._id) return;
    setFollowLoading(geniusId);
    try {
      const isFollowing = followingUsers.has(geniusId);
      if (isFollowing) {
        await usersAPI.unfollowUser(geniusId);
        setFollowingUsers(prev => {
          const next = new Set(prev);
          next.delete(geniusId);
          return next;
        });
      } else {
        await usersAPI.followUser(geniusId);
        setFollowingUsers(prev => new Set(prev).add(geniusId));
      }
    } catch (err) {
      console.error('Failed to follow/unfollow:', err);
    } finally {
      setFollowLoading(null);
    }
  }, [user?._id, followingUsers]);

  // Handle vote action
  const handleVote = useCallback(async (geniusId: string) => {
    if (!user?._id) return;
    setVoteLoading(geniusId);
    try {
      await apiClient.post(`/users/${geniusId}/vote`, { voterId: user._id });
      setVotedGeniuses(prev => new Set(prev).add(geniusId));

      // Update the genius votes count in the UI
      setGeniuses(prev => prev.map(g =>
        g.id === geniusId ? { ...g, votes: g.votes + 1 } : g
      ));
    } catch (err) {
      console.error('Failed to vote:', err);
    } finally {
      setVoteLoading(null);
    }
  }, [user?._id]);

  // Categories and countries for filtering
  const categories = ['All', 'Political', 'Oversight', 'Technical', 'Civic'];
  const countries = ['All Countries', 'Nigeria', 'Ghana', 'Kenya', 'South Africa', 'Egypt'];

  return (
    <ProtectedRoute>
      <DashboardLayout>
        <div className="space-y-8">
          {/* Header */}
          <div>
            <h1 className="text-4xl font-black text-text-dark mb-2">
              Explore Geniuses
            </h1>
            <p className="text-lg text-text-gray">
              Discover Africa's brightest minds and support leaders based on merit
            </p>
          </div>

          {/* Search & Filters */}
          <AGACard variant="elevated" padding="lg">
            <div className="flex flex-col lg:flex-row gap-4">
              {/* Search */}
              <div className="flex-1">
                <div className="relative">
                  <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <input
                    type="text"
                    placeholder="Search by name, position, or keyword..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-12 pr-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
                  />
                </div>
              </div>

              {/* View Toggle */}
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setViewMode('grid')}
                  className={`p-3 rounded-lg transition-colors ${
                    viewMode === 'grid'
                      ? 'bg-primary text-white'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  <Grid className="w-5 h-5" />
                </button>
                <button
                  onClick={() => setViewMode('list')}
                  className={`p-3 rounded-lg transition-colors ${
                    viewMode === 'list'
                      ? 'bg-primary text-white'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  <List className="w-5 h-5" />
                </button>
              </div>
            </div>

            {/* Filter Chips */}
            <div className="mt-4 space-y-3">
              {/* Categories */}
              <div>
                <label className="text-sm font-semibold text-text-dark mb-2 block">
                  Category
                </label>
                <div className="flex flex-wrap gap-2">
                  {categories.map((category) => (
                    <AGAChip
                      key={category}
                      selected={selectedCategory === category || (category === 'All' && !selectedCategory)}
                      onClick={() => setSelectedCategory(category === 'All' ? null : category)}
                    >
                      {category}
                    </AGAChip>
                  ))}
                </div>
              </div>

              {/* Countries */}
              <div>
                <label className="text-sm font-semibold text-text-dark mb-2 block">
                  Country
                </label>
                <div className="flex flex-wrap gap-2">
                  {countries.map((country) => (
                    <AGAChip
                      key={country}
                      selected={selectedCountry === country || (country === 'All Countries' && !selectedCountry)}
                      onClick={() => setSelectedCountry(country === 'All Countries' ? null : country)}
                    >
                      {country}
                    </AGAChip>
                  ))}
                </div>
              </div>
            </div>
          </AGACard>

          {/* Results Count */}
          <div className="flex items-center justify-between">
            <p className="text-text-gray">
              {loading ? 'Loading...' : (
                <>Showing <span className="font-semibold text-text-dark">{geniuses.length}</span> geniuses</>
              )}
            </p>
            <select className="px-4 py-2 rounded-lg border border-gray-200 text-text-dark focus:outline-none focus:ring-2 focus:ring-primary/20">
              <option>Most Votes</option>
              <option>Most Followers</option>
              <option>Newest</option>
              <option>Rising Stars</option>
            </select>
          </div>

          {/* Loading State */}
          {loading && (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="w-8 h-8 text-primary animate-spin" />
            </div>
          )}

          {/* Empty State */}
          {!loading && geniuses.length === 0 && (
            <AGACard variant="elevated" padding="lg" className="text-center py-12">
              <p className="text-text-gray text-lg">No geniuses found matching your criteria.</p>
              <p className="text-text-gray mt-2">Try adjusting your filters or search query.</p>
            </AGACard>
          )}

          {/* Geniuses Grid/List */}
          {!loading && geniuses.length > 0 && viewMode === 'grid' ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {geniuses.map((genius) => (
                <AGACard
                  key={genius.id}
                  variant="elevated"
                  padding="lg"
                  hoverable
                  className="group"
                >
                  {/* Rank Badge */}
                  <div className="absolute top-4 right-4">
                    <AGAPill
                      variant={genius.rank <= 3 ? 'secondary' : 'neutral'}
                      size="sm"
                    >
                      #{genius.rank}
                    </AGAPill>
                  </div>

                  {/* Avatar & Name */}
                  <div className="text-center mb-4">
                    <div className="w-20 h-20 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-2xl mx-auto mb-3 group-hover:scale-110 transition-transform">
                      {genius.avatar}
                    </div>
                    <h3 className="font-bold text-text-dark text-lg flex items-center justify-center gap-1">
                      {genius.name}
                      {genius.verified && (
                        <span className="text-blue-500" title="Verified">
                          ✓
                        </span>
                      )}
                    </h3>
                    <p className="text-sm text-text-gray mb-2">
                      {genius.position}
                    </p>
                    <div className="flex items-center justify-center gap-2">
                      <AGAPill variant="primary" size="sm">
                        {genius.category}
                      </AGAPill>
                      <AGAPill variant="neutral" size="sm">
                        <MapPin className="w-3 h-3 mr-1" />
                        {genius.country}
                      </AGAPill>
                    </div>
                  </div>

                  {/* Bio */}
                  <p className="text-sm text-text-gray text-center mb-4 line-clamp-2">
                    {genius.bio}
                  </p>

                  {/* Stats */}
                  <div className="flex items-center justify-around py-3 border-y border-gray-200 mb-4">
                    <div className="text-center">
                      <div className="flex items-center justify-center gap-1 text-sm font-semibold text-text-dark">
                        <TrendingUp className="w-4 h-4" />
                        {genius.votes.toLocaleString()}
                      </div>
                      <div className="text-xs text-text-gray">Votes</div>
                    </div>
                    <div className="w-px h-8 bg-gray-200" />
                    <div className="text-center">
                      <div className="flex items-center justify-center gap-1 text-sm font-semibold text-text-dark">
                        <Users className="w-4 h-4" />
                        {genius.followers.toLocaleString()}
                      </div>
                      <div className="text-xs text-text-gray">Followers</div>
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="space-y-2">
                    <div className="flex gap-2">
                      <AGAButton
                        variant={followingUsers.has(genius.id) ? 'outline' : 'primary'}
                        size="sm"
                        fullWidth
                        loading={followLoading === genius.id}
                        onClick={() => handleFollow(genius.id)}
                      >
                        {followingUsers.has(genius.id) ? 'Following' : 'Follow'}
                      </AGAButton>
                      <Link href={`/user/${genius.id}`} className="flex-1">
                        <AGAButton variant="outline" size="sm" fullWidth>
                          View
                        </AGAButton>
                      </Link>
                    </div>
                    <AGAButton
                      variant={votedGeniuses.has(genius.id) ? 'outline' : 'secondary'}
                      size="sm"
                      fullWidth
                      loading={voteLoading === genius.id}
                      onClick={() => handleVote(genius.id)}
                      disabled={votedGeniuses.has(genius.id)}
                    >
                      {votedGeniuses.has(genius.id) ? (
                        <>
                          <ThumbsUp className="w-4 h-4 mr-2 fill-current" />
                          Voted
                        </>
                      ) : (
                        <>
                          <ThumbsUp className="w-4 h-4 mr-2" />
                          Vote
                        </>
                      )}
                    </AGAButton>
                  </div>
                </AGACard>
              ))}
            </div>
          ) : !loading && geniuses.length > 0 && viewMode === 'list' ? (
            <div className="space-y-4">
              {geniuses.map((genius) => (
                <AGACard
                  key={genius.id}
                  variant="elevated"
                  padding="lg"
                  hoverable
                >
                  <div className="flex items-start gap-6">
                    {/* Avatar */}
                    <div className="w-16 h-16 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-xl flex-shrink-0">
                      {genius.avatar}
                    </div>

                    {/* Content */}
                    <div className="flex-1">
                      <div className="flex items-start justify-between mb-2">
                        <div>
                          <h3 className="font-bold text-text-dark text-lg flex items-center gap-1">
                            {genius.name}
                            {genius.verified && (
                              <span className="text-blue-500" title="Verified">
                                ✓
                              </span>
                            )}
                          </h3>
                          <p className="text-sm text-text-gray">
                            {genius.position}
                          </p>
                        </div>
                        <AGAPill
                          variant={genius.rank <= 3 ? 'secondary' : 'neutral'}
                          size="sm"
                        >
                          #{genius.rank}
                        </AGAPill>
                      </div>

                      <p className="text-sm text-text-gray mb-3">
                        {genius.bio}
                      </p>

                      <div className="flex items-center gap-2 mb-3">
                        <AGAPill variant="primary" size="sm">
                          {genius.category}
                        </AGAPill>
                        <AGAPill variant="neutral" size="sm">
                          <MapPin className="w-3 h-3 mr-1" />
                          {genius.country}
                        </AGAPill>
                      </div>

                      <div className="flex items-center gap-6">
                        <div className="flex items-center gap-2 text-sm text-text-gray">
                          <TrendingUp className="w-4 h-4" />
                          <span className="font-semibold">
                            {genius.votes.toLocaleString()}
                          </span>{' '}
                          votes
                        </div>
                        <div className="flex items-center gap-2 text-sm text-text-gray">
                          <Users className="w-4 h-4" />
                          <span className="font-semibold">
                            {genius.followers.toLocaleString()}
                          </span>{' '}
                          followers
                        </div>
                      </div>
                    </div>

                    {/* Actions */}
                    <div className="flex flex-col gap-2 flex-shrink-0">
                      <AGAButton
                        variant={followingUsers.has(genius.id) ? 'outline' : 'primary'}
                        size="sm"
                        loading={followLoading === genius.id}
                        onClick={() => handleFollow(genius.id)}
                      >
                        {followingUsers.has(genius.id) ? 'Following' : 'Follow'}
                      </AGAButton>
                      <AGAButton
                        variant={votedGeniuses.has(genius.id) ? 'outline' : 'secondary'}
                        size="sm"
                        loading={voteLoading === genius.id}
                        onClick={() => handleVote(genius.id)}
                        disabled={votedGeniuses.has(genius.id)}
                      >
                        {votedGeniuses.has(genius.id) ? (
                          <>
                            <ThumbsUp className="w-4 h-4 mr-2 fill-current" />
                            Voted
                          </>
                        ) : (
                          <>
                            <ThumbsUp className="w-4 h-4 mr-2" />
                            Vote
                          </>
                        )}
                      </AGAButton>
                      <Link href={`/user/${genius.id}`}>
                        <AGAButton variant="outline" size="sm">
                          View Profile
                        </AGAButton>
                      </Link>
                    </div>
                  </div>
                </AGACard>
              ))}
            </div>
          ) : null}

          {/* Pagination */}
          {!loading && geniuses.length > 0 && (
            <div className="flex justify-center">
              <div className="flex items-center gap-2">
                <AGAButton
                  variant="outline"
                  size="sm"
                  onClick={() => setPage(p => Math.max(1, p - 1))}
                  disabled={page === 1}
                >
                  Previous
                </AGAButton>
                <span className="px-4 py-2 text-text-dark">
                  Page {page} of {totalPages}
                </span>
                <AGAButton
                  variant="outline"
                  size="sm"
                  onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                  disabled={page === totalPages}
                >
                  Next
                </AGAButton>
              </div>
            </div>
          )}
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}
