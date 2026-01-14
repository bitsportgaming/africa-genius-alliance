import { useEffect, useRef, useState, useCallback } from 'react';
import { io, Socket } from 'socket.io-client';

interface WebRTCConfig {
  streamId: string;
  isHost: boolean;
  hostId?: string;
  viewerId?: string;
  onViewerJoined?: (viewerId: string) => void;
  onViewerLeft?: (viewerId: string) => void;
  onStreamEnded?: () => void;
}

export function useWebRTC(config: WebRTCConfig) {
  const { streamId, isHost, hostId, viewerId, onViewerJoined, onViewerLeft, onStreamEnded } = config;

  const [isConnected, setIsConnected] = useState(false);
  const [viewerCount, setViewerCount] = useState(0);
  const [error, setError] = useState<string | null>(null);

  const socketRef = useRef<Socket | null>(null);
  const peerConnectionsRef = useRef<Map<string, RTCPeerConnection>>(new Map());
  const localStreamRef = useRef<MediaStream | null>(null);

  // ICE servers for NAT traversal (using public STUN servers)
  const iceServers = {
    iceServers: [
      { urls: 'stun:stun.l.google.com:19302' },
      { urls: 'stun:stun1.l.google.com:19302' },
      { urls: 'stun:stun2.l.google.com:19302' },
    ],
  };

  // Initialize socket connection
  useEffect(() => {
    // Don't initialize if we don't have required IDs
    if (!streamId || (isHost && !hostId) || (!isHost && !viewerId)) {
      return;
    }

    const socket = io(process.env.NEXT_PUBLIC_API_URL || 'https://africageniusalliance.com', {
      transports: ['websocket', 'polling'],
    });

    socketRef.current = socket;

    socket.on('connect', () => {
      console.log('Socket connected:', socket.id);
      setIsConnected(true);

      if (isHost) {
        socket.emit('start-stream', { streamId, hostId });
      } else {
        socket.emit('join-stream', { streamId, viewerId });
      }
    });

    socket.on('disconnect', () => {
      console.log('Socket disconnected');
      setIsConnected(false);
    });

    socket.on('error', (data: { message: string }) => {
      console.error('Socket error:', data.message);
      setError(data.message);
    });

    return () => {
      socket.disconnect();
    };
  }, [streamId, isHost, hostId, viewerId]);

  // Create peer connection
  const createPeerConnection = useCallback(
    (targetSocketId: string): RTCPeerConnection => {
      const peerConnection = new RTCPeerConnection(iceServers);

      // Add local stream tracks to peer connection
      if (localStreamRef.current) {
        localStreamRef.current.getTracks().forEach((track) => {
          peerConnection.addTrack(track, localStreamRef.current!);
        });
      }

      // Handle ICE candidates
      peerConnection.onicecandidate = (event) => {
        if (event.candidate && socketRef.current) {
          socketRef.current.emit('ice-candidate', {
            targetSocketId,
            candidate: event.candidate,
          });
        }
      };

      // Handle connection state changes
      peerConnection.onconnectionstatechange = () => {
        console.log('Connection state:', peerConnection.connectionState);
        if (peerConnection.connectionState === 'failed') {
          setError('Connection failed. Please try again.');
        }
      };

      peerConnectionsRef.current.set(targetSocketId, peerConnection);
      return peerConnection;
    },
    []
  );

  // Host: Handle viewer joining
  useEffect(() => {
    if (!isHost || !socketRef.current) return;

    const socket = socketRef.current;

    socket.on('viewer-joined', async (data: { viewerId: string; viewerSocketId: string }) => {
      console.log('Viewer joined:', data.viewerId);
      setViewerCount((prev) => prev + 1);
      onViewerJoined?.(data.viewerId);

      try {
        const peerConnection = createPeerConnection(data.viewerSocketId);
        const offer = await peerConnection.createOffer();
        await peerConnection.setLocalDescription(offer);

        socket.emit('offer', {
          targetSocketId: data.viewerSocketId,
          sdp: offer,
        });
      } catch (error) {
        console.error('Error creating offer:', error);
        setError('Failed to connect to viewer');
      }
    });

    socket.on('answer', async (data: { sdp: RTCSessionDescriptionInit; viewerSocketId: string }) => {
      console.log('Received answer from viewer');
      const peerConnection = peerConnectionsRef.current.get(data.viewerSocketId);
      if (peerConnection) {
        await peerConnection.setRemoteDescription(new RTCSessionDescription(data.sdp));
      }
    });

    socket.on('viewer-left', (data: { viewerSocketId: string }) => {
      console.log('Viewer left');
      setViewerCount((prev) => Math.max(0, prev - 1));
      const peerConnection = peerConnectionsRef.current.get(data.viewerSocketId);
      if (peerConnection) {
        peerConnection.close();
        peerConnectionsRef.current.delete(data.viewerSocketId);
      }
      onViewerLeft?.(data.viewerSocketId);
    });

    return () => {
      socket.off('viewer-joined');
      socket.off('answer');
      socket.off('viewer-left');
    };
  }, [isHost, createPeerConnection, onViewerJoined, onViewerLeft]);

  // Viewer: Handle receiving stream from host
  useEffect(() => {
    if (isHost || !socketRef.current) return;

    const socket = socketRef.current;
    let peerConnection: RTCPeerConnection | null = null;

    socket.on('offer', async (data: { sdp: RTCSessionDescriptionInit; hostSocketId: string }) => {
      console.log('Received offer from host');

      try {
        peerConnection = createPeerConnection(data.hostSocketId);

        // Handle incoming tracks from host
        peerConnection.ontrack = (event) => {
          console.log('Received remote track:', event.track.kind);
        };

        await peerConnection.setRemoteDescription(new RTCSessionDescription(data.sdp));
        const answer = await peerConnection.createAnswer();
        await peerConnection.setLocalDescription(answer);

        socket.emit('answer', {
          targetSocketId: data.hostSocketId,
          sdp: answer,
        });
      } catch (error) {
        console.error('Error handling offer:', error);
        setError('Failed to connect to stream');
      }
    });

    socket.on('stream-ended', () => {
      console.log('Stream ended by host');
      onStreamEnded?.();
    });

    return () => {
      socket.off('offer');
      socket.off('stream-ended');
      if (peerConnection) {
        peerConnection.close();
      }
    };
  }, [isHost, createPeerConnection, onStreamEnded]);

  // Handle ICE candidates
  useEffect(() => {
    if (!socketRef.current) return;

    const socket = socketRef.current;

    socket.on('ice-candidate', (data: { candidate: RTCIceCandidateInit; fromSocketId: string }) => {
      const peerConnection = peerConnectionsRef.current.get(data.fromSocketId);
      if (peerConnection) {
        peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
      }
    });

    return () => {
      socket.off('ice-candidate');
    };
  }, []);

  // Start streaming (for host)
  const startStreaming = useCallback(async (stream: MediaStream) => {
    localStreamRef.current = stream;
  }, []);

  // Stop streaming (for host)
  const stopStreaming = useCallback(() => {
    if (localStreamRef.current) {
      localStreamRef.current.getTracks().forEach((track) => track.stop());
      localStreamRef.current = null;
    }

    // Close all peer connections
    peerConnectionsRef.current.forEach((pc) => pc.close());
    peerConnectionsRef.current.clear();

    // Notify server
    if (socketRef.current) {
      socketRef.current.emit('end-stream', { streamId });
    }

    setViewerCount(0);
  }, [streamId]);

  // Get remote stream (for viewer)
  const getRemoteStream = useCallback((hostSocketId: string): MediaStream | null => {
    const peerConnection = peerConnectionsRef.current.get(hostSocketId);
    if (!peerConnection) return null;

    const remoteStream = new MediaStream();
    peerConnection.getReceivers().forEach((receiver) => {
      if (receiver.track) {
        remoteStream.addTrack(receiver.track);
      }
    });

    return remoteStream;
  }, []);

  return {
    isConnected,
    viewerCount,
    error,
    startStreaming,
    stopStreaming,
    getRemoteStream,
  };
}
