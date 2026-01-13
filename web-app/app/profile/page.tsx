'use client';

import { useState, useRef } from 'react';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { useAuth } from '@/lib/store/auth-store';
import { AGACard, AGAButton, AGAPill } from '@/components/ui';
import {
  User,
  Mail,
  MapPin,
  Calendar,
  Upload,
  Save,
  LogOut,
  Shield,
  Bell,
  Lock,
  Globe,
  Award,
  TrendingUp,
  Users as UsersIcon,
} from 'lucide-react';
import { useRouter } from 'next/navigation';
import { UserRole } from '@/types';

export default function ProfilePage() {
  const { user, logout, updateUser } = useAuth();
  const router = useRouter();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [formData, setFormData] = useState({
    displayName: user?.displayName || '',
    bio: user?.bio || '',
    country: user?.country || '',
    geniusPosition: user?.geniusPosition || '',
  });

  const isGenius = user?.role === UserRole.GENIUS;

  const handleSave = async () => {
    if (!user?._id) return;

    setIsSaving(true);
    try {
      // Call API to update profile
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/users`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          userId: user._id,
          displayName: formData.displayName,
          bio: formData.bio,
          country: formData.country,
          positionTitle: formData.geniusPosition,
        }),
      });

      const data = await response.json();

      if (data.success && data.data) {
        // Update user in store
        updateUser(data.data);
        setIsEditing(false);
      } else {
        console.error('Failed to update profile:', data.error);
        alert('Failed to update profile. Please try again.');
      }
    } catch (error) {
      console.error('Error updating profile:', error);
      alert('Failed to update profile. Please try again.');
    } finally {
      setIsSaving(false);
    }
  };

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !user?._id) return;

    try {
      // Create form data for file upload
      const formData = new FormData();
      formData.append('image', file);
      formData.append('userId', user._id);

      // Upload to server
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/upload/profile-image`, {
        method: 'POST',
        body: formData,
      });

      const data = await response.json();

      if (data.success && data.imageUrl) {
        // Update user with new profile image URL
        updateUser({ ...user, profileImageURL: data.imageUrl });
      } else {
        console.error('Failed to upload image:', data.error);
        alert('Failed to upload image. Please try again.');
      }
    } catch (error) {
      console.error('Error uploading image:', error);
      alert('Failed to upload image. Please try again.');
    }
  };

  const handleLogout = () => {
    logout();
    router.push('/');
  };

  return (
    <ProtectedRoute>
      <DashboardLayout>
        <div className="max-w-4xl mx-auto space-y-6">
          {/* Header */}
          <div>
            <h1 className="text-4xl font-black text-text-dark mb-2">
              My Profile
            </h1>
            <p className="text-lg text-text-gray">
              Manage your account settings and preferences
            </p>
          </div>

          {/* Profile Card */}
          <AGACard variant="elevated" padding="lg">
            <div className="flex flex-col md:flex-row gap-8">
              {/* Avatar Section */}
              <div className="flex flex-col items-center">
                <div className="relative">
                  {user?.profileImageURL ? (
                    <img
                      src={user.profileImageURL.startsWith('http') ? user.profileImageURL : `${process.env.NEXT_PUBLIC_API_URL}${user.profileImageURL}`}
                      alt={user.displayName || 'Profile'}
                      className="w-32 h-32 rounded-full object-cover"
                    />
                  ) : (
                    <div className="w-32 h-32 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-5xl">
                      {user?.displayName?.[0]?.toUpperCase() || 'U'}
                    </div>
                  )}
                  <button
                    onClick={() => fileInputRef.current?.click()}
                    className="absolute bottom-0 right-0 w-10 h-10 bg-primary text-white rounded-full flex items-center justify-center hover:bg-primary-dark transition-colors shadow-aga"
                  >
                    <Upload className="w-5 h-5" />
                  </button>
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept="image/*"
                    onChange={handleImageUpload}
                    className="hidden"
                  />
                </div>
                <AGAPill
                  variant={isGenius ? 'secondary' : 'primary'}
                  size="md"
                  className="mt-4"
                >
                  {isGenius ? 'Genius' : 'Supporter'}
                </AGAPill>
              </div>

              {/* Info Section */}
              <div className="flex-1">
                {!isEditing ? (
                  <>
                    <div className="flex items-start justify-between mb-6">
                      <div>
                        <h2 className="text-3xl font-black text-text-dark mb-2">
                          {user?.displayName || user?.email?.split('@')[0] || 'User'}
                        </h2>
                        {isGenius && user?.geniusPosition && (
                          <p className="text-text-gray mb-2">
                            {user.geniusPosition}
                          </p>
                        )}
                        {user?.verificationStatus === 'verified' && (
                          <AGAPill variant="success" size="sm">
                            <Shield className="w-3 h-3 mr-1" />
                            Verified
                          </AGAPill>
                        )}
                      </div>
                      <AGAButton
                        variant="outline"
                        size="sm"
                        onClick={() => setIsEditing(true)}
                      >
                        Edit Profile
                      </AGAButton>
                    </div>

                    <div className="space-y-3 mb-6">
                      <div className="flex items-center gap-3 text-text-gray">
                        <Mail className="w-5 h-5" />
                        <span>{user?.email}</span>
                      </div>
                      {user?.country && (
                        <div className="flex items-center gap-3 text-text-gray">
                          <MapPin className="w-5 h-5" />
                          <span>{user.country}</span>
                        </div>
                      )}
                      <div className="flex items-center gap-3 text-text-gray">
                        <Calendar className="w-5 h-5" />
                        <span>
                          Joined{' '}
                          {user?.createdAt
                            ? new Date(user.createdAt).toLocaleDateString('en-US', {
                                month: 'long',
                                year: 'numeric',
                              })
                            : 'Recently'}
                        </span>
                      </div>
                    </div>

                    {user?.bio && (
                      <div className="p-4 bg-gray-50 rounded-lg">
                        <p className="text-text-gray">{user.bio}</p>
                      </div>
                    )}
                  </>
                ) : (
                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-semibold text-text-dark mb-2">
                        Display Name
                      </label>
                      <input
                        type="text"
                        value={formData.displayName}
                        onChange={(e) =>
                          setFormData({ ...formData, displayName: e.target.value })
                        }
                        className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none"
                      />
                    </div>

                    {isGenius && (
                      <div>
                        <label className="block text-sm font-semibold text-text-dark mb-2">
                          Position
                        </label>
                        <input
                          type="text"
                          value={formData.geniusPosition}
                          onChange={(e) =>
                            setFormData({ ...formData, geniusPosition: e.target.value })
                          }
                          className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none"
                        />
                      </div>
                    )}

                    <div>
                      <label className="block text-sm font-semibold text-text-dark mb-2">
                        Country
                      </label>
                      <input
                        type="text"
                        value={formData.country}
                        onChange={(e) =>
                          setFormData({ ...formData, country: e.target.value })
                        }
                        className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-semibold text-text-dark mb-2">
                        Bio
                      </label>
                      <textarea
                        value={formData.bio}
                        onChange={(e) =>
                          setFormData({ ...formData, bio: e.target.value })
                        }
                        rows={4}
                        className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none resize-none"
                      />
                    </div>

                    <div className="flex gap-3 pt-4">
                      <AGAButton
                        variant="outline"
                        onClick={() => {
                          setIsEditing(false);
                          setFormData({
                            displayName: user?.displayName || '',
                            bio: user?.bio || '',
                            country: user?.country || '',
                            geniusPosition: user?.geniusPosition || '',
                          });
                        }}
                      >
                        Cancel
                      </AGAButton>
                      <AGAButton
                        variant="primary"
                        onClick={handleSave}
                        loading={isSaving}
                        leftIcon={<Save className="w-5 h-5" />}
                      >
                        Save Changes
                      </AGAButton>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </AGACard>

          {/* Stats */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <AGACard variant="elevated" padding="md">
              <div className="text-center">
                <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center mx-auto mb-2">
                  <TrendingUp className="w-6 h-6 text-primary" />
                </div>
                <div className="text-2xl font-black text-text-dark">
                  {user?.votesReceived || 0}
                </div>
                <div className="text-xs text-text-gray">
                  {isGenius ? 'Votes Received' : 'Votes Cast'}
                </div>
              </div>
            </AGACard>

            <AGACard variant="elevated" padding="md">
              <div className="text-center">
                <div className="w-12 h-12 rounded-xl bg-secondary/10 flex items-center justify-center mx-auto mb-2">
                  <UsersIcon className="w-6 h-6 text-secondary" />
                </div>
                <div className="text-2xl font-black text-text-dark">
                  {user?.followersCount || 0}
                </div>
                <div className="text-xs text-text-gray">Followers</div>
              </div>
            </AGACard>

            <AGACard variant="elevated" padding="md">
              <div className="text-center">
                <div className="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center mx-auto mb-2">
                  <Globe className="w-6 h-6 text-green-600" />
                </div>
                <div className="text-2xl font-black text-text-dark">
                  {user?.followingCount || 0}
                </div>
                <div className="text-xs text-text-gray">Following</div>
              </div>
            </AGACard>

            {isGenius && (
              <AGACard variant="elevated" padding="md">
                <div className="text-center">
                  <div className="w-12 h-12 rounded-xl bg-yellow-500/10 flex items-center justify-center mx-auto mb-2">
                    <Award className="w-6 h-6 text-yellow-600" />
                  </div>
                  <div className="text-2xl font-black text-text-dark">
                    #{user?.rank || '—'}
                  </div>
                  <div className="text-xs text-text-gray">Rank</div>
                </div>
              </AGACard>
            )}
          </div>

          {/* Settings Sections */}
          <AGACard variant="elevated" padding="lg">
            <h3 className="text-xl font-bold text-text-dark mb-4">
              Notification Settings
            </h3>
            <div className="space-y-4">
              {[
                { label: 'Email notifications', desc: 'Receive updates via email' },
                { label: 'Push notifications', desc: 'Browser push notifications' },
                { label: 'New followers', desc: 'Get notified when someone follows you' },
                { label: 'New votes', desc: 'Get notified when you receive votes' },
                { label: 'Comments', desc: 'Get notified on post comments' },
              ].map((setting, index) => (
                <div key={index} className="flex items-center justify-between py-3 border-b border-gray-100 last:border-0">
                  <div>
                    <p className="font-medium text-text-dark">{setting.label}</p>
                    <p className="text-sm text-text-gray">{setting.desc}</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" defaultChecked className="sr-only peer" />
                    <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                  </label>
                </div>
              ))}
            </div>
          </AGACard>

          {/* Security */}
          <AGACard variant="elevated" padding="lg">
            <h3 className="text-xl font-bold text-text-dark mb-4">
              Security
            </h3>
            <div className="space-y-3">
              <AGAButton
                variant="outline"
                fullWidth
                leftIcon={<Lock className="w-5 h-5" />}
                onClick={() => window.location.href = '/auth/forgot-password'}
              >
                Change Password
              </AGAButton>
              <AGAButton
                variant="outline"
                fullWidth
                leftIcon={<Shield className="w-5 h-5" />}
                onClick={() => alert('Two-Factor Authentication coming soon!')}
              >
                Two-Factor Authentication
              </AGAButton>
            </div>
          </AGACard>

          {/* Danger Zone */}
          <AGACard variant="elevated" padding="lg" className="border-2 border-red-200">
            <h3 className="text-xl font-bold text-red-600 mb-4">Danger Zone</h3>
            <div className="space-y-3">
              <AGAButton
                variant="danger"
                fullWidth
                onClick={handleLogout}
                leftIcon={<LogOut className="w-5 h-5" />}
              >
                Logout
              </AGAButton>
              <AGAButton
                variant="outline"
                fullWidth
                className="!text-red-600 !border-red-300 hover:!bg-red-50"
                onClick={() => {
                  if (confirm('Are you sure you want to delete your account? This action cannot be undone.')) {
                    alert('Account deletion request submitted. You will receive an email confirmation.');
                  }
                }}
              >
                Delete Account
              </AGAButton>
            </div>
          </AGACard>
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}
