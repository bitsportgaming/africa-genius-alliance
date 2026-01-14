'use client';

import { useState } from 'react';
import { Share2, X, Copy, Check } from 'lucide-react';
import { AGAButton } from './AGAButton';

interface ShareMenuProps {
  postId: string;
  postContent: string;
  authorName: string;
}

export function ShareMenu({ postId, postContent, authorName }: ShareMenuProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [copied, setCopied] = useState(false);

  const shareUrl = `${typeof window !== 'undefined' ? window.location.origin : ''}/post/${postId}`;
  const shareText = `Check out this post by ${authorName} on Africa Genius Alliance: ${postContent.slice(0, 100)}${postContent.length > 100 ? '...' : ''}`;

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(shareUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error('Failed to copy:', err);
    }
  };

  const shareOptions = [
    {
      name: 'X (Twitter)',
      icon: '/icons/x-logo.svg',
      iconFallback: '𝕏',
      url: `https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}&url=${encodeURIComponent(shareUrl)}`,
      color: 'hover:bg-black hover:text-white'
    },
    {
      name: 'Facebook',
      icon: '/icons/facebook-logo.svg',
      iconFallback: 'f',
      url: `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`,
      color: 'hover:bg-blue-600 hover:text-white'
    },
    {
      name: 'LinkedIn',
      icon: '/icons/linkedin-logo.svg',
      iconFallback: 'in',
      url: `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(shareUrl)}`,
      color: 'hover:bg-blue-700 hover:text-white'
    },
    {
      name: 'WhatsApp',
      icon: '/icons/whatsapp-logo.svg',
      iconFallback: 'W',
      url: `https://wa.me/?text=${encodeURIComponent(shareText + ' ' + shareUrl)}`,
      color: 'hover:bg-green-500 hover:text-white'
    },
    {
      name: 'Telegram',
      icon: '/icons/telegram-logo.svg',
      iconFallback: 'T',
      url: `https://t.me/share/url?url=${encodeURIComponent(shareUrl)}&text=${encodeURIComponent(shareText)}`,
      color: 'hover:bg-blue-500 hover:text-white'
    }
  ];

  const handleShare = (url: string) => {
    window.open(url, '_blank', 'noopener,noreferrer,width=600,height=600');
    setIsOpen(false);
  };

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-2 text-text-gray hover:text-secondary transition-colors"
      >
        <Share2 className="w-5 h-5" />
      </button>

      {isOpen && (
        <>
          {/* Backdrop */}
          <div
            className="fixed inset-0 z-40"
            onClick={() => setIsOpen(false)}
          />

          {/* Menu */}
          <div className="absolute bottom-full right-0 mb-2 z-50 bg-white rounded-2xl shadow-2xl border border-gray-200 p-4 min-w-[280px]">
            {/* Header */}
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-gray-200">
              <h3 className="font-bold text-text-dark text-sm">Share this post</h3>
              <button
                onClick={() => setIsOpen(false)}
                className="p-1 hover:bg-gray-100 rounded-lg transition-colors"
              >
                <X className="w-4 h-4 text-text-gray" />
              </button>
            </div>

            {/* Share Options Grid */}
            <div className="grid grid-cols-3 gap-3 mb-4">
              {shareOptions.map((option) => (
                <button
                  key={option.name}
                  onClick={() => handleShare(option.url)}
                  className={`flex flex-col items-center gap-2 p-3 rounded-xl border border-gray-200 transition-all ${option.color}`}
                >
                  <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center text-lg font-bold">
                    {option.iconFallback}
                  </div>
                  <span className="text-xs font-medium text-center">{option.name}</span>
                </button>
              ))}
            </div>

            {/* Copy Link Button */}
            <button
              onClick={handleCopyLink}
              className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-gray-100 hover:bg-gray-200 rounded-xl transition-colors text-sm font-medium text-text-dark"
            >
              {copied ? (
                <>
                  <Check className="w-4 h-4 text-green-600" />
                  <span className="text-green-600">Link copied!</span>
                </>
              ) : (
                <>
                  <Copy className="w-4 h-4" />
                  Copy link
                </>
              )}
            </button>
          </div>
        </>
      )}
    </div>
  );
}
