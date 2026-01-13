'use client';

import { useState, useEffect } from 'react';
import { AGACard, AGAPill, AGAChip, AGAButton } from '@/components/ui';
import { Trophy, TrendingUp, TrendingDown, Crown, Filter, Loader2 } from 'lucide-react';
import Link from 'next/link';
import { usersAPI } from '@/lib/api';

interface LeaderboardEntry {
  id: string;
  rank: number;
  prevRank: number;
  name: string;
  avatar: string;
  position: string;
  category: string;
  country: string;
  votes: number;
  followers: number;
  trend: string;
}

export function SupporterImpactView() {
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [selectedCountry, setSelectedCountry] = useState<string | null>(null);
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>([]);
  const [loading, setLoading] = useState(true);

  // Fetch leaderboard from API
  useEffect(() => {
    const fetchLeaderboard = async () => {
      setLoading(true);
      try {
        const params: any = { limit: 20, sort: 'votes' };
        if (selectedCategory && selectedCategory !== 'All') {
          params.category = selectedCategory;
        }
        if (selectedCountry && selectedCountry !== 'All') {
          params.country = selectedCountry;
        }

        const response = await usersAPI.getGeniuses(params);
        if (response.success && response.data) {
          const mappedLeaderboard = response.data.map((g: any, index: number) => ({
            id: g.userId || g._id,
            rank: index + 1,
            prevRank: index + 1 + (Math.random() > 0.5 ? 1 : -1) * Math.floor(Math.random() * 3),
            name: g.displayName || 'Genius',
            avatar: g.displayName?.[0]?.toUpperCase() || 'G',
            position: g.positionTitle || 'Leader',
            category: g.geniusCategory || 'Political',
            country: g.country || 'Africa',
            votes: g.votesReceived || 0,
            followers: g.followersCount || 0,
            trend: `+${Math.floor(Math.random() * 20 + 5)}%`,
          }));
          setLeaderboard(mappedLeaderboard);
        }
      } catch (err) {
        console.error('Failed to fetch leaderboard:', err);
      } finally {
        setLoading(false);
      }
    };
    fetchLeaderboard();
  }, [selectedCategory, selectedCountry]);

  const risingStars = leaderboard
    .filter((g) => g.rank < g.prevRank)
    .sort((a, b) => (b.prevRank - b.rank) - (a.prevRank - a.rank))
    .slice(0, 3);

  const categories = ['All', 'Political', 'Oversight', 'Technical', 'Civic'];
  const countries = ['All', 'Nigeria', 'Ghana', 'Kenya', 'South Africa', 'Egypt'];

  const getRankIcon = (rank: number) => {
    if (rank === 1) return <Crown className="w-6 h-6 text-yellow-500" />;
    if (rank === 2) return <Crown className="w-6 h-6 text-gray-400" />;
    if (rank === 3) return <Crown className="w-6 h-6 text-orange-600" />;
    return null;
  };

  const getRankChange = (current: number, prev: number) => {
    if (current < prev) {
      return { icon: <TrendingUp className="w-4 h-4" />, variant: 'success' as const, text: `+${prev - current}` };
    } else if (current > prev) {
      return { icon: <TrendingDown className="w-4 h-4" />, variant: 'danger' as const, text: `-${current - prev}` };
    }
    return { icon: null, variant: 'neutral' as const, text: '—' };
  };

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-4xl font-black text-text-dark mb-2">
          Impact Leaderboard
        </h1>
        <p className="text-lg text-text-gray">
          Discover and support Africa's most impactful leaders
        </p>
      </div>

      {/* Filters */}
      <AGACard variant="elevated" padding="lg">
        <div className="space-y-4">
          <div>
            <label className="text-sm font-semibold text-text-dark mb-2 block">
              Filter by Category
            </label>
            <div className="flex flex-wrap gap-2">
              {categories.map((cat) => (
                <AGAChip
                  key={cat}
                  selected={selectedCategory === cat || (cat === 'All' && !selectedCategory)}
                  onClick={() => setSelectedCategory(cat === 'All' ? null : cat)}
                >
                  {cat}
                </AGAChip>
              ))}
            </div>
          </div>

          <div>
            <label className="text-sm font-semibold text-text-dark mb-2 block">
              Filter by Country
            </label>
            <div className="flex flex-wrap gap-2">
              {countries.map((country) => (
                <AGAChip
                  key={country}
                  selected={selectedCountry === country || (country === 'All' && !selectedCountry)}
                  onClick={() => setSelectedCountry(country === 'All' ? null : country)}
                >
                  {country}
                </AGAChip>
              ))}
            </div>
          </div>
        </div>
      </AGACard>

      {/* Loading State */}
      {loading && (
        <div className="flex items-center justify-center py-12">
          <Loader2 className="w-8 h-8 text-primary animate-spin" />
        </div>
      )}

      {/* Empty State */}
      {!loading && leaderboard.length === 0 && (
        <AGACard variant="elevated" padding="lg" className="text-center py-12">
          <p className="text-text-gray text-lg">No geniuses found matching your criteria.</p>
          <p className="text-text-gray mt-2">Try adjusting your filters.</p>
        </AGACard>
      )}

      {/* Rising Stars */}
      {!loading && risingStars.length > 0 && (
        <section>
          <h2 className="text-2xl font-bold text-text-dark mb-4 flex items-center gap-2">
            <TrendingUp className="w-6 h-6 text-green-500" />
            Rising Stars This Week
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {risingStars.map((genius) => {
              const change = getRankChange(genius.rank, genius.prevRank);
              return (
                <AGACard key={genius.rank} variant="elevated" padding="lg" hoverable>
                  <div className="text-center">
                    <div className="w-20 h-20 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-2xl mx-auto mb-3">
                      {genius.avatar}
                    </div>
                    <h3 className="font-bold text-text-dark mb-1">{genius.name}</h3>
                    <p className="text-sm text-text-gray mb-3">{genius.position}</p>
                    <div className="flex items-center justify-center gap-2 mb-3">
                      <AGAPill variant="primary" size="sm">
                        #{genius.rank}
                      </AGAPill>
                      <AGAPill variant={change.variant} size="sm">
                        {change.icon}
                        {change.text}
                      </AGAPill>
                    </div>
                    <Link href={`/genius/${genius.rank}`}>
                      <AGAButton variant="outline" size="sm" fullWidth>
                        View Profile
                      </AGAButton>
                    </Link>
                  </div>
                </AGACard>
              );
            })}
          </div>
        </section>
      )}

      {/* Leaderboard Table */}
      {!loading && leaderboard.length > 0 && (
      <section>
        <h2 className="text-2xl font-bold text-text-dark mb-4">
          All Geniuses
        </h2>
        <AGACard variant="elevated" padding="none">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200 bg-gray-50">
                  <th className="text-left py-4 px-6 text-sm font-semibold text-text-dark">
                    Rank
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-text-dark">
                    Genius
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-text-dark">
                    Category
                  </th>
                  <th className="text-left py-4 px-6 text-sm font-semibold text-text-dark">
                    Country
                  </th>
                  <th className="text-right py-4 px-6 text-sm font-semibold text-text-dark">
                    Votes
                  </th>
                  <th className="text-right py-4 px-6 text-sm font-semibold text-text-dark">
                    Followers
                  </th>
                  <th className="text-center py-4 px-6 text-sm font-semibold text-text-dark">
                    Trend
                  </th>
                  <th className="text-right py-4 px-6 text-sm font-semibold text-text-dark">
                    Action
                  </th>
                </tr>
              </thead>
              <tbody>
                {leaderboard.map((genius) => {
                  const change = getRankChange(genius.rank, genius.prevRank);
                  return (
                    <tr
                      key={genius.rank}
                      className={`border-b border-gray-100 hover:bg-gray-50 transition-colors ${
                        genius.rank <= 3 ? 'bg-primary/5' : ''
                      }`}
                    >
                      <td className="py-4 px-6">
                        <div className="flex items-center gap-2">
                          {getRankIcon(genius.rank)}
                          <span className="text-lg font-bold text-text-dark">
                            {genius.rank}
                          </span>
                        </div>
                      </td>
                      <td className="py-4 px-6">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-sm flex-shrink-0">
                            {genius.avatar}
                          </div>
                          <div>
                            <p className="font-semibold text-text-dark">
                              {genius.name}
                            </p>
                            <p className="text-xs text-text-gray">
                              {genius.position}
                            </p>
                          </div>
                        </div>
                      </td>
                      <td className="py-4 px-6">
                        <AGAPill variant="primary" size="sm">
                          {genius.category}
                        </AGAPill>
                      </td>
                      <td className="py-4 px-6">
                        <span className="text-sm text-text-gray">
                          {genius.country}
                        </span>
                      </td>
                      <td className="py-4 px-6 text-right">
                        <span className="font-semibold text-text-dark">
                          {genius.votes.toLocaleString()}
                        </span>
                      </td>
                      <td className="py-4 px-6 text-right">
                        <span className="font-semibold text-text-dark">
                          {genius.followers.toLocaleString()}
                        </span>
                      </td>
                      <td className="py-4 px-6 text-center">
                        <AGAPill variant={change.variant} size="sm">
                          {change.icon}
                          {genius.trend}
                        </AGAPill>
                      </td>
                      <td className="py-4 px-6 text-right">
                        <Link href={`/genius/${genius.rank}`}>
                          <AGAButton variant="ghost" size="sm">
                            View
                          </AGAButton>
                        </Link>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </AGACard>
      </section>
      )}
    </div>
  );
}
