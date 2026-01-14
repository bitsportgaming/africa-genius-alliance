'use client';

import { useState, useEffect, useRef } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { AGACard, AGAButton, AGAPill } from '@/components/ui';
import { liveAPI, LiveStream } from '@/lib/api';
import { useAuth } from '@/lib/store/auth-store';
import { useWebRTC } from '@/lib/webrtc/useWebRTC';
import { Radio, Users, Heart, ArrowLeft, Loader2, Share2, MessageCircle, Wifi } from 'lucide-react';
import Link from 'next/link';

export default function LiveStreamViewerPage() {
  const params = useParams();
  const router = useRouter();
  const { user } = useAuth();
  const streamId = params.id as string;

  const [stream, setStream] = useState<LiveStream | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isLiked, setIsLiked] = useState(false);
  const [hasJoined, setHasJoined] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);
  const [remoteStream, setRemoteStream] = useState<MediaStream | null>(null);

  // WebRTC hook for viewer
  const webrtc = useWebRTC({
    streamId: streamId || '',
    isHost: false,
    hostId: stream?.hostId,
    viewerId: user?._id || '',
    onStreamEnded: () => {
      setError('Stream has ended');
      router.push('/live');
    },
  });

  // Handle remote stream from WebRTC
  useEffect(() => {
    if (!stream?.hostId || !webrtc.isConnected) return;

    // Get remote stream from the host's socket ID
    // We need to get this from the peer connection
    const checkForStream = setInterval(() => {
      const remoteMediaStream = webrtc.getRemoteStream(stream.hostId);
      if (remoteMediaStream && remoteMediaStream.getTracks().length > 0) {
        setRemoteStream(remoteMediaStream);
        if (videoRef.current) {
          videoRef.current.srcObject = remoteMediaStream;
        }
        clearInterval(checkForStream);
      }
    }, 500);

    return () => clearInterval(checkForStream);
  }, [stream?.hostId, webrtc, webrtc.isConnected]);

  useEffect(() => {
    const fetchStream = async () => {
      if (!streamId) return;
      try {
        setLoading(true);
        const response = await liveAPI.getLiveStream(streamId);
        if (response.success && response.data) {
          setStream(response.data);
          setIsLiked(response.data.likedBy?.includes(user?._id || '') || false);
        } else {
          setError('Stream not found');
        }
      } catch (err: any) {
        console.error('Failed to fetch stream:', err);
        setError(err.message || 'Failed to load stream');
      } finally {
        setLoading(false);
      }
    };

    fetchStream();
    const interval = setInterval(fetchStream, 5000); // Refresh every 5s
    return () => clearInterval(interval);
  }, [streamId, user?._id]);

  useEffect(() => {
    // Join stream on mount
    const joinStream = async () => {
      if (!streamId || !user?._id || hasJoined) return;
      try {
        await liveAPI.joinStream(streamId, user._id);
        setHasJoined(true);
      } catch (err) {
        console.error('Failed to join stream:', err);
      }
    };

    if (stream && !hasJoined) {
      joinStream();
    }

    // Leave stream on unmount
    return () => {
      if (streamId && user?._id && hasJoined) {
        liveAPI.leaveStream(streamId, user._id).catch(console.error);
      }
    };
  }, [streamId, user?._id, stream, hasJoined]);

  const handleLike = async () => {
    if (!streamId || !user?._id) return;
    try {
      const response = await liveAPI.likeStream(streamId, user._id);
      if (response.success) {
        setIsLiked(response.data?.liked || !isLiked);
        if (stream) {
          setStream({
            ...stream,
            likesCount: isLiked ? stream.likesCount - 1 : stream.likesCount + 1,
          });
        }
      }
    } catch (err) {
      console.error('Failed to like stream:', err);
    }
  };

  if (loading) {
    return (
      <ProtectedRoute>
        <DashboardLayout>
          <div className="flex items-center justify-center min-h-[60vh]">
            <div className="text-center">
              <Loader2 className="w-12 h-12 text-primary animate-spin mx-auto mb-4" />
              <p className="text-text-gray">Loading stream...</p>
            </div>
          </div>
        </DashboardLayout>
      </ProtectedRoute>
    );
  }

  if (error || !stream) {
    return (
      <ProtectedRoute>
        <DashboardLayout>
          <div className="max-w-2xl mx-auto mt-12">
            <AGACard variant="elevated" padding="lg">
              <div className="text-center py-8">
                <Radio className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                <h2 className="text-xl font-bold text-text-dark mb-2">Stream Not Found</h2>
                <p className="text-text-gray mb-4">{error || 'This stream may have ended or doesn\'t exist.'}</p>
                <Link href="/live">
                  <AGAButton variant="primary">Browse Live Streams</AGAButton>
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
        <div className="max-w-5xl mx-auto space-y-6">
          {/* Back Button */}
          <button onClick={() => router.back()} className="flex items-center gap-2 text-text-gray hover:text-text-dark transition-colors">
            <ArrowLeft className="w-5 h-5" />
            <span>Back</span>
          </button>

          {/* Video Player Area */}
          <div className="relative bg-gradient-to-br from-gray-900 to-black rounded-2xl overflow-hidden aspect-video">
            {remoteStream ? (
              <video
                ref={videoRef}
                autoPlay
                playsInline
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <div className="text-center text-white">
                  {webrtc.isConnected ? (
                    <>
                      <Loader2 className="w-20 h-20 mx-auto mb-4 animate-spin text-primary" />
                      <p className="text-xl font-bold">Connecting to stream...</p>
                      <p className="text-gray-400 mt-2">Please wait while we connect you to the live stream</p>
                    </>
                  ) : (
                    <>
                      <Wifi className="w-20 h-20 mx-auto mb-4 text-gray-600" />
                      <p className="text-xl font-bold">Establishing connection...</p>
                      <p className="text-gray-400 mt-2">Connecting to signaling server</p>
                    </>
                  )}
                </div>
              </div>
            )}

            {/* Live Badge */}
            <div className="absolute top-4 left-4">
              <AGAPill variant="danger" size="md" className="animate-pulse">
                🔴 LIVE
              </AGAPill>
            </div>

            {/* Viewer Count */}
            <div className="absolute top-4 right-4 flex items-center gap-2 bg-black/60 px-3 py-2 rounded-lg text-white">
              <Users className="w-5 h-5" />
              <span className="font-semibold">{stream.viewerCount.toLocaleString()} watching</span>
            </div>

            {/* Connection Status Indicator */}
            {remoteStream && (
              <div className="absolute bottom-4 right-4 flex items-center gap-2 bg-green-600/80 px-3 py-2 rounded-lg text-white text-sm">
                <Wifi className="w-4 h-4" />
                <span>Connected</span>
              </div>
            )}
          </div>

          {/* Stream Info */}
          <AGACard variant="elevated" padding="lg">
            <div className="flex items-start justify-between gap-4">
              <div className="flex items-start gap-4">
                <div className="w-14 h-14 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-xl">
                  {stream.hostName?.[0]?.toUpperCase() || 'G'}
                </div>
                <div>
                  <h1 className="text-2xl font-black text-text-dark">{stream.title}</h1>
                  <p className="text-text-gray mt-1">{stream.hostName}</p>
                  <p className="text-sm text-text-gray">{stream.hostPosition}</p>
                </div>
              </div>
              
              <div className="flex items-center gap-3">
                <AGAButton variant={isLiked ? 'primary' : 'outline'} onClick={handleLike} leftIcon={<Heart className={`w-5 h-5 ${isLiked ? 'fill-current' : ''}`} />}>
                  {stream.likesCount}
                </AGAButton>
                <AGAButton variant="outline" leftIcon={<Share2 className="w-5 h-5" />}>Share</AGAButton>
              </div>
            </div>

            {stream.description && (
              <p className="mt-4 text-text-gray">{stream.description}</p>
            )}
          </AGACard>
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}

