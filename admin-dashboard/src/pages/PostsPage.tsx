import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { postsAPI, Post } from '../services/api';
import { Search, Star, Flag, Trash2, Eye, EyeOff, Plus, X, Send, Shield } from 'lucide-react';
import { format } from 'date-fns';

export default function PostsPage() {
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [page, setPage] = useState(1);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newPostContent, setNewPostContent] = useState('');
  const [isCreating, setIsCreating] = useState(false);
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['adminPosts', page, search, statusFilter],
    queryFn: () => postsAPI.getAll({ page, limit: 20, search, status: statusFilter }),
  });

  const updateMutation = useMutation({
    mutationFn: ({ postId, data }: { postId: string; data: any }) =>
      postsAPI.update(postId, data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['adminPosts'] }),
  });

  const deleteMutation = useMutation({
    mutationFn: (postId: string) => postsAPI.delete(postId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['adminPosts'] }),
  });

  const createMutation = useMutation({
    mutationFn: (content: string) => postsAPI.create({ content }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminPosts'] });
      setShowCreateModal(false);
      setNewPostContent('');
      setIsCreating(false);
    },
    onError: () => setIsCreating(false),
  });

  const posts = data?.data?.data || [];
  const pagination = data?.data?.pagination;

  const handleToggleFeature = (post: Post) => {
    const postId = post.postId || post._id;
    updateMutation.mutate({ postId, data: { isFeatured: !post.isFeatured } });
  };

  const handleToggleVisibility = (post: Post) => {
    const postId = post.postId || post._id;
    const newStatus = post.status === 'active' ? 'hidden' : 'active';
    updateMutation.mutate({ postId, data: { status: newStatus } });
  };

  const handleDelete = (post: Post) => {
    if (confirm('Are you sure you want to delete this post?')) {
      const postId = post.postId || post._id;
      deleteMutation.mutate(postId);
    }
  };

  const handleCreatePost = () => {
    if (newPostContent.trim() && !isCreating) {
      setIsCreating(true);
      createMutation.mutate(newPostContent.trim());
    }
  };

  return (
    <div className="space-y-6">
      {/* Create Post Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-slate-800 rounded-xl w-full max-w-lg shadow-2xl">
            <div className="flex items-center justify-between p-4 border-b border-slate-700">
              <div className="flex items-center gap-2">
                <Shield className="text-yellow-400" size={20} />
                <h2 className="text-lg font-bold text-white">Create Admin Announcement</h2>
              </div>
              <button
                onClick={() => setShowCreateModal(false)}
                className="p-1 hover:bg-slate-700 rounded-lg transition-colors"
              >
                <X className="text-slate-400" size={20} />
              </button>
            </div>
            <div className="p-4">
              <p className="text-sm text-yellow-400/80 mb-3 flex items-center gap-2">
                <span className="text-lg">✦</span>
                This post will appear with a gold checkmark on all users' feeds
              </p>
              <textarea
                value={newPostContent}
                onChange={(e) => setNewPostContent(e.target.value)}
                placeholder="Write your announcement to all AGA users..."
                className="w-full h-32 bg-slate-900 border border-slate-600 rounded-lg p-3 text-white placeholder-slate-500 focus:border-yellow-400 focus:ring-1 focus:ring-yellow-400 resize-none"
                maxLength={500}
              />
              <div className="flex items-center justify-between mt-3">
                <span className="text-sm text-slate-500">{newPostContent.length}/500</span>
                <div className="flex gap-2">
                  <button
                    onClick={() => setShowCreateModal(false)}
                    className="px-4 py-2 bg-slate-700 text-slate-300 rounded-lg hover:bg-slate-600 transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleCreatePost}
                    disabled={!newPostContent.trim() || isCreating}
                    className="px-4 py-2 bg-gradient-to-r from-yellow-500 to-yellow-600 text-black font-medium rounded-lg hover:from-yellow-400 hover:to-yellow-500 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                  >
                    <Send size={16} />
                    {isCreating ? 'Posting...' : 'Post Announcement'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Posts</h1>
          <p className="text-slate-400">Moderate and manage content</p>
        </div>
        <button
          onClick={() => setShowCreateModal(true)}
          className="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-yellow-500 to-yellow-600 text-black font-medium rounded-lg hover:from-yellow-400 hover:to-yellow-500 transition-colors"
        >
          <Plus size={18} />
          Create Admin Post
        </button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-4">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" size={18} />
          <input
            type="text"
            placeholder="Search posts..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10"
          />
        </div>
        <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="min-w-[150px]">
          <option value="">All Posts</option>
          <option value="featured">Featured</option>
          <option value="flagged">Flagged</option>
        </select>
      </div>

      {/* Posts Grid */}
      <div className="grid gap-4">
        {isLoading ? (
          <div className="text-center py-8 text-slate-400">Loading...</div>
        ) : posts.length === 0 ? (
          <div className="text-center py-8 text-slate-400">No posts found</div>
        ) : (
          posts.map((post: Post) => (
            <div key={post._id} className="card">
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="font-medium text-white">{post.authorName}</span>
                    {post.isAdminPost && (
                      <span className="text-yellow-400" title="Admin Post">✦</span>
                    )}
                    <span className="text-slate-500">•</span>
                    <span className="text-sm text-slate-400">
                      {format(new Date(post.createdAt), 'MMM d, yyyy h:mm a')}
                    </span>
                    {post.isAdminPost && (
                      <span className="badge bg-gradient-to-r from-yellow-500 to-yellow-600 text-black flex items-center gap-1">
                        <Shield size={12} /> Admin
                      </span>
                    )}
                    {post.isFeatured && !post.isAdminPost && (
                      <span className="badge badge-warning flex items-center gap-1">
                        <Star size={12} /> Featured
                      </span>
                    )}
                    {post.isFlagged && (
                      <span className="badge badge-danger flex items-center gap-1">
                        <Flag size={12} /> Flagged
                      </span>
                    )}
                    {post.status !== 'active' && (
                      <span className="badge badge-info">{post.status}</span>
                    )}
                  </div>
                  <p className="text-slate-300 whitespace-pre-wrap">{post.content}</p>
                  {post.mediaURLs?.length > 0 && (
                    <div className="mt-3 flex gap-2">
                      {post.mediaURLs.slice(0, 3).map((url, i) => (
                        <img key={i} src={url} alt="" className="w-20 h-20 rounded-lg object-cover" />
                      ))}
                      {post.mediaURLs.length > 3 && (
                        <div className="w-20 h-20 rounded-lg bg-slate-700 flex items-center justify-center text-slate-400">
                          +{post.mediaURLs.length - 3}
                        </div>
                      )}
                    </div>
                  )}
                  <div className="mt-3 flex gap-4 text-sm text-slate-400">
                    <span>{post.likesCount} likes</span>
                    <span>{post.commentsCount} comments</span>
                  </div>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => handleToggleFeature(post)}
                    className={`p-2 rounded-lg transition-colors ${post.isFeatured ? 'bg-yellow-500/20 text-yellow-400' : 'bg-slate-700 text-slate-400 hover:text-yellow-400'}`}
                    title={post.isFeatured ? 'Remove from Featured' : 'Feature Post'}
                  >
                    <Star size={18} />
                  </button>
                  <button
                    onClick={() => handleToggleVisibility(post)}
                    className="p-2 bg-slate-700 rounded-lg text-slate-400 hover:text-white transition-colors"
                    title={post.status === 'active' ? 'Hide Post' : 'Show Post'}
                  >
                    {post.status === 'active' ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                  <button
                    onClick={() => handleDelete(post)}
                    className="p-2 bg-slate-700 rounded-lg text-slate-400 hover:text-red-400 transition-colors"
                    title="Delete Post"
                  >
                    <Trash2 size={18} />
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Pagination */}
      {pagination && pagination.pages > 1 && (
        <div className="flex justify-center gap-2">
          <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="btn btn-secondary">Previous</button>
          <span className="px-4 py-2 text-slate-400">Page {page} of {pagination.pages}</span>
          <button onClick={() => setPage(p => Math.min(pagination.pages, p + 1))} disabled={page === pagination.pages} className="btn btn-secondary">Next</button>
        </div>
      )}
    </div>
  );
}

