'use client';

import { useState, useRef } from 'react';
import { AGAButton, AGAPill } from '@/components/ui';
import { Image, Video, X, Upload, AlertCircle } from 'lucide-react';
import { postsAPI } from '@/lib/api';
import { useAuth } from '@/lib/store/auth-store';

const MAX_CHARS = 500;
const MAX_IMAGES = 5;
const MAX_VIDEO = 1;

export function CreatePostTab() {
  const { user } = useAuth();
  const [content, setContent] = useState('');
  const [files, setFiles] = useState<File[]>([]);
  const [previews, setPreviews] = useState<string[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const imageInputRef = useRef<HTMLInputElement>(null);
  const videoInputRef = useRef<HTMLInputElement>(null);

  const remainingChars = MAX_CHARS - content.length;
  const hasVideo = files.some(f => f.type.startsWith('video/'));

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>, type: 'image' | 'video') => {
    const selectedFiles = Array.from(e.target.files || []);
    if (selectedFiles.length === 0) return;

    // Validation
    if (type === 'video' && files.length > 0) {
      setError('You can only upload 1 video OR multiple images, not both');
      return;
    }

    if (type === 'image' && hasVideo) {
      setError('You can only upload 1 video OR multiple images, not both');
      return;
    }

    if (type === 'image' && files.length + selectedFiles.length > MAX_IMAGES) {
      setError(`Maximum ${MAX_IMAGES} images allowed`);
      return;
    }

    if (type === 'video' && files.length + selectedFiles.length > MAX_VIDEO) {
      setError('Only 1 video allowed per post');
      return;
    }

    setError(null);

    // Add files
    const newFiles = [...files, ...selectedFiles];
    setFiles(newFiles);

    // Create previews
    selectedFiles.forEach((file) => {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreviews((prev) => [...prev, reader.result as string]);
      };
      reader.readAsDataURL(file);
    });
  };

  const removeFile = (index: number) => {
    setFiles((prev) => prev.filter((_, i) => i !== index));
    setPreviews((prev) => prev.filter((_, i) => i !== index));
    setError(null);
  };

  const handleSubmit = async () => {
    if (!content.trim()) {
      setError('Please write something');
      return;
    }

    if (remainingChars < 0) {
      setError('Content is too long');
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      // Determine post type
      let postType: 'text' | 'image' | 'video' = 'text';
      if (files.length > 0) {
        postType = hasVideo ? 'video' : 'image';
      }

      await postsAPI.createPost({
        content: content.trim(),
        files: files.length > 0 ? files : undefined,
        postType,
      });

      setSuccess(true);
      setContent('');
      setFiles([]);
      setPreviews([]);

      setTimeout(() => setSuccess(false), 3000);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Failed to create post');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Success Message */}
      {success && (
        <div className="p-4 bg-green-50 border border-green-200 rounded-aga text-green-700 flex items-center gap-2">
          <span className="text-xl">✓</span>
          <span className="font-medium">Post created successfully!</span>
        </div>
      )}

      {/* Error Message */}
      {error && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-aga text-red-700 flex items-start gap-2">
          <AlertCircle className="w-5 h-5 mt-0.5 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {/* Content Input */}
      <div>
        <label className="block text-sm font-semibold text-text-dark mb-2">
          What's on your mind, {user?.displayName}?
        </label>
        <textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Share your vision, ideas, or updates with your supporters..."
          rows={6}
          className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none resize-none transition-all"
        />
        <div className="flex items-center justify-between mt-2">
          <span
            className={`text-sm ${
              remainingChars < 50
                ? remainingChars < 0
                  ? 'text-red-600 font-bold'
                  : 'text-orange-600 font-semibold'
                : 'text-text-gray'
            }`}
          >
            {remainingChars} characters remaining
          </span>
          <AGAPill variant={remainingChars < 50 ? 'warning' : 'neutral'} size="sm">
            {content.length} / {MAX_CHARS}
          </AGAPill>
        </div>
      </div>

      {/* Media Upload */}
      <div>
        <label className="block text-sm font-semibold text-text-dark mb-3">
          Add Media (Optional)
        </label>

        <div className="flex gap-3">
          {/* Image Upload Button */}
          <button
            type="button"
            onClick={() => imageInputRef.current?.click()}
            disabled={hasVideo || files.length >= MAX_IMAGES}
            className="flex-1 p-4 border-2 border-dashed border-gray-300 rounded-aga hover:border-primary hover:bg-primary/5 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Image className="w-8 h-8 text-gray-400 mx-auto mb-2" />
            <p className="text-sm font-medium text-text-dark">
              Upload Images
            </p>
            <p className="text-xs text-text-gray mt-1">
              Up to {MAX_IMAGES} images
            </p>
          </button>

          {/* Video Upload Button */}
          <button
            type="button"
            onClick={() => videoInputRef.current?.click()}
            disabled={files.length > 0}
            className="flex-1 p-4 border-2 border-dashed border-gray-300 rounded-aga hover:border-primary hover:bg-primary/5 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Video className="w-8 h-8 text-gray-400 mx-auto mb-2" />
            <p className="text-sm font-medium text-text-dark">
              Upload Video
            </p>
            <p className="text-xs text-text-gray mt-1">
              1 video per post
            </p>
          </button>

          {/* Hidden File Inputs */}
          <input
            ref={imageInputRef}
            type="file"
            accept="image/*"
            multiple
            onChange={(e) => handleFileSelect(e, 'image')}
            className="hidden"
          />
          <input
            ref={videoInputRef}
            type="file"
            accept="video/*"
            onChange={(e) => handleFileSelect(e, 'video')}
            className="hidden"
          />
        </div>
      </div>

      {/* File Previews */}
      {previews.length > 0 && (
        <div>
          <label className="block text-sm font-semibold text-text-dark mb-3">
            Preview ({files.length} {hasVideo ? 'video' : 'image'}
            {files.length > 1 ? 's' : ''})
          </label>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {previews.map((preview, index) => (
              <div key={index} className="relative group rounded-aga overflow-hidden border-2 border-gray-200">
                {files[index].type.startsWith('video/') ? (
                  <video src={preview} className="w-full h-40 object-cover" controls />
                ) : (
                  <img src={preview} alt={`Preview ${index + 1}`} className="w-full h-40 object-cover" />
                )}
                <button
                  onClick={() => removeFile(index)}
                  className="absolute top-2 right-2 w-8 h-8 bg-red-500 text-white rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Submit Button */}
      <div className="flex items-center justify-between pt-4 border-t border-gray-200">
        <div className="text-sm text-text-gray">
          Your post will be visible to all your followers
        </div>
        <AGAButton
          variant="primary"
          size="lg"
          onClick={handleSubmit}
          loading={isSubmitting}
          disabled={!content.trim() || remainingChars < 0}
          leftIcon={<Upload className="w-5 h-5" />}
        >
          Publish Post
        </AGAButton>
      </div>
    </div>
  );
}
