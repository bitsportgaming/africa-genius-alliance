'use client';

import { useState } from 'react';
import { useAuth } from '@/lib/store/auth-store';
import { AGACard, AGAPill, AGAButton } from '@/components/ui';
import { TrendingUp, TrendingDown, Users, Award, Eye, ArrowUp, ArrowDown, Target } from 'lucide-react';
import Link from 'next/link';

export function GeniusImpactView() {
  const { user } = useAuth();
  const [timeRange, setTimeRange] = useState<'24h' | '7d' | '30d'>('7d');

  // Mock data - Replace with real API
  const impactData = {
    rank: 12,
    rankChange: -2, // Improved by 2 positions
    totalVotes: 5432,
    totalFollowers: 2341,
    profileViews: 12456,
    delta24h: {
      votes: 45,
      followers: 23,
      profileViews: 342,
    },
    delta7d: {
      votes: 234,
      followers: 156,
    },
    votesChart: [120, 145, 178, 156, 198, 234, 289],
    followersChart: [1850, 1920, 1985, 2045, 2134, 2198, 2341],
  };

  const peerComparison = [
    { name: 'Avg. Top 10', votes: 6234, followers: 3456, rank: 5 },
    { name: 'You', votes: impactData.totalVotes, followers: impactData.totalFollowers, rank: impactData.rank },
    { name: 'Avg. Your Category', votes: 3891, followers: 1789, rank: 25 },
  ];

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-4xl font-black text-text-dark mb-2">
          Your Impact Analytics
        </h1>
        <p className="text-lg text-text-gray">
          Track your growth, rankings, and engagement metrics
        </p>
      </div>

      {/* Rank Card - Hero */}
      <AGACard variant="hero" padding="lg" className="relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-secondary/20 to-primary/20 rounded-full blur-3xl -mr-32 -mt-32" />

        <div className="relative">
          <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
            <div>
              <p className="text-sm font-semibold text-text-gray mb-2">Current Rank</p>
              <div className="flex items-baseline gap-3">
                <h2 className="text-7xl font-black text-text-dark">
                  #{impactData.rank}
                </h2>
                <div className="flex items-center gap-2">
                  {impactData.rankChange < 0 ? (
                    <>
                      <ArrowUp className="w-6 h-6 text-green-500" />
                      <AGAPill variant="success">
                        +{Math.abs(impactData.rankChange)} positions
                      </AGAPill>
                    </>
                  ) : impactData.rankChange > 0 ? (
                    <>
                      <ArrowDown className="w-6 h-6 text-red-500" />
                      <AGAPill variant="danger">
                        -{impactData.rankChange} positions
                      </AGAPill>
                    </>
                  ) : (
                    <AGAPill variant="neutral">No change</AGAPill>
                  )}
                </div>
              </div>
              <p className="text-sm text-text-gray mt-2">
                National ranking • {user?.geniusCategory} category
              </p>
            </div>

            <div className="flex gap-4">
              <Link href="/create">
                <AGAButton variant="secondary" size="lg" leftIcon={<Target className="w-5 h-5" />}>
                  Increase Impact
                </AGAButton>
              </Link>
            </div>
          </div>
        </div>
      </AGACard>

      {/* Time Range Selector */}
      <div className="flex justify-center gap-2">
        {(['24h', '7d', '30d'] as const).map((range) => (
          <button
            key={range}
            onClick={() => setTimeRange(range)}
            className={`px-6 py-2 rounded-full font-medium transition-all ${
              timeRange === range
                ? 'bg-primary text-white shadow-aga'
                : 'bg-white text-text-gray border border-gray-200 hover:border-primary/50'
            }`}
          >
            {range === '24h' ? 'Last 24 Hours' : range === '7d' ? 'Last 7 Days' : 'Last 30 Days'}
          </button>
        ))}
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <AGACard variant="elevated" padding="lg">
          <div className="flex items-start justify-between mb-2">
            <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
              <TrendingUp className="w-6 h-6 text-primary" />
            </div>
            <AGAPill
              variant={impactData.delta24h.votes >= 0 ? 'success' : 'danger'}
              size="sm"
            >
              {impactData.delta24h.votes >= 0 ? '+' : ''}
              {impactData.delta24h.votes}
            </AGAPill>
          </div>
          <h3 className="text-3xl font-black text-text-dark">
            {impactData.totalVotes.toLocaleString()}
          </h3>
          <p className="text-sm text-text-gray mt-1">Total Votes</p>
          <div className="mt-3 text-xs text-text-gray">
            +{impactData.delta7d.votes} in last 7 days
          </div>
        </AGACard>

        <AGACard variant="elevated" padding="lg">
          <div className="flex items-start justify-between mb-2">
            <div className="w-12 h-12 rounded-xl bg-secondary/10 flex items-center justify-center">
              <Users className="w-6 h-6 text-secondary" />
            </div>
            <AGAPill
              variant={impactData.delta24h.followers >= 0 ? 'success' : 'danger'}
              size="sm"
            >
              {impactData.delta24h.followers >= 0 ? '+' : ''}
              {impactData.delta24h.followers}
            </AGAPill>
          </div>
          <h3 className="text-3xl font-black text-text-dark">
            {impactData.totalFollowers.toLocaleString()}
          </h3>
          <p className="text-sm text-text-gray mt-1">Followers</p>
          <div className="mt-3 text-xs text-text-gray">
            +{impactData.delta7d.followers} in last 7 days
          </div>
        </AGACard>

        <AGACard variant="elevated" padding="lg">
          <div className="flex items-start justify-between mb-2">
            <div className="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center">
              <Award className="w-6 h-6 text-green-600" />
            </div>
            <AGAPill
              variant={impactData.rankChange <= 0 ? 'success' : 'danger'}
              size="sm"
            >
              {impactData.rankChange <= 0 ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
            </AGAPill>
          </div>
          <h3 className="text-3xl font-black text-text-dark">
            #{impactData.rank}
          </h3>
          <p className="text-sm text-text-gray mt-1">Current Rank</p>
          <div className="mt-3 text-xs text-text-gray">
            {impactData.rankChange < 0 ? `Up ${Math.abs(impactData.rankChange)}` : impactData.rankChange > 0 ? `Down ${impactData.rankChange}` : 'No change'} from last week
          </div>
        </AGACard>

        <AGACard variant="elevated" padding="lg">
          <div className="flex items-start justify-between mb-2">
            <div className="w-12 h-12 rounded-xl bg-blue-500/10 flex items-center justify-center">
              <Eye className="w-6 h-6 text-blue-600" />
            </div>
            <AGAPill variant="neutral" size="sm">
              24h
            </AGAPill>
          </div>
          <h3 className="text-3xl font-black text-text-dark">
            {impactData.profileViews.toLocaleString()}
          </h3>
          <p className="text-sm text-text-gray mt-1">Profile Views</p>
          <div className="mt-3 text-xs text-text-gray">
            +{impactData.delta24h.profileViews} today
          </div>
        </AGACard>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Votes Trend */}
        <AGACard variant="elevated" padding="lg">
          <h3 className="text-xl font-bold text-text-dark mb-4">
            Votes Trend (7 Days)
          </h3>
          <div className="relative h-64">
            <svg className="w-full h-full" viewBox="0 0 400 200">
              {/* Grid lines */}
              {[0, 1, 2, 3, 4].map((i) => (
                <line
                  key={i}
                  x1="0"
                  y1={i * 50}
                  x2="400"
                  y2={i * 50}
                  stroke="#e5e7eb"
                  strokeWidth="1"
                />
              ))}

              {/* Line chart */}
              <polyline
                points={impactData.votesChart
                  .map((v, i) => `${i * 66},${200 - (v / Math.max(...impactData.votesChart)) * 180}`)
                  .join(' ')}
                fill="none"
                stroke="#0a4d3c"
                strokeWidth="3"
                strokeLinecap="round"
                strokeLinejoin="round"
              />

              {/* Area fill */}
              <polygon
                points={`0,200 ${impactData.votesChart
                  .map((v, i) => `${i * 66},${200 - (v / Math.max(...impactData.votesChart)) * 180}`)
                  .join(' ')} 400,200`}
                fill="url(#gradient-votes)"
                opacity="0.2"
              />

              {/* Dots */}
              {impactData.votesChart.map((v, i) => (
                <circle
                  key={i}
                  cx={i * 66}
                  cy={200 - (v / Math.max(...impactData.votesChart)) * 180}
                  r="4"
                  fill="#0a4d3c"
                />
              ))}

              <defs>
                <linearGradient id="gradient-votes" x1="0%" y1="0%" x2="0%" y2="100%">
                  <stop offset="0%" stopColor="#0a4d3c" />
                  <stop offset="100%" stopColor="#0a4d3c" stopOpacity="0" />
                </linearGradient>
              </defs>
            </svg>
          </div>
          <div className="flex justify-between text-xs text-text-gray mt-2">
            <span>Mon</span>
            <span>Tue</span>
            <span>Wed</span>
            <span>Thu</span>
            <span>Fri</span>
            <span>Sat</span>
            <span>Sun</span>
          </div>
        </AGACard>

        {/* Followers Trend */}
        <AGACard variant="elevated" padding="lg">
          <h3 className="text-xl font-bold text-text-dark mb-4">
            Followers Growth (7 Days)
          </h3>
          <div className="relative h-64">
            <svg className="w-full h-full" viewBox="0 0 400 200">
              {/* Grid lines */}
              {[0, 1, 2, 3, 4].map((i) => (
                <line
                  key={i}
                  x1="0"
                  y1={i * 50}
                  x2="400"
                  y2={i * 50}
                  stroke="#e5e7eb"
                  strokeWidth="1"
                />
              ))}

              {/* Line chart */}
              <polyline
                points={impactData.followersChart
                  .map((v, i) => `${i * 66},${200 - ((v - Math.min(...impactData.followersChart)) / (Math.max(...impactData.followersChart) - Math.min(...impactData.followersChart))) * 180}`)
                  .join(' ')}
                fill="none"
                stroke="#f59e0b"
                strokeWidth="3"
                strokeLinecap="round"
                strokeLinejoin="round"
              />

              {/* Area fill */}
              <polygon
                points={`0,200 ${impactData.followersChart
                  .map((v, i) => `${i * 66},${200 - ((v - Math.min(...impactData.followersChart)) / (Math.max(...impactData.followersChart) - Math.min(...impactData.followersChart))) * 180}`)
                  .join(' ')} 400,200`}
                fill="url(#gradient-followers)"
                opacity="0.2"
              />

              {/* Dots */}
              {impactData.followersChart.map((v, i) => (
                <circle
                  key={i}
                  cx={i * 66}
                  cy={200 - ((v - Math.min(...impactData.followersChart)) / (Math.max(...impactData.followersChart) - Math.min(...impactData.followersChart))) * 180}
                  r="4"
                  fill="#f59e0b"
                />
              ))}

              <defs>
                <linearGradient id="gradient-followers" x1="0%" y1="0%" x2="0%" y2="100%">
                  <stop offset="0%" stopColor="#f59e0b" />
                  <stop offset="100%" stopColor="#f59e0b" stopOpacity="0" />
                </linearGradient>
              </defs>
            </svg>
          </div>
          <div className="flex justify-between text-xs text-text-gray mt-2">
            <span>Mon</span>
            <span>Tue</span>
            <span>Wed</span>
            <span>Thu</span>
            <span>Fri</span>
            <span>Sat</span>
            <span>Sun</span>
          </div>
        </AGACard>
      </div>

      {/* Peer Comparison */}
      <AGACard variant="elevated" padding="lg">
        <h3 className="text-xl font-bold text-text-dark mb-4">
          Peer Comparison
        </h3>
        <div className="space-y-4">
          {peerComparison.map((peer, index) => (
            <div
              key={index}
              className={`p-4 rounded-lg ${
                peer.name === 'You'
                  ? 'bg-primary/10 border-2 border-primary'
                  : 'bg-gray-50'
              }`}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className={`text-xl font-bold ${peer.name === 'You' ? 'text-primary' : 'text-text-gray'}`}>
                    #{peer.rank}
                  </div>
                  <div>
                    <p className={`font-semibold ${peer.name === 'You' ? 'text-primary' : 'text-text-dark'}`}>
                      {peer.name}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-6 text-sm">
                  <div>
                    <span className="text-text-gray">Votes: </span>
                    <span className="font-semibold text-text-dark">
                      {peer.votes.toLocaleString()}
                    </span>
                  </div>
                  <div>
                    <span className="text-text-gray">Followers: </span>
                    <span className="font-semibold text-text-dark">
                      {peer.followers.toLocaleString()}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </AGACard>

      {/* Insights & Recommendations */}
      <AGACard variant="hero" padding="lg">
        <h3 className="text-xl font-bold text-text-dark mb-4">
          📊 Insights & Recommendations
        </h3>
        <div className="space-y-3 text-sm">
          <div className="flex items-start gap-3 p-3 bg-white/50 rounded-lg">
            <TrendingUp className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
            <p className="text-text-gray">
              Your engagement is <strong className="text-green-600">up 23%</strong> this week. Keep posting regularly to maintain momentum!
            </p>
          </div>
          <div className="flex items-start gap-3 p-3 bg-white/50 rounded-lg">
            <Users className="w-5 h-5 text-blue-500 mt-0.5 flex-shrink-0" />
            <p className="text-text-gray">
              You're <strong className="text-text-dark">2 positions away</strong> from breaking into the Top 10. Focus on increasing follower engagement.
            </p>
          </div>
          <div className="flex items-start gap-3 p-3 bg-white/50 rounded-lg">
            <Target className="w-5 h-5 text-secondary mt-0.5 flex-shrink-0" />
            <p className="text-text-gray">
              Going live increases votes by <strong className="text-text-dark">3x on average</strong>. Schedule your next live stream!
            </p>
          </div>
        </div>
      </AGACard>
    </div>
  );
}
