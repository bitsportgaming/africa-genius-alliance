'use client';

import { useState, useRef, useEffect } from 'react';
import { AGAButton, AGAPill } from '@/components/ui';
import { Radio, Video, VideoOff, Wifi, AlertCircle, Users as UsersIcon } from 'lucide-react';
import { useAuth } from '@/lib/store/auth-store';
import { useWebRTC } from '@/lib/webrtc/useWebRTC';
import { liveAPI } from '@/lib/api';

export function GoLiveTab() {
  const { user } = useAuth();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [cameraEnabled, setCameraEnabled] = useState(false);
  const [isLive, setIsLive] = useState(false);
  const [streamId, setStreamId] = useState<string | null>(null);
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [duration, setDuration] = useState(0);
  const videoRef = useRef<HTMLVideoElement>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const durationIntervalRef = useRef<NodeJS.Timeout | null>(null);

  // WebRTC hook
  const webrtc = useWebRTC({
    streamId: streamId || '',
    isHost: true,
    hostId: user?._id || '',
    onViewerJoined: (viewerId) => {
      console.log('Viewer joined:', viewerId);
    },
    onViewerLeft: (viewerId) => {
      console.log('Viewer left:', viewerId);
    },
  });

  // Enable/disable camera
  const toggleCamera = async () => {
    if (cameraEnabled) {
      // Disable camera
      if (streamRef.current) {
        streamRef.current.getTracks().forEach(track => track.stop());
        streamRef.current = null;
      }
      if (videoRef.current) {
        videoRef.current.srcObject = null;
      }
      setCameraEnabled(false);
      setCameraError(null);
    } else {
      // Enable camera
      try {
        setCameraError(null);
        const stream = await navigator.mediaDevices.getUserMedia({
          video: { width: 1280, height: 720 },
          audio: true
        });

        streamRef.current = stream;
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
        }
        setCameraEnabled(true);
      } catch (error: any) {
        console.error('Error accessing camera:', error);
        if (error.name === 'NotAllowedError') {
          setCameraError('Camera access denied. Please allow camera access in your browser settings.');
        } else if (error.name === 'NotFoundError') {
          setCameraError('No camera found. Please connect a camera and try again.');
        } else {
          setCameraError('Failed to access camera. Please check your device settings.');
        }
      }
    }
  };

  // Auto-enable camera on mount
  useEffect(() => {
    const enableCamera = async () => {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: { width: 1280, height: 720 },
          audio: true
        });

        streamRef.current = stream;
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
        }
        setCameraEnabled(true);
      } catch (error: any) {
        console.error('Error accessing camera:', error);
        if (error.name === 'NotAllowedError') {
          setCameraError('Camera access denied. Please allow camera access in your browser settings.');
        } else if (error.name === 'NotFoundError') {
          setCameraError('No camera found. Please connect a camera and try again.');
        } else {
          setCameraError('Failed to access camera. Please check your device settings.');
        }
      }
    };

    enableCamera();

    return () => {
      if (streamRef.current) {
        streamRef.current.getTracks().forEach(track => track.stop());
      }
    };
  }, []);

  const handleStartLive = async () => {
    if (!streamRef.current || !user?._id) return;

    try {
      // Create live stream in database
      const response = await liveAPI.startStream({
        title,
        description,
        hostId: user._id,
        hostName: user.displayName || user.email?.split('@')[0] || 'Unknown',
        hostAvatar: user.profileImageURL,
        hostPosition: user.geniusPosition,
      });

      if (response.success && response.data) {
        const newStreamId = response.data._id;
        setStreamId(newStreamId);
        setIsLive(true);

        // Start WebRTC streaming
        await webrtc.startStreaming(streamRef.current);

        // Start duration counter
        durationIntervalRef.current = setInterval(() => {
          setDuration((prev) => prev + 1);
        }, 1000);
      } else {
        setCameraError('Failed to start live stream. Please try again.');
      }
    } catch (error) {
      console.error('Error starting live stream:', error);
      setCameraError('Failed to start live stream. Please try again.');
    }
  };

  const handleStopLive = async () => {
    // Stop duration counter
    if (durationIntervalRef.current) {
      clearInterval(durationIntervalRef.current);
      durationIntervalRef.current = null;
    }

    // Stop WebRTC streaming
    webrtc.stopStreaming();

    // End stream in database
    if (streamId) {
      try {
        await liveAPI.stopStream(streamId);
      } catch (error) {
        console.error('Error ending stream:', error);
      }
    }

    // Clean up local stream
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop());
      streamRef.current = null;
    }
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }

    // Reset state
    setIsLive(false);
    setCameraEnabled(false);
    setStreamId(null);
    setDuration(0);
    setTitle('');
    setDescription('');
  };

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (durationIntervalRef.current) {
        clearInterval(durationIntervalRef.current);
      }
      if (isLive) {
        handleStopLive();
      }
    };
  }, [isLive]);

  return (
    <div className="space-y-6">
      {/* Info Banner */}
      <div className="p-4 bg-blue-50 border border-blue-200 rounded-aga flex items-start gap-3">
        <AlertCircle className="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0" />
        <div>
          <h3 className="font-semibold text-blue-900 mb-1">
            Live Streaming Setup
          </h3>
          <p className="text-sm text-blue-700">
            Connect with your supporters in real-time. Live streams appear at the top of their feeds and send notifications to all followers.
          </p>
        </div>
      </div>

      {!isLive ? (
        <>
          {/* Stream Title */}
          <div>
            <label className="block text-sm font-semibold text-text-dark mb-2">
              Stream Title *
            </label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g., Town Hall Q&A Session"
              className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
            />
          </div>

          {/* Stream Description */}
          <div>
            <label className="block text-sm font-semibold text-text-dark mb-2">
              Description (Optional)
            </label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="What will you discuss during this live stream?"
              rows={3}
              className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none resize-none transition-all"
            />
          </div>

          {/* Camera Preview */}
          <div>
            <label className="block text-sm font-semibold text-text-dark mb-3">
              Camera Preview
            </label>
            <div className="relative bg-gray-900 rounded-aga overflow-hidden aspect-video">
              {cameraEnabled ? (
                <video
                  ref={videoRef}
                  autoPlay
                  playsInline
                  muted
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center">
                  <div className="text-center">
                    <VideoOff className="w-16 h-16 text-gray-600 mx-auto mb-3" />
                    <p className="text-gray-400 text-sm">
                      Camera is disabled
                    </p>
                  </div>
                </div>
              )}

              {/* Live Badge (when testing) */}
              {cameraEnabled && (
                <div className="absolute top-4 left-4">
                  <AGAPill variant="danger" size="sm">
                    <Radio className="w-3 h-3 mr-1" />
                    PREVIEW
                  </AGAPill>
                </div>
              )}
            </div>

            {/* Error Message */}
            {cameraError && (
              <div className="mt-3 p-3 bg-red-50 border border-red-200 rounded-lg">
                <p className="text-sm text-red-700">{cameraError}</p>
              </div>
            )}

            <div className="mt-3 flex gap-2">
              <AGAButton
                variant={cameraEnabled ? 'danger' : 'secondary'}
                size="sm"
                onClick={toggleCamera}
                leftIcon={cameraEnabled ? <VideoOff className="w-4 h-4" /> : <Video className="w-4 h-4" />}
              >
                {cameraEnabled ? 'Disable Camera' : 'Enable Camera'}
              </AGAButton>
            </div>
          </div>

          {/* Stream Settings */}
          <div className="grid grid-cols-2 gap-4">
            <div className="p-4 border border-gray-200 rounded-aga">
              <h4 className="font-semibold text-text-dark mb-2">Resolution</h4>
              <select className="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20">
                <option>720p (Recommended)</option>
                <option>1080p (High Quality)</option>
                <option>480p (Low Bandwidth)</option>
              </select>
            </div>

            <div className="p-4 border border-gray-200 rounded-aga">
              <h4 className="font-semibold text-text-dark mb-2">Notifications</h4>
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  defaultChecked
                  className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
                />
                <span className="text-sm text-text-gray">
                  Notify all followers
                </span>
              </label>
            </div>
          </div>

          {/* Go Live Button */}
          <div className="flex items-center justify-between pt-4 border-t border-gray-200">
            <div className="text-sm text-text-gray">
              {user?.followersCount || 0} followers will be notified
            </div>
            <AGAButton
              variant="secondary"
              size="lg"
              onClick={handleStartLive}
              disabled={!title.trim() || !cameraEnabled}
              leftIcon={<Radio className="w-5 h-5" />}
            >
              Go Live
            </AGAButton>
          </div>
        </>
      ) : (
        <>
          {/* Live Stream Active */}
          <div className="text-center py-8">
            <div className="relative inline-block mb-6">
              <div className="w-24 h-24 rounded-full bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center animate-pulse">
                <Radio className="w-12 h-12 text-white" />
              </div>
              <div className="absolute -top-2 -right-2">
                <AGAPill variant="danger" size="lg">
                  LIVE
                </AGAPill>
              </div>
            </div>

            <h3 className="text-2xl font-black text-text-dark mb-2">
              You're Live!
            </h3>
            <p className="text-text-gray mb-6">
              Broadcasting: {title}
            </p>

            {/* Live Stats */}
            <div className="flex items-center justify-center gap-8 mb-8">
              <div>
                <div className="flex items-center justify-center gap-2 mb-1">
                  <UsersIcon className="w-5 h-5 text-primary" />
                  <div className="text-3xl font-black text-text-dark">{webrtc.viewerCount}</div>
                </div>
                <div className="text-sm text-text-gray">Viewers</div>
              </div>
              <div>
                <div className="text-3xl font-black text-text-dark">
                  {Math.floor(duration / 60)}:{(duration % 60).toString().padStart(2, '0')}
                </div>
                <div className="text-sm text-text-gray">Duration</div>
              </div>
              {webrtc.isConnected && (
                <div>
                  <div className="flex items-center justify-center gap-2 mb-1">
                    <Wifi className="w-5 h-5 text-green-500" />
                  </div>
                  <div className="text-sm text-text-gray">Connected</div>
                </div>
              )}
            </div>

            <AGAButton
              variant="danger"
              size="lg"
              onClick={handleStopLive}
            >
              End Stream
            </AGAButton>
          </div>
        </>
      )}

      {/* Tips */}
      {!isLive && (
        <div className="p-4 bg-gray-50 rounded-aga">
          <h4 className="font-semibold text-text-dark mb-2">
            💡 Live Streaming Tips
          </h4>
          <ul className="space-y-1 text-sm text-text-gray">
            <li>• Test your camera and microphone before going live</li>
            <li>• Choose a well-lit location with minimal background noise</li>
            <li>• Prepare talking points to keep the conversation flowing</li>
            <li>• Engage with viewers by responding to comments</li>
            <li>• Announce your live session in advance for better turnout</li>
          </ul>
        </div>
      )}
    </div>
  );
}
