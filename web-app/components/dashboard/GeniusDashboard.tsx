'use client';

import { useAuth } from '@/lib/store/auth-store';
import { AGACard, AGAButton, AGAPill } from '@/components/ui';
import Link from 'next/link';
import {
  TrendingUp,
  TrendingDown,
  Users,
  Award,
  Eye,
  FileText,
  Radio,
  BarChart3,
  Inbox,
  Megaphone,
  Settings,
  ArrowRight,
  Sparkles,
  Loader2
} from 'lucide-react';
import { useEffect, useState } from 'react';
import { apiClient } from '@/lib/api';

interface UserStats {
  profile: {
    userId: string;
    displayName: string;
    positionTitle: string;
    isVerified: boolean;
    rank: number;
    votesTotal: number;
    followersTotal: number;
    profileViews: number;
    stats24h: {
      votesDelta: number;
      followersDelta: number;
      rankDelta: number;
      profileViewsDelta: number;
    };
  };
  topGeniuses: Array<{
    id: string;
    name: string;
    positionTitle: string;
    rank: number;
    votes: number;
  }>;
}

export function GeniusDashboard() {
  const { user } = useAuth();
  const [stats, setStats] = useState<UserStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      if (!user?._id) return;

      try {
        setLoading(true);
        setError(null);
        const response: any = await apiClient.get(`/users/${user._id}/stats`);
        if (response.success && response.data) {
          setStats(response.data);
        }
      } catch (err: any) {
        console.error('Failed to fetch user stats:', err);
        setError(err.message || 'Failed to load dashboard data');
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
    // Refresh stats every 5 minutes
    const interval = setInterval(fetchStats, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, [user?._id]);

  const commandCenterActions = [
    {
      icon: FileText,
      title: 'Post Update',
      description: 'Share your latest ideas',
      href: '/create?tab=post',
      color: 'from-blue-500 to-blue-600',
    },
    {
      icon: Radio,
      title: 'Go Live',
      description: 'Connect with supporters',
      href: '/create?tab=live',
      color: 'from-red-500 to-red-600',
    },
    {
      icon: BarChart3,
      title: 'Analytics',
      description: 'View detailed insights',
      href: '/impact',
      color: 'from-green-500 to-green-600',
    },
    {
      icon: Inbox,
      title: 'Inbox',
      description: 'Messages & Notifications',
      href: '/inbox',
      color: 'from-purple-500 to-purple-600',
    },
    {
      icon: Megaphone,
      title: 'Campaign',
      description: 'Manage campaigns',
      href: '/campaigns',
      color: 'from-orange-500 to-orange-600',
    },
    {
      icon: Settings,
      title: 'Settings',
      description: 'Profile & preferences',
      href: '/profile',
      color: 'from-gray-500 to-gray-600',
    },
  ];

  // Generate alerts based on real stats
  const generateAlerts = () => {
    const alerts = [];
    if (stats?.profile.stats24h?.votesDelta || 0 > 0) {
      alerts.push({
        type: 'success' as const,
        message: `You gained ${stats!.profile.stats24h.votesDelta} new vote${stats!.profile.stats24h.votesDelta > 1 ? 's' : ''} today!`,
        time: 'Today',
      });
    }
    if (stats?.profile.stats24h?.followersDelta || 0 > 0) {
      alerts.push({
        type: 'success' as const,
        message: `${stats!.profile.stats24h.followersDelta} new follower${stats!.profile.stats24h.followersDelta > 1 ? 's' : ''}!`,
        time: 'Today',
      });
    }
    if ((stats?.profile.stats24h?.rankDelta ?? 0) < 0) {
      alerts.push({
        type: 'info' as const,
        message: `Your rank improved by ${Math.abs(stats!.profile.stats24h.rankDelta)} position${Math.abs(stats!.profile.stats24h.rankDelta) > 1 ? 's' : ''}`,
        time: 'Today',
      });
    }
    if ((stats?.profile.stats24h?.rankDelta ?? 0) > 0) {
      alerts.push({
        type: 'warning' as const,
        message: `Your rank decreased by ${stats!.profile.stats24h.rankDelta} position${stats!.profile.stats24h.rankDelta > 1 ? 's' : ''}. Stay active!`,
        time: 'Today',
      });
    }
    if (!user?.bio || user.bio.length < 50) {
      alerts.push({
        type: 'warning' as const,
        message: 'Complete your profile bio to increase visibility',
        time: 'Suggestion',
      });
    }
    if (alerts.length === 0) {
      alerts.push({
        type: 'info' as const,
        message: 'Keep engaging with your supporters to grow your impact!',
        time: 'Tip',
      });
    }
    return alerts;
  };

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

  const impactStats = {
    totalVotes: stats?.profile.votesTotal || 0,
    delta24h: {
      votes: stats?.profile.stats24h?.votesDelta || 0 || 0,
      followers: stats?.profile.stats24h?.followersDelta || 0 || 0,
      rank: (stats?.profile.stats24h?.rankDelta ?? 0) || 0,
      profileViews: stats?.profile.stats24h.profileViewsDelta || 0,
    },
    followers: stats?.profile.followersTotal || 0,
    rank: stats?.profile.rank || 0,
    profileViews24h: stats?.profile.stats24h.profileViewsDelta || 0,
  };

  const alerts = generateAlerts();
  const topGeniuses = stats?.topGeniuses || [];

  return (
    <div className="space-y-8">
      {/* Welcome Section */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-4xl font-black text-text-dark mb-2">
            Welcome back, {user?.displayName}!
          </h1>
          <p className="text-lg text-text-gray">
            Track your impact and manage your leadership journey
          </p>
        </div>
        <AGAPill variant="secondary" size="lg">
          <Sparkles className="w-4 h-4 mr-1" />
          Genius
        </AGAPill>
      </div>

      {/* Impact Snapshot */}
      <section>
        <h2 className="text-2xl font-bold text-text-dark mb-4">Impact Snapshot</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Total Votes */}
          <AGACard variant="elevated" padding="lg">
            <div className="flex items-start justify-between mb-2">
              <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                <TrendingUp className="w-6 h-6 text-primary" />
              </div>
              <AGAPill
                variant={impactStats.delta24h.votes >= 0 ? 'success' : 'danger'}
                size="sm"
              >
                {impactStats.delta24h.votes >= 0 ? '+' : ''}
                {impactStats.delta24h.votes}
              </AGAPill>
            </div>
            <h3 className="text-3xl font-black text-text-dark">
              {impactStats.totalVotes.toLocaleString()}
            </h3>
            <p className="text-sm text-text-gray mt-1">Total Votes</p>
          </AGACard>

          {/* Followers */}
          <AGACard variant="elevated" padding="lg">
            <div className="flex items-start justify-between mb-2">
              <div className="w-12 h-12 rounded-xl bg-secondary/10 flex items-center justify-center">
                <Users className="w-6 h-6 text-secondary" />
              </div>
              <AGAPill
                variant={impactStats.delta24h.followers >= 0 ? 'success' : 'danger'}
                size="sm"
              >
                {impactStats.delta24h.followers >= 0 ? '+' : ''}
                {impactStats.delta24h.followers}
              </AGAPill>
            </div>
            <h3 className="text-3xl font-black text-text-dark">
              {impactStats.followers.toLocaleString()}
            </h3>
            <p className="text-sm text-text-gray mt-1">Followers</p>
          </AGACard>

          {/* Rank */}
          <AGACard variant="elevated" padding="lg">
            <div className="flex items-start justify-between mb-2">
              <div className="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center">
                <Award className="w-6 h-6 text-green-600" />
              </div>
              <AGAPill
                variant={impactStats.delta24h.rank <= 0 ? 'success' : 'danger'}
                size="sm"
              >
                {impactStats.delta24h.rank <= 0 ? (
                  <TrendingUp className="w-3 h-3" />
                ) : (
                  <TrendingDown className="w-3 h-3" />
                )}
                {Math.abs(impactStats.delta24h.rank)}
              </AGAPill>
            </div>
            <h3 className="text-3xl font-black text-text-dark">
              #{impactStats.rank}
            </h3>
            <p className="text-sm text-text-gray mt-1">Current Rank</p>
          </AGACard>

          {/* Profile Views */}
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
              {impactStats.profileViews24h.toLocaleString()}
            </h3>
            <p className="text-sm text-text-gray mt-1">Profile Views</p>
          </AGACard>
        </div>
      </section>

      {/* Command Center */}
      <section>
        <h2 className="text-2xl font-bold text-text-dark mb-4">Command Center</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {commandCenterActions.map((action, index) => {
            const Icon = action.icon;
            return (
              <Link key={index} href={action.href}>
                <AGACard
                  variant="elevated"
                  padding="lg"
                  hoverable
                  className="group relative overflow-hidden"
                >
                  <div
                    className={`absolute top-0 right-0 w-24 h-24 bg-gradient-to-br ${action.color} rounded-full blur-3xl opacity-20 group-hover:opacity-30 transition-opacity -mr-12 -mt-12`}
                  />
                  <div className="relative">
                    <div className="flex items-start justify-between mb-4">
                      <div
                        className={`w-14 h-14 rounded-xl bg-gradient-to-br ${action.color} flex items-center justify-center group-hover:scale-110 transition-transform`}
                      >
                        <Icon className="w-7 h-7 text-white" />
                      </div>
                    </div>
                    <h3 className="text-xl font-bold text-text-dark mb-1">
                      {action.title}
                    </h3>
                    <p className="text-sm text-text-gray">
                      {action.description}
                    </p>
                  </div>
                </AGACard>
              </Link>
            );
          })}
        </div>
      </section>

      {/* Alerts & Opportunities */}
      {alerts.length > 0 && (
        <section>
          <h2 className="text-2xl font-bold text-text-dark mb-4">
            Alerts & Opportunities
          </h2>
          <AGACard variant="elevated" padding="lg">
            <div className="space-y-4">
              {alerts.map((alert, index) => (
                <div
                  key={index}
                  className={`flex items-start gap-4 p-4 rounded-lg border ${
                    alert.type === 'success'
                      ? 'bg-green-50 border-green-200'
                      : alert.type === 'warning'
                      ? 'bg-yellow-50 border-yellow-200'
                      : 'bg-blue-50 border-blue-200'
                  }`}
                >
                  <div
                    className={`w-2 h-2 rounded-full mt-2 ${
                      alert.type === 'success'
                        ? 'bg-green-500'
                        : alert.type === 'warning'
                        ? 'bg-yellow-500'
                        : 'bg-blue-500'
                    }`}
                  />
                  <div className="flex-1">
                    <p className="text-sm font-medium text-text-dark">
                      {alert.message}
                    </p>
                    <p className="text-xs text-text-gray mt-1">{alert.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </AGACard>
        </section>
      )}

      {/* Leaderboard Preview */}
      {topGeniuses.length > 0 && (
        <section>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-2xl font-bold text-text-dark">
              Leaderboard Preview
            </h2>
            <Link href="/impact">
              <AGAButton variant="ghost" size="sm" rightIcon={<ArrowRight className="w-4 h-4" />}>
                View Full Leaderboard
              </AGAButton>
            </Link>
          </div>
          <AGACard variant="elevated" padding="lg">
            <div className="space-y-3">
              {topGeniuses.map((genius) => (
                <div
                  key={genius.rank}
                  className="flex items-center justify-between p-3 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <div
                      className={`w-10 h-10 rounded-full flex items-center justify-center font-bold ${
                        genius.rank <= 3
                          ? 'bg-gradient-accent text-white'
                          : 'bg-gray-100 text-gray-600'
                      }`}
                    >
                      {genius.rank}
                    </div>
                    <div>
                      <p className="font-semibold text-text-dark">
                        {genius.name}
                      </p>
                      <p className="text-sm text-text-gray">
                        {genius.votes.toLocaleString()} votes
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </AGACard>
        </section>
      )}
    </div>
  );
}
