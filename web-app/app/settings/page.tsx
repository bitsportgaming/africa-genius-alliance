'use client';

import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { AGACard, AGAButton } from '@/components/ui';
import { useState } from 'react';
import {
  Settings,
  Lock,
  Shield,
  Bell,
  Eye,
  User,
  Mail,
  Smartphone,
  CheckCircle,
  AlertCircle,
  Copy,
  Download
} from 'lucide-react';

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState<'account' | 'security' | 'notifications' | 'privacy'>('account');

  // Account Settings State
  const [accountData, setAccountData] = useState({
    fullName: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+234 800 000 0000',
    bio: 'Passionate about African development and innovation.'
  });

  // Change Password State
  const [passwordData, setPasswordData] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  });
  const [passwordSuccess, setPasswordSuccess] = useState(false);

  // 2FA State
  const [twoFactorEnabled, setTwoFactorEnabled] = useState(false);
  const [showQRCode, setShowQRCode] = useState(false);
  const [backupCodes, setBackupCodes] = useState<string[]>([]);
  const qrCodeUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=otpauth://totp/AGA:john.doe@example.com?secret=JBSWY3DPEHPK3PXP&issuer=AGA';

  // Notification Preferences
  const [notifications, setNotifications] = useState({
    emailNewFollower: true,
    emailNewVote: true,
    emailNewComment: true,
    emailWeeklyDigest: true,
    pushNewFollower: false,
    pushNewVote: true,
    pushNewComment: true
  });

  // Privacy Settings
  const [privacy, setPrivacy] = useState({
    profileVisibility: 'public',
    showEmail: false,
    showPhone: false,
    allowMessages: true
  });

  const handlePasswordChange = (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Implement password change API call
    if (passwordData.newPassword === passwordData.confirmPassword) {
      setPasswordSuccess(true);
      setPasswordData({ currentPassword: '', newPassword: '', confirmPassword: '' });
      setTimeout(() => setPasswordSuccess(false), 3000);
    }
  };

  const handleEnable2FA = () => {
    // Generate backup codes
    const codes = Array.from({ length: 8 }, () =>
      Math.random().toString(36).substring(2, 10).toUpperCase()
    );
    setBackupCodes(codes);
    setShowQRCode(true);
  };

  const handleConfirm2FA = () => {
    // TODO: Verify 2FA code and enable
    setTwoFactorEnabled(true);
    setShowQRCode(false);
  };

  const handleDisable2FA = () => {
    // TODO: Implement 2FA disable API call
    setTwoFactorEnabled(false);
    setBackupCodes([]);
  };

  const copyBackupCodes = () => {
    navigator.clipboard.writeText(backupCodes.join('\n'));
  };

  const downloadBackupCodes = () => {
    const blob = new Blob([backupCodes.join('\n')], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'aga-backup-codes.txt';
    a.click();
  };

  const tabs = [
    { id: 'account', label: 'Account', icon: User },
    { id: 'security', label: 'Security', icon: Lock },
    { id: 'notifications', label: 'Notifications', icon: Bell },
    { id: 'privacy', label: 'Privacy', icon: Eye }
  ];

  return (
    <ProtectedRoute>
      <DashboardLayout>
        <div className="space-y-6">
          {/* Header */}
          <div>
            <h1 className="text-4xl font-black text-text-dark mb-2">Settings</h1>
            <p className="text-lg text-text-gray">
              Manage your account, security, and preferences
            </p>
          </div>

          {/* Tabs */}
          <AGACard variant="elevated" padding="sm">
            <div className="flex gap-2 overflow-x-auto">
              {tabs.map(({ id, label, icon: Icon }) => (
                <button
                  key={id}
                  onClick={() => setActiveTab(id as any)}
                  className={`flex items-center gap-2 px-6 py-3 rounded-aga font-medium transition-colors whitespace-nowrap ${
                    activeTab === id
                      ? 'bg-primary text-white'
                      : 'bg-gray-100 text-text-gray hover:bg-gray-200'
                  }`}
                >
                  <Icon className="w-5 h-5" />
                  {label}
                </button>
              ))}
            </div>
          </AGACard>

          {/* Account Settings */}
          {activeTab === 'account' && (
            <AGACard variant="elevated" padding="lg">
              <div className="space-y-6">
                <div>
                  <h2 className="text-2xl font-bold text-text-dark mb-4">Account Information</h2>
                  <p className="text-text-gray mb-6">Update your personal information</p>
                </div>

                <form className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-text-dark mb-2">
                      Full Name
                    </label>
                    <input
                      type="text"
                      value={accountData.fullName}
                      onChange={(e) => setAccountData({ ...accountData, fullName: e.target.value })}
                      className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-text-dark mb-2">
                      Email Address
                    </label>
                    <input
                      type="email"
                      value={accountData.email}
                      onChange={(e) => setAccountData({ ...accountData, email: e.target.value })}
                      className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-text-dark mb-2">
                      Phone Number
                    </label>
                    <input
                      type="tel"
                      value={accountData.phone}
                      onChange={(e) => setAccountData({ ...accountData, phone: e.target.value })}
                      className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-text-dark mb-2">
                      Bio
                    </label>
                    <textarea
                      value={accountData.bio}
                      onChange={(e) => setAccountData({ ...accountData, bio: e.target.value })}
                      rows={4}
                      className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                    />
                  </div>

                  <div className="flex gap-3">
                    <AGAButton variant="primary">Save Changes</AGAButton>
                    <AGAButton variant="outline">Cancel</AGAButton>
                  </div>
                </form>
              </div>
            </AGACard>
          )}

          {/* Security Settings */}
          {activeTab === 'security' && (
            <div className="space-y-6">
              {/* Change Password */}
              <AGACard variant="elevated" padding="lg">
                <div className="space-y-6">
                  <div>
                    <h2 className="text-2xl font-bold text-text-dark mb-2">Change Password</h2>
                    <p className="text-text-gray">Update your password to keep your account secure</p>
                  </div>

                  {passwordSuccess && (
                    <div className="flex items-center gap-2 p-4 bg-green-50 border border-green-200 rounded-aga text-green-700">
                      <CheckCircle className="w-5 h-5" />
                      <span>Password changed successfully!</span>
                    </div>
                  )}

                  <form onSubmit={handlePasswordChange} className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-text-dark mb-2">
                        Current Password
                      </label>
                      <input
                        type="password"
                        value={passwordData.currentPassword}
                        onChange={(e) => setPasswordData({ ...passwordData, currentPassword: e.target.value })}
                        required
                        className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-text-dark mb-2">
                        New Password
                      </label>
                      <input
                        type="password"
                        value={passwordData.newPassword}
                        onChange={(e) => setPasswordData({ ...passwordData, newPassword: e.target.value })}
                        required
                        minLength={8}
                        className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                      />
                      <p className="text-xs text-text-gray mt-1">Must be at least 8 characters</p>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-text-dark mb-2">
                        Confirm New Password
                      </label>
                      <input
                        type="password"
                        value={passwordData.confirmPassword}
                        onChange={(e) => setPasswordData({ ...passwordData, confirmPassword: e.target.value })}
                        required
                        className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                      />
                      {passwordData.confirmPassword && passwordData.newPassword !== passwordData.confirmPassword && (
                        <p className="text-xs text-red-600 mt-1">Passwords do not match</p>
                      )}
                    </div>

                    <div className="flex gap-3">
                      <AGAButton variant="primary" type="submit">
                        Change Password
                      </AGAButton>
                      <AGAButton
                        variant="outline"
                        type="button"
                        onClick={() => setPasswordData({ currentPassword: '', newPassword: '', confirmPassword: '' })}
                      >
                        Cancel
                      </AGAButton>
                    </div>
                  </form>
                </div>
              </AGACard>

              {/* Two-Factor Authentication */}
              <AGACard variant="elevated" padding="lg">
                <div className="space-y-6">
                  <div className="flex items-start justify-between">
                    <div>
                      <h2 className="text-2xl font-bold text-text-dark mb-2">Two-Factor Authentication</h2>
                      <p className="text-text-gray">Add an extra layer of security to your account</p>
                    </div>
                    {twoFactorEnabled && (
                      <span className="flex items-center gap-2 px-4 py-2 bg-green-50 border border-green-200 rounded-aga text-green-700 text-sm font-medium">
                        <Shield className="w-4 h-4" />
                        Enabled
                      </span>
                    )}
                  </div>

                  {!twoFactorEnabled && !showQRCode && (
                    <div>
                      <div className="flex items-start gap-3 p-4 bg-blue-50 border border-blue-200 rounded-aga mb-6">
                        <AlertCircle className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                        <div className="text-sm text-blue-800">
                          <p className="font-medium mb-1">Protect your account</p>
                          <p>Two-factor authentication adds an extra layer of security by requiring both your password and a verification code from your phone.</p>
                        </div>
                      </div>
                      <AGAButton variant="primary" onClick={handleEnable2FA}>
                        <Smartphone className="w-5 h-5 mr-2" />
                        Enable 2FA
                      </AGAButton>
                    </div>
                  )}

                  {!twoFactorEnabled && showQRCode && (
                    <div className="space-y-6">
                      <div>
                        <h3 className="font-bold text-text-dark mb-4">Step 1: Scan QR Code</h3>
                        <p className="text-text-gray mb-4">
                          Scan this QR code with your authenticator app (Google Authenticator, Authy, etc.)
                        </p>
                        <div className="flex justify-center p-6 bg-gray-50 rounded-aga">
                          <img src={qrCodeUrl} alt="2FA QR Code" className="w-48 h-48" />
                        </div>
                      </div>

                      <div>
                        <h3 className="font-bold text-text-dark mb-4">Step 2: Save Backup Codes</h3>
                        <p className="text-text-gray mb-4">
                          Save these backup codes in a safe place. You can use them to access your account if you lose your phone.
                        </p>
                        <div className="p-4 bg-gray-50 rounded-aga border border-gray-200 mb-4">
                          <div className="grid grid-cols-2 gap-2 font-mono text-sm">
                            {backupCodes.map((code, index) => (
                              <div key={index} className="flex items-center gap-2">
                                <span className="text-text-gray">{index + 1}.</span>
                                <code className="text-text-dark">{code}</code>
                              </div>
                            ))}
                          </div>
                        </div>
                        <div className="flex gap-3">
                          <AGAButton variant="outline" size="sm" onClick={copyBackupCodes}>
                            <Copy className="w-4 h-4 mr-2" />
                            Copy Codes
                          </AGAButton>
                          <AGAButton variant="outline" size="sm" onClick={downloadBackupCodes}>
                            <Download className="w-4 h-4 mr-2" />
                            Download Codes
                          </AGAButton>
                        </div>
                      </div>

                      <div>
                        <h3 className="font-bold text-text-dark mb-4">Step 3: Verify</h3>
                        <input
                          type="text"
                          placeholder="Enter 6-digit code from app"
                          maxLength={6}
                          className="w-full max-w-xs px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary mb-4"
                        />
                      </div>

                      <div className="flex gap-3">
                        <AGAButton variant="primary" onClick={handleConfirm2FA}>
                          Confirm & Enable
                        </AGAButton>
                        <AGAButton variant="outline" onClick={() => setShowQRCode(false)}>
                          Cancel
                        </AGAButton>
                      </div>
                    </div>
                  )}

                  {twoFactorEnabled && (
                    <div>
                      <div className="flex items-start gap-3 p-4 bg-green-50 border border-green-200 rounded-aga mb-6">
                        <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
                        <div className="text-sm text-green-800">
                          <p className="font-medium mb-1">Two-factor authentication is enabled</p>
                          <p>Your account is protected with an additional layer of security.</p>
                        </div>
                      </div>
                      <AGAButton variant="danger" onClick={handleDisable2FA}>
                        Disable 2FA
                      </AGAButton>
                    </div>
                  )}
                </div>
              </AGACard>
            </div>
          )}

          {/* Notification Preferences */}
          {activeTab === 'notifications' && (
            <AGACard variant="elevated" padding="lg">
              <div className="space-y-6">
                <div>
                  <h2 className="text-2xl font-bold text-text-dark mb-2">Notification Preferences</h2>
                  <p className="text-text-gray">Choose how you want to be notified</p>
                </div>

                <div className="space-y-6">
                  {/* Email Notifications */}
                  <div>
                    <h3 className="font-bold text-text-dark mb-4 flex items-center gap-2">
                      <Mail className="w-5 h-5" />
                      Email Notifications
                    </h3>
                    <div className="space-y-3">
                      {[
                        { key: 'emailNewFollower', label: 'New Follower', desc: 'When someone follows you' },
                        { key: 'emailNewVote', label: 'New Vote', desc: 'When someone votes for you' },
                        { key: 'emailNewComment', label: 'New Comment', desc: 'When someone comments on your post' },
                        { key: 'emailWeeklyDigest', label: 'Weekly Digest', desc: 'Summary of your activity' }
                      ].map(({ key, label, desc }) => (
                        <label key={key} className="flex items-center justify-between p-4 bg-gray-50 rounded-aga cursor-pointer hover:bg-gray-100 transition-colors">
                          <div>
                            <div className="font-medium text-text-dark">{label}</div>
                            <div className="text-sm text-text-gray">{desc}</div>
                          </div>
                          <input
                            type="checkbox"
                            checked={notifications[key as keyof typeof notifications]}
                            onChange={(e) => setNotifications({ ...notifications, [key]: e.target.checked })}
                            className="w-5 h-5 text-primary rounded focus:ring-2 focus:ring-primary"
                          />
                        </label>
                      ))}
                    </div>
                  </div>

                  {/* Push Notifications */}
                  <div>
                    <h3 className="font-bold text-text-dark mb-4 flex items-center gap-2">
                      <Smartphone className="w-5 h-5" />
                      Push Notifications
                    </h3>
                    <div className="space-y-3">
                      {[
                        { key: 'pushNewFollower', label: 'New Follower', desc: 'When someone follows you' },
                        { key: 'pushNewVote', label: 'New Vote', desc: 'When someone votes for you' },
                        { key: 'pushNewComment', label: 'New Comment', desc: 'When someone comments on your post' }
                      ].map(({ key, label, desc }) => (
                        <label key={key} className="flex items-center justify-between p-4 bg-gray-50 rounded-aga cursor-pointer hover:bg-gray-100 transition-colors">
                          <div>
                            <div className="font-medium text-text-dark">{label}</div>
                            <div className="text-sm text-text-gray">{desc}</div>
                          </div>
                          <input
                            type="checkbox"
                            checked={notifications[key as keyof typeof notifications]}
                            onChange={(e) => setNotifications({ ...notifications, [key]: e.target.checked })}
                            className="w-5 h-5 text-primary rounded focus:ring-2 focus:ring-primary"
                          />
                        </label>
                      ))}
                    </div>
                  </div>
                </div>

                <AGAButton variant="primary">Save Preferences</AGAButton>
              </div>
            </AGACard>
          )}

          {/* Privacy Settings */}
          {activeTab === 'privacy' && (
            <AGACard variant="elevated" padding="lg">
              <div className="space-y-6">
                <div>
                  <h2 className="text-2xl font-bold text-text-dark mb-2">Privacy Settings</h2>
                  <p className="text-text-gray">Control who can see your information</p>
                </div>

                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-text-dark mb-2">
                      Profile Visibility
                    </label>
                    <select
                      value={privacy.profileVisibility}
                      onChange={(e) => setPrivacy({ ...privacy, profileVisibility: e.target.value })}
                      className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                    >
                      <option value="public">Public - Anyone can see your profile</option>
                      <option value="followers">Followers Only - Only your followers can see</option>
                      <option value="private">Private - Only you can see</option>
                    </select>
                  </div>

                  <div className="space-y-3 pt-4">
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-aga cursor-pointer">
                      <div>
                        <div className="font-medium text-text-dark">Show Email Address</div>
                        <div className="text-sm text-text-gray">Display your email on your profile</div>
                      </div>
                      <input
                        type="checkbox"
                        checked={privacy.showEmail}
                        onChange={(e) => setPrivacy({ ...privacy, showEmail: e.target.checked })}
                        className="w-5 h-5 text-primary rounded focus:ring-2 focus:ring-primary"
                      />
                    </label>

                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-aga cursor-pointer">
                      <div>
                        <div className="font-medium text-text-dark">Show Phone Number</div>
                        <div className="text-sm text-text-gray">Display your phone on your profile</div>
                      </div>
                      <input
                        type="checkbox"
                        checked={privacy.showPhone}
                        onChange={(e) => setPrivacy({ ...privacy, showPhone: e.target.checked })}
                        className="w-5 h-5 text-primary rounded focus:ring-2 focus:ring-primary"
                      />
                    </label>

                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-aga cursor-pointer">
                      <div>
                        <div className="font-medium text-text-dark">Allow Direct Messages</div>
                        <div className="text-sm text-text-gray">Let other users send you messages</div>
                      </div>
                      <input
                        type="checkbox"
                        checked={privacy.allowMessages}
                        onChange={(e) => setPrivacy({ ...privacy, allowMessages: e.target.checked })}
                        className="w-5 h-5 text-primary rounded focus:ring-2 focus:ring-primary"
                      />
                    </label>
                  </div>
                </div>

                <div className="pt-6 border-t border-gray-200">
                  <h3 className="font-bold text-text-dark mb-2">Delete Account</h3>
                  <p className="text-text-gray mb-4 text-sm">
                    Once you delete your account, there is no going back. Please be certain.
                  </p>
                  <AGAButton variant="danger">
                    Delete My Account
                  </AGAButton>
                </div>

                <AGAButton variant="primary">Save Privacy Settings</AGAButton>
              </div>
            </AGACard>
          )}
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}
