'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/lib/store/auth-store';
import { AGAButton, AGACard } from '@/components/ui';
import Link from 'next/link';
import { Mail, Lock, ArrowRight } from 'lucide-react';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { login, isLoading, error, clearError } = useAuth();
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();

    try {
      await login({ email, password });
      router.push('/dashboard');
    } catch (err) {
      // Error handled in store
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary via-primary-dark to-background-navy px-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <Link href="/" className="inline-block">
            <h1 className="text-4xl font-black text-white">AGA</h1>
            <p className="text-white/70 text-sm mt-1">Africa Genius Alliance</p>
          </Link>
        </div>

        <AGACard variant="elevated" padding="lg">
          <h2 className="text-3xl font-black text-text-dark text-center mb-2">
            Welcome Back
          </h2>
          <p className="text-text-gray text-center mb-6">
            Sign in to continue your impact
          </p>

          {error && (
            <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-aga text-red-700 text-sm">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="block text-sm font-semibold text-text-dark mb-2">
                Email Address
              </label>
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  placeholder="you@example.com"
                  className="w-full pl-12 pr-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-text-dark mb-2">
                Password
              </label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  placeholder="••••••••"
                  className="w-full pl-12 pr-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
                />
              </div>
            </div>

            <div className="flex items-center justify-between text-sm">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  className="w-4 h-4 text-primary border-gray-300 rounded focus:ring-primary"
                />
                <span className="text-text-gray">Remember me</span>
              </label>
              <Link href="/auth/forgot-password" className="text-primary font-semibold hover:underline">
                Forgot password?
              </Link>
            </div>

            <AGAButton
              type="submit"
              variant="primary"
              size="lg"
              fullWidth
              loading={isLoading}
              rightIcon={!isLoading ? <ArrowRight className="w-5 h-5" /> : undefined}
            >
              Sign In
            </AGAButton>
          </form>

          <div className="mt-6 pt-6 border-t border-gray-200">
            <p className="text-center text-sm text-text-gray">
              Don't have an account?{' '}
              <Link href="/auth/signup" className="text-primary font-semibold hover:underline">
                Create account
              </Link>
            </p>
          </div>

          <div className="mt-4 text-center">
            <Link href="/" className="text-sm text-text-gray hover:text-primary transition-colors">
              ← Back to home
            </Link>
          </div>
        </AGACard>
      </div>
    </div>
  );
}
