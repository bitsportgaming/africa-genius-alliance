'use client';

import { useState, useEffect, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { AGACard, AGAButton } from '@/components/ui';
import { Heart, MessageCircle, Share2, ArrowLeft, Send, Loader2, Trash2 } from 'lucide-react';
import Link from 'next/link';
import { postsAPI, commentsAPI, apiClient } from '@/lib/api';
import { useAuth } from '@/lib/store/auth-store';
import type { Post, Comment } from '@/types';

export default function PostDetailPage() {
  const params = useParams();
  const router = useRouter();
  const { user } = useAuth();
  const postId = params?.id as string;

  const [post, setPost] = useState<Post | null>(null);
  const [comments, setComments] = useState<Comment[]>([]);
  const [loading, setLoading] = useState(true);
  const [newComment, setNewComment] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [isLiked, setIsLiked] = useState(false);

  // Fetch post and comments
  const fetchData = useCallback(async () => {
    if (!postId) return;
    try {
      const [postRes, commentsRes] = await Promise.all([
        postsAPI.getPost(postId),
        commentsAPI.getPostComments(postId),
      ]);
      if (postRes.success && postRes.data) {
        setPost(postRes.data);
        setIsLiked(postRes.data.likedBy?.includes(user?._id || '') || false);
      }
      if (commentsRes.success && commentsRes.data) {
        setComments(commentsRes.data);
      }
    } catch (err) {
      console.error('Failed to fetch post:', err);
    } finally {
      setLoading(false);
    }
  }, [postId, user?._id]);

  useEffect(() => {
    fetchData();
    // Poll for real-time updates
    const interval = setInterval(fetchData, 10000);
    return () => clearInterval(interval);
  }, [fetchData]);

  // Handle like
  const handleLike = async () => {
    if (!user?._id || !post) return;
    const wasLiked = isLiked;
    setIsLiked(!wasLiked);
    setPost(prev => prev ? {
      ...prev,
      likesCount: wasLiked ? prev.likesCount - 1 : prev.likesCount + 1,
      likedBy: wasLiked ? prev.likedBy.filter(id => id !== user._id) : [...prev.likedBy, user._id],
    } : null);

    try {
      await apiClient.post(`/posts/${postId}/like`, { userId: user._id });
    } catch (err) {
      // Revert on error
      setIsLiked(wasLiked);
      setPost(prev => prev ? {
        ...prev,
        likesCount: wasLiked ? prev.likesCount + 1 : prev.likesCount - 1,
        likedBy: wasLiked ? [...prev.likedBy, user._id] : prev.likedBy.filter(id => id !== user._id),
      } : null);
    }
  };

  // Handle comment submit
  const handleSubmitComment = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user?._id || !newComment.trim() || submitting) return;

    setSubmitting(true);
    try {
      const res = await commentsAPI.createComment({
        postId,
        content: newComment.trim(),
        authorId: user._id,
        authorName: user.displayName || 'Anonymous',
        authorAvatar: user.profileImageURL,
      });
      if (res.success && res.data) {
        setComments(prev => [res.data, ...prev]);
        setPost(prev => prev ? { ...prev, commentsCount: prev.commentsCount + 1 } : null);
        setNewComment('');
      }
    } catch (err) {
      console.error('Failed to post comment:', err);
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <ProtectedRoute>
        <DashboardLayout>
          <div className="flex items-center justify-center min-h-[60vh]">
            <Loader2 className="w-8 h-8 text-primary animate-spin" />
          </div>
        </DashboardLayout>
      </ProtectedRoute>
    );
  }

  if (!post) {
    return (
      <ProtectedRoute>
        <DashboardLayout>
          <div className="text-center py-12">
            <p className="text-text-gray mb-4">Post not found</p>
            <Link href="/dashboard">
              <AGAButton variant="primary">Go to Dashboard</AGAButton>
            </Link>
          </div>
        </DashboardLayout>
      </ProtectedRoute>
    );
  }

  return (
    <ProtectedRoute>
      <DashboardLayout>
        <div className="max-w-2xl mx-auto">
          {/* Back button */}
          <button onClick={() => router.back()} className="flex items-center gap-2 text-text-gray hover:text-primary mb-4 transition-colors">
            <ArrowLeft className="w-5 h-5" />
            <span>Back</span>
          </button>

          {/* Post */}
          <AGACard variant="elevated" padding="lg" className="mb-6">
            <div className="flex items-start gap-3 mb-4">
              <div className="w-12 h-12 rounded-full bg-gradient-accent flex items-center justify-center text-white font-semibold">
                {post.authorName?.[0]?.toUpperCase() || 'U'}
              </div>
              <div className="flex-1">
                <h3 className="font-semibold text-text-dark">{post.authorName}</h3>
                {post.authorPosition && <p className="text-sm text-text-gray">{post.authorPosition}</p>}
                <p className="text-xs text-text-gray">{new Date(post.createdAt).toLocaleString()}</p>
              </div>
            </div>

            <p className="text-text-dark mb-4 leading-relaxed">{post.content}</p>

            {/* Media */}
            {post.mediaURLs && post.mediaURLs.length > 0 && (
              <div className="mb-4 rounded-lg overflow-hidden">
                {post.mediaURLs.map((url, i) => (
                  <img key={i} src={`${process.env.NEXT_PUBLIC_API_URL || ''}${url}`} alt="" className="w-full" />
                ))}
              </div>
            )}

            {/* Actions */}
            <div className="flex items-center gap-6 pt-4 border-t border-gray-100">
              <button onClick={handleLike} className={`flex items-center gap-2 transition-colors ${isLiked ? 'text-red-500' : 'text-text-gray hover:text-red-500'}`}>
                <Heart className={`w-5 h-5 ${isLiked ? 'fill-current' : ''}`} />
                <span className="font-medium">{post.likesCount}</span>
              </button>
              <div className="flex items-center gap-2 text-text-gray">
                <MessageCircle className="w-5 h-5" />
                <span className="font-medium">{post.commentsCount}</span>
              </div>
            </div>
          </AGACard>

          {/* Comment Form */}
          <AGACard variant="elevated" padding="md" className="mb-6">
            <form onSubmit={handleSubmitComment} className="flex gap-3">
              <div className="w-10 h-10 rounded-full bg-gradient-accent flex items-center justify-center text-white font-semibold flex-shrink-0">
                {user?.displayName?.[0]?.toUpperCase() || 'U'}
              </div>
              <div className="flex-1 flex gap-2">
                <input
                  type="text"
                  value={newComment}
                  onChange={(e) => setNewComment(e.target.value)}
                  placeholder="Write a comment..."
                  className="flex-1 px-4 py-2 rounded-full border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none"
                />
                <button
                  type="submit"
                  disabled={!newComment.trim() || submitting}
                  className="w-10 h-10 rounded-full bg-primary text-white flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {submitting ? <Loader2 className="w-5 h-5 animate-spin" /> : <Send className="w-5 h-5" />}
                </button>
              </div>
            </form>
          </AGACard>

          {/* Comments List */}
          <div className="space-y-4">
            <h3 className="font-semibold text-text-dark">Comments ({comments.length})</h3>
            {comments.length === 0 ? (
              <p className="text-text-gray text-center py-8">No comments yet. Be the first to comment!</p>
            ) : (
              comments.map((comment) => (
                <AGACard key={comment._id} variant="default" padding="md">
                  <div className="flex items-start gap-3">
                    <div className="w-8 h-8 rounded-full bg-gradient-to-br from-gray-300 to-gray-400 flex items-center justify-center text-white text-sm font-semibold flex-shrink-0">
                      {comment.authorName?.[0]?.toUpperCase() || 'U'}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-semibold text-text-dark text-sm">{comment.authorName}</span>
                        <span className="text-xs text-text-gray">{new Date(comment.createdAt).toLocaleDateString()}</span>
                      </div>
                      <p className="text-text-dark text-sm">{comment.content}</p>
                    </div>
                  </div>
                </AGACard>
              ))
            )}
          </div>
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}

