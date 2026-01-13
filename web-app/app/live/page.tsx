'use client';

import { useState, useEffect } from 'react';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { AGACard, AGAButton, AGAPill } from '@/components/ui';
import { liveAPI, LiveStream } from '@/lib/api';
import { useAuth } from '@/lib/store/auth-store';
import { Radio, Users, Heart, Play, Loader2, Eye } from 'lucide-react';
import Link from 'next/link';

export default function LivePage() {
  const { user } = useAuth();
  const [liveStreams, setLiveStreams] = useState<LiveStream[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchLiveStreams = async () => {
      try {
        setLoading(true);
        const response = await liveAPI.getLiveStreams({ status: 'live', limit: 20 });
        if (response.success && response.data) {
          setLiveStreams(response.data);
        }
      } catch (err: any) {
        console.error('Failed to fetch live streams:', err);
        setError(err.message || 'Failed to load live streams');
      } finally {
        setLoading(false);
      }
    };

    fetchLiveStreams();
    const interval = setInterval(fetchLiveStreams, 30000); // Refresh every 30s
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <ProtectedRoute>
        <DashboardLayout>
          <div className="flex items-center justify-center min-h-[60vh]">
            <div className="text-center">
              <Loader2 className="w-12 h-12 text-primary animate-spin mx-auto mb-4" />
              <p className="text-text-gray">Loading live streams...</p>
            </div>
          </div>
        </DashboardLayout>
      </ProtectedRoute>
    );
  }

  return (
    <ProtectedRoute>
      <DashboardLayout>
        <div className="max-w-6xl mx-auto space-y-8">
          {/* Header */}
          <div>
            <div className="flex items-center gap-3 mb-2">
              <Radio className="w-8 h-8 text-red-500 animate-pulse" />
              <h1 className="text-4xl font-black text-text-dark">Live Now</h1>
            </div>
            <p className="text-lg text-text-gray">
              Watch live streams from Africa's brightest geniuses
            </p>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <AGACard variant="elevated" padding="lg">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-red-500/10 flex items-center justify-center">
                  <Radio className="w-6 h-6 text-red-500" />
                </div>
                <div>
                  <h3 className="text-3xl font-black text-text-dark">{liveStreams.length}</h3>
                  <p className="text-sm text-text-gray mt-1">Live Now</p>
                </div>
              </div>
            </AGACard>

            <AGACard variant="elevated" padding="lg">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                  <Eye className="w-6 h-6 text-primary" />
                </div>
                <div>
                  <h3 className="text-3xl font-black text-text-dark">
                    {liveStreams.reduce((sum, s) => sum + s.viewerCount, 0).toLocaleString()}
                  </h3>
                  <p className="text-sm text-text-gray mt-1">Total Viewers</p>
                </div>
              </div>
            </AGACard>

            <AGACard variant="elevated" padding="lg">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-secondary/10 flex items-center justify-center">
                  <Heart className="w-6 h-6 text-secondary" />
                </div>
                <div>
                  <h3 className="text-3xl font-black text-text-dark">
                    {liveStreams.reduce((sum, s) => sum + s.likesCount, 0).toLocaleString()}
                  </h3>
                  <p className="text-sm text-text-gray mt-1">Total Likes</p>
                </div>
              </div>
            </AGACard>
          </div>

          {/* Live Streams Grid */}
          {liveStreams.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {liveStreams.map((stream) => (
                <Link key={stream._id} href={`/live/${stream._id}`}>
                  <AGACard variant="elevated" padding="none" hoverable className="overflow-hidden">
                    {/* Thumbnail / Preview */}
                    <div className="relative bg-gradient-to-br from-gray-800 to-gray-900 h-40 flex items-center justify-center">
                      <Play className="w-16 h-16 text-white/50" />
                      <div className="absolute top-3 left-3">
                        <AGAPill variant="danger" size="sm" className="animate-pulse">
                          🔴 LIVE
                        </AGAPill>
                      </div>
                      <div className="absolute bottom-3 right-3 flex items-center gap-1.5 bg-black/60 px-2 py-1 rounded text-white text-sm">
                        <Users className="w-4 h-4" />
                        {stream.viewerCount.toLocaleString()}
                      </div>
                    </div>
                    
                    <div className="p-4">
                      <div className="flex items-start gap-3">
                        <div className="w-10 h-10 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold flex-shrink-0">
                          {stream.hostName?.[0]?.toUpperCase() || 'G'}
                        </div>
                        <div className="flex-1 min-w-0">
                          <h3 className="font-bold text-text-dark truncate">{stream.title}</h3>
                          <p className="text-sm text-text-gray">{stream.hostName}</p>
                          <p className="text-xs text-text-gray">{stream.hostPosition}</p>
                        </div>
                      </div>
                      
                      <div className="flex items-center gap-4 mt-3 pt-3 border-t border-gray-100">
                        <div className="flex items-center gap-1 text-sm text-text-gray">
                          <Heart className="w-4 h-4" />
                          {stream.likesCount}
                        </div>
                        <div className="flex items-center gap-1 text-sm text-text-gray">
                          <Eye className="w-4 h-4" />
                          {stream.totalViews} views
                        </div>
                      </div>
                    </div>
                  </AGACard>
                </Link>
              ))}
            </div>
          ) : (
            <AGACard variant="elevated" padding="lg">
              <div className="text-center py-12">
                <Radio className="w-20 h-20 text-gray-300 mx-auto mb-4" />
                <h3 className="text-xl font-bold text-text-dark mb-2">No Live Streams</h3>
                <p className="text-text-gray mb-4">There are no live streams at the moment. Check back later!</p>
                <Link href="/dashboard">
                  <AGAButton variant="primary">Back to Dashboard</AGAButton>
                </Link>
              </div>
            </AGACard>
          )}
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}

