'use client';

import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { AGACard, AGAButton } from '@/components/ui';
import { useState } from 'react';
import {
  Inbox,
  MessageSquare,
  Heart,
  UserPlus,
  Vote,
  Bell,
  Check,
  CheckCheck,
  Trash2,
  Filter
} from 'lucide-react';

export default function InboxPage() {
  const [filter, setFilter] = useState<'all' | 'unread' | 'votes' | 'follows' | 'comments'>('all');

  // Mock notifications - replace with actual API calls
  const notifications = [
    {
      id: '1',
      type: 'vote',
      title: 'New Vote Received',
      message: '5 people voted for you in the Political category',
      time: '2 hours ago',
      read: false,
      icon: Vote,
      color: 'primary'
    },
    {
      id: '2',
      type: 'follow',
      title: 'New Follower',
      message: 'Kwame Mensah started following you',
      time: '5 hours ago',
      read: false,
      icon: UserPlus,
      color: 'secondary'
    },
    {
      id: '3',
      type: 'comment',
      title: 'New Comment',
      message: 'Amina Hassan commented on your post: "Great initiative! How can we help?"',
      time: '1 day ago',
      read: true,
      icon: MessageSquare,
      color: 'blue'
    },
    {
      id: '4',
      type: 'like',
      title: 'Post Liked',
      message: '23 people liked your recent post about education reform',
      time: '2 days ago',
      read: true,
      icon: Heart,
      color: 'red'
    },
    {
      id: '5',
      type: 'system',
      title: 'Weekly Digest Available',
      message: 'Your AGA activity summary for this week is ready to view',
      time: '3 days ago',
      read: true,
      icon: Bell,
      color: 'yellow'
    }
  ];

  const filteredNotifications = notifications.filter(notif => {
    if (filter === 'all') return true;
    if (filter === 'unread') return !notif.read;
    return notif.type === filter || notif.type + 's' === filter;
  });

  const unreadCount = notifications.filter(n => !n.read).length;

  const getIconColor = (color: string) => {
    const colors: Record<string, string> = {
      primary: 'bg-primary/10 text-primary',
      secondary: 'bg-secondary/10 text-secondary',
      blue: 'bg-blue-100 text-blue-600',
      red: 'bg-red-100 text-red-600',
      yellow: 'bg-yellow-100 text-yellow-600'
    };
    return colors[color] || colors.primary;
  };

  return (
    <ProtectedRoute>
      <DashboardLayout>
        <div className="space-y-6">
          {/* Header */}
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-4xl font-black text-text-dark mb-2">Inbox</h1>
              <p className="text-lg text-text-gray">
                {unreadCount > 0 ? `You have ${unreadCount} unread notification${unreadCount !== 1 ? 's' : ''}` : 'All caught up!'}
              </p>
            </div>
            <AGAButton variant="outline" size="sm">
              <Check className="w-4 h-4 mr-2" />
              Mark All Read
            </AGAButton>
          </div>

          {/* Filters */}
          <AGACard variant="elevated" padding="md">
            <div className="flex items-center gap-2 flex-wrap">
              <Filter className="w-5 h-5 text-text-gray" />
              <button
                onClick={() => setFilter('all')}
                className={`px-4 py-2 rounded-aga text-sm font-medium transition-colors ${
                  filter === 'all'
                    ? 'bg-primary text-white'
                    : 'bg-gray-100 text-text-gray hover:bg-gray-200'
                }`}
              >
                All
              </button>
              <button
                onClick={() => setFilter('unread')}
                className={`px-4 py-2 rounded-aga text-sm font-medium transition-colors ${
                  filter === 'unread'
                    ? 'bg-primary text-white'
                    : 'bg-gray-100 text-text-gray hover:bg-gray-200'
                }`}
              >
                Unread {unreadCount > 0 && `(${unreadCount})`}
              </button>
              <button
                onClick={() => setFilter('votes')}
                className={`px-4 py-2 rounded-aga text-sm font-medium transition-colors ${
                  filter === 'votes'
                    ? 'bg-primary text-white'
                    : 'bg-gray-100 text-text-gray hover:bg-gray-200'
                }`}
              >
                Votes
              </button>
              <button
                onClick={() => setFilter('follows')}
                className={`px-4 py-2 rounded-aga text-sm font-medium transition-colors ${
                  filter === 'follows'
                    ? 'bg-primary text-white'
                    : 'bg-gray-100 text-text-gray hover:bg-gray-200'
                }`}
              >
                Follows
              </button>
              <button
                onClick={() => setFilter('comments')}
                className={`px-4 py-2 rounded-aga text-sm font-medium transition-colors ${
                  filter === 'comments'
                    ? 'bg-primary text-white'
                    : 'bg-gray-100 text-text-gray hover:bg-gray-200'
                }`}
              >
                Comments
              </button>
            </div>
          </AGACard>

          {/* Notifications List */}
          <div className="space-y-3">
            {filteredNotifications.length === 0 ? (
              <AGACard variant="elevated" padding="lg">
                <div className="text-center py-12">
                  <Inbox className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                  <h3 className="text-lg font-bold text-text-dark mb-2">
                    No notifications yet
                  </h3>
                  <p className="text-text-gray">
                    {filter === 'unread'
                      ? "You're all caught up!"
                      : 'Your notifications will appear here'}
                  </p>
                </div>
              </AGACard>
            ) : (
              filteredNotifications.map((notif) => {
                const IconComponent = notif.icon;
                return (
                  <AGACard
                    key={notif.id}
                    variant="elevated"
                    padding="md"
                    hoverable
                    className={`cursor-pointer ${!notif.read ? 'border-l-4 border-l-primary' : ''}`}
                  >
                    <div className="flex items-start gap-4">
                      {/* Icon */}
                      <div className={`w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0 ${getIconColor(notif.color)}`}>
                        <IconComponent className="w-6 h-6" />
                      </div>

                      {/* Content */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between gap-4 mb-1">
                          <h3 className="font-bold text-text-dark">
                            {notif.title}
                            {!notif.read && (
                              <span className="ml-2 w-2 h-2 bg-primary rounded-full inline-block" />
                            )}
                          </h3>
                          <span className="text-xs text-text-gray whitespace-nowrap">
                            {notif.time}
                          </span>
                        </div>
                        <p className="text-sm text-text-gray line-clamp-2">
                          {notif.message}
                        </p>
                      </div>

                      {/* Actions */}
                      <div className="flex items-center gap-2">
                        {!notif.read && (
                          <button
                            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                            title="Mark as read"
                          >
                            <CheckCheck className="w-4 h-4 text-text-gray" />
                          </button>
                        )}
                        <button
                          className="p-2 hover:bg-red-50 rounded-lg transition-colors"
                          title="Delete"
                        >
                          <Trash2 className="w-4 h-4 text-red-500" />
                        </button>
                      </div>
                    </div>
                  </AGACard>
                );
              })
            )}
          </div>

          {/* Load More */}
          {filteredNotifications.length > 0 && (
            <div className="text-center">
              <AGAButton variant="outline">
                Load More Notifications
              </AGAButton>
            </div>
          )}
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}
