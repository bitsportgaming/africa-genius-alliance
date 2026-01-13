'use client';

import { useAuth } from '@/lib/store/auth-store';
import { UserRole } from '@/types';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import {
  Home,
  Compass,
  Vote,
  PlusCircle,
  TrendingUp,
  User,
  Bell,
  Menu,
  X,
  LogOut,
  Settings
} from 'lucide-react';
import { useState } from 'react';

export function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, logout } = useAuth();
  const pathname = usePathname();
  const router = useRouter();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [profileMenuOpen, setProfileMenuOpen] = useState(false);
  const [notificationsOpen, setNotificationsOpen] = useState(false);

  // Mock notifications - replace with real API data
  const notifications = [
    { id: 1, type: 'vote', message: 'You received 5 new votes!', time: '2 hours ago', read: false },
    { id: 2, type: 'follow', message: 'Amina Okafor started following you', time: '5 hours ago', read: false },
    { id: 3, type: 'comment', message: 'New comment on your post', time: '1 day ago', read: true },
  ];

  const isGenius = user?.role === UserRole.GENIUS;

  const navigation = [
    { name: 'Home', href: '/dashboard', icon: Home, show: true },
    { name: 'Explore', href: '/explore', icon: Compass, show: true },
    { name: 'Vote', href: '/vote', icon: Vote, show: !isGenius },
    { name: 'Create', href: '/create', icon: PlusCircle, show: isGenius },
    { name: 'Impact', href: '/impact', icon: TrendingUp, show: true },
    { name: 'Profile', href: '/profile', icon: User, show: true },
  ].filter(item => item.show);

  const handleLogout = () => {
    logout();
    router.push('/');
  };

  return (
    <div className="min-h-screen bg-background-cream">
      {/* Top Navigation */}
      <nav className="bg-white border-b border-gray-200 sticky top-0 z-40 shadow-sm">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <Link href="/dashboard" className="flex items-center gap-2">
              <div className="w-10 h-10 rounded-xl bg-gradient-primary flex items-center justify-center">
                <span className="text-white font-black text-xl">A</span>
              </div>
              <span className="text-2xl font-black text-primary hidden sm:block">AGA</span>
            </Link>

            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center gap-2">
              {navigation.map((item) => {
                const Icon = item.icon;
                const isActive = pathname === item.href;
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-all duration-200 ${
                      isActive
                        ? 'bg-primary text-white shadow-aga'
                        : 'text-gray-700 hover:bg-gray-100'
                    }`}
                  >
                    <Icon className="w-5 h-5" />
                    <span>{item.name}</span>
                  </Link>
                );
              })}
            </div>

            {/* Right Side */}
            <div className="flex items-center gap-3">
              {/* Notifications */}
              <div className="relative">
                <button
                  onClick={() => {
                    setNotificationsOpen(!notificationsOpen);
                    setProfileMenuOpen(false);
                  }}
                  className="relative p-2 hover:bg-gray-100 rounded-full transition-colors"
                >
                  <Bell className="w-6 h-6 text-gray-700" />
                  {notifications.some(n => !n.read) && (
                    <span className="absolute top-1 right-1 w-2 h-2 bg-secondary rounded-full animate-pulse" />
                  )}
                </button>

                {/* Notifications Dropdown */}
                {notificationsOpen && (
                  <>
                    <div
                      className="fixed inset-0 z-40"
                      onClick={() => setNotificationsOpen(false)}
                    />
                    <div className="absolute right-0 mt-2 w-80 bg-white rounded-aga shadow-aga-lg border border-gray-200 z-50 overflow-hidden">
                      <div className="px-4 py-3 border-b border-gray-200 flex items-center justify-between">
                        <h3 className="font-semibold text-text-dark">Notifications</h3>
                        <button className="text-xs text-primary hover:underline">Mark all read</button>
                      </div>
                      <div className="max-h-80 overflow-y-auto">
                        {notifications.length > 0 ? (
                          notifications.map((notification) => (
                            <div
                              key={notification.id}
                              className={`px-4 py-3 border-b border-gray-100 hover:bg-gray-50 cursor-pointer ${
                                !notification.read ? 'bg-primary/5' : ''
                              }`}
                            >
                              <p className="text-sm text-text-dark">{notification.message}</p>
                              <p className="text-xs text-text-gray mt-1">{notification.time}</p>
                            </div>
                          ))
                        ) : (
                          <div className="px-4 py-8 text-center text-text-gray">
                            No notifications yet
                          </div>
                        )}
                      </div>
                      <div className="px-4 py-2 border-t border-gray-200 text-center">
                        <Link
                          href="/notifications"
                          className="text-sm text-primary hover:underline"
                          onClick={() => setNotificationsOpen(false)}
                        >
                          View all notifications
                        </Link>
                      </div>
                    </div>
                  </>
                )}
              </div>

              {/* Profile Menu */}
              <div className="relative hidden md:block">
                <button
                  onClick={() => setProfileMenuOpen(!profileMenuOpen)}
                  className="flex items-center gap-3 p-2 hover:bg-gray-100 rounded-lg transition-colors"
                >
                  <div className="w-10 h-10 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold">
                    {user?.displayName?.[0]?.toUpperCase() || 'U'}
                  </div>
                  <div className="text-left hidden lg:block">
                    <div className="text-sm font-semibold text-text-dark">
                      {user?.displayName}
                    </div>
                    <div className="text-xs text-text-gray capitalize">
                      {user?.role === UserRole.GENIUS ? 'Genius' : 'Supporter'}
                    </div>
                  </div>
                </button>

                {/* Profile Dropdown */}
                {profileMenuOpen && (
                  <>
                    <div
                      className="fixed inset-0 z-40"
                      onClick={() => setProfileMenuOpen(false)}
                    />
                    <div className="absolute right-0 mt-2 w-56 bg-white rounded-aga shadow-aga-lg border border-gray-200 py-2 z-50">
                      <div className="px-4 py-3 border-b border-gray-200">
                        <p className="text-sm font-semibold text-text-dark">
                          {user?.displayName}
                        </p>
                        <p className="text-xs text-text-gray">{user?.email}</p>
                      </div>
                      <Link
                        href="/profile"
                        className="flex items-center gap-3 px-4 py-2 hover:bg-gray-50 transition-colors"
                        onClick={() => setProfileMenuOpen(false)}
                      >
                        <User className="w-4 h-4 text-gray-600" />
                        <span className="text-sm text-text-dark">Profile</span>
                      </Link>
                      <Link
                        href="/settings"
                        className="flex items-center gap-3 px-4 py-2 hover:bg-gray-50 transition-colors"
                        onClick={() => setProfileMenuOpen(false)}
                      >
                        <Settings className="w-4 h-4 text-gray-600" />
                        <span className="text-sm text-text-dark">Settings</span>
                      </Link>
                      <hr className="my-2 border-gray-200" />
                      <button
                        onClick={handleLogout}
                        className="w-full flex items-center gap-3 px-4 py-2 hover:bg-red-50 transition-colors text-left"
                      >
                        <LogOut className="w-4 h-4 text-red-600" />
                        <span className="text-sm text-red-600">Logout</span>
                      </button>
                    </div>
                  </>
                )}
              </div>

              {/* Mobile Menu Toggle */}
              <button
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                className="md:hidden p-2 hover:bg-gray-100 rounded-lg transition-colors"
              >
                {mobileMenuOpen ? (
                  <X className="w-6 h-6 text-gray-700" />
                ) : (
                  <Menu className="w-6 h-6 text-gray-700" />
                )}
              </button>
            </div>
          </div>
        </div>

        {/* Mobile Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden border-t border-gray-200 bg-white">
            <div className="container mx-auto px-4 py-4 space-y-2">
              {navigation.map((item) => {
                const Icon = item.icon;
                const isActive = pathname === item.href;
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={`flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-all ${
                      isActive
                        ? 'bg-primary text-white'
                        : 'text-gray-700 hover:bg-gray-100'
                    }`}
                    onClick={() => setMobileMenuOpen(false)}
                  >
                    <Icon className="w-5 h-5" />
                    <span>{item.name}</span>
                  </Link>
                );
              })}
              <hr className="my-2 border-gray-200" />
              <button
                onClick={handleLogout}
                className="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-red-600 hover:bg-red-50 transition-colors text-left font-medium"
              >
                <LogOut className="w-5 h-5" />
                <span>Logout</span>
              </button>
            </div>
          </div>
        )}
      </nav>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        {children}
      </main>
    </div>
  );
}
