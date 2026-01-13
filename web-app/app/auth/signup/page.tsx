'use client';

import { useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { useAuth } from '@/lib/store/auth-store';
import { AGAButton, AGACard } from '@/components/ui';
import Link from 'next/link';
import { Mail, Lock, User, Globe, Crown, Heart } from 'lucide-react';

export default function SignUpPage() {
  const searchParams = useSearchParams();
  const roleParam = searchParams.get('role');

  const [step, setStep] = useState<'role' | 'details'>('role');
  const [role, setRole] = useState<'genius' | 'regular'>(
    roleParam === 'genius' ? 'genius' : roleParam === 'supporter' ? 'regular' : 'regular'
  );

  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
    displayName: '',
    country: '',
    bio: '',
  });

  const { register, isLoading, error, clearError } = useAuth();
  const router = useRouter();

  const handleRoleSelect = (selectedRole: 'genius' | 'regular') => {
    setRole(selectedRole);
    setStep('details');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();

    if (formData.password !== formData.confirmPassword) {
      alert('Passwords do not match');
      return;
    }

    try {
      await register({
        username: formData.username,
        email: formData.email,
        password: formData.password,
        displayName: formData.displayName,
        role,
        country: formData.country || undefined,
        bio: formData.bio || undefined,
      });

      router.push('/dashboard');
    } catch (err) {
      // Error handled in store
    }
  };

  if (step === 'role') {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#052e24] via-primary-dark to-[#041f19] px-4 py-12 relative overflow-hidden">
        {/* Background decorative elements */}
        <div className="absolute top-0 left-0 w-[500px] h-[500px] bg-secondary/10 rounded-full blur-[120px] -translate-x-1/2 -translate-y-1/2" />
        <div className="absolute bottom-0 right-0 w-[400px] h-[400px] bg-primary-light/10 rounded-full blur-[100px] translate-x-1/2 translate-y-1/2" />

        <div className="w-full max-w-4xl relative z-10">
          <div className="text-center mb-12">
            <Link href="/" className="inline-block mb-6 group">
              <h1 className="text-5xl font-black text-white tracking-tight group-hover:text-secondary transition-colors">AGA</h1>
            </Link>
            <h2 className="text-4xl font-black text-white mb-3 tracking-tight">Choose Your Path</h2>
            <p className="text-white/70 text-lg font-medium">How do you want to make an impact?</p>
          </div>

          <div className="grid md:grid-cols-2 gap-8">
            {/* Genius Card */}
            <div
              onClick={() => handleRoleSelect('genius')}
              className="cursor-pointer group relative"
            >
              {/* Glow effect on hover */}
              <div className="absolute inset-0 bg-gradient-to-br from-secondary/40 to-secondary-dark/40 rounded-3xl blur-xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 scale-95" />

              <div className="relative bg-white/[0.08] backdrop-blur-xl rounded-3xl p-8 border border-white/10 group-hover:border-secondary/50 transition-all duration-300 group-hover:translate-y-[-4px] group-hover:shadow-[0_20px_40px_rgba(245,158,11,0.2)]">
                {/* Icon */}
                <div className="w-20 h-20 mx-auto mb-6 rounded-2xl bg-gradient-to-br from-secondary via-secondary to-secondary-dark flex items-center justify-center shadow-[0_8px_32px_rgba(245,158,11,0.4)] group-hover:shadow-[0_12px_40px_rgba(245,158,11,0.5)] group-hover:scale-110 transition-all duration-300">
                  <Crown className="w-10 h-10 text-white drop-shadow-lg" />
                </div>

                {/* Content */}
                <h3 className="text-2xl font-black text-white mb-3 text-center">Be a Genius</h3>
                <p className="text-white/60 mb-6 leading-relaxed text-center text-sm">
                  Lead with ideas. Share your vision. Drive transformative change across Africa through merit and impact.
                </p>

                {/* Features */}
                <ul className="space-y-3 mb-8">
                  {['Post your manifesto', 'Go live with followers', 'Track your impact', 'Build your movement'].map(
                    (item) => (
                      <li key={item} className="flex items-center gap-3 text-white/80 text-sm">
                        <div className="w-2 h-2 rounded-full bg-secondary shadow-[0_0_8px_rgba(245,158,11,0.6)]" />
                        <span>{item}</span>
                      </li>
                    )
                  )}
                </ul>

                {/* Button */}
                <button className="w-full py-4 px-6 bg-gradient-to-r from-secondary to-secondary-dark text-white font-bold rounded-xl shadow-[0_4px_20px_rgba(245,158,11,0.4)] hover:shadow-[0_6px_24px_rgba(245,158,11,0.5)] transition-all duration-300 hover:translate-y-[-2px]">
                  Continue as Genius
                </button>
              </div>
            </div>

            {/* Supporter Card */}
            <div
              onClick={() => handleRoleSelect('regular')}
              className="cursor-pointer group relative"
            >
              {/* Glow effect on hover */}
              <div className="absolute inset-0 bg-gradient-to-br from-primary-light/30 to-primary/30 rounded-3xl blur-xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 scale-95" />

              <div className="relative bg-white/[0.08] backdrop-blur-xl rounded-3xl p-8 border border-white/10 group-hover:border-primary-light/50 transition-all duration-300 group-hover:translate-y-[-4px] group-hover:shadow-[0_20px_40px_rgba(16,185,129,0.2)]">
                {/* Icon */}
                <div className="w-20 h-20 mx-auto mb-6 rounded-2xl bg-gradient-to-br from-primary-light via-primary to-primary-dark flex items-center justify-center shadow-[0_8px_32px_rgba(16,185,129,0.4)] group-hover:shadow-[0_12px_40px_rgba(16,185,129,0.5)] group-hover:scale-110 transition-all duration-300">
                  <Heart className="w-10 h-10 text-white drop-shadow-lg" />
                </div>

                {/* Content */}
                <h3 className="text-2xl font-black text-white mb-3 text-center">Be a Supporter</h3>
                <p className="text-white/60 mb-6 leading-relaxed text-center text-sm">
                  Discover leaders. Vote on merit. Support Africa's brightest minds and shape the future of leadership.
                </p>

                {/* Features */}
                <ul className="space-y-3 mb-8">
                  {['Discover verified geniuses', 'Vote on ideas', 'Track their impact', 'Join the movement'].map(
                    (item) => (
                      <li key={item} className="flex items-center gap-3 text-white/80 text-sm">
                        <div className="w-2 h-2 rounded-full bg-primary-light shadow-[0_0_8px_rgba(16,185,129,0.6)]" />
                        <span>{item}</span>
                      </li>
                    )
                  )}
                </ul>

                {/* Button */}
                <button className="w-full py-4 px-6 bg-gradient-to-r from-primary to-primary-dark text-white font-bold rounded-xl shadow-[0_4px_20px_rgba(10,77,60,0.4)] hover:shadow-[0_6px_24px_rgba(10,77,60,0.5)] transition-all duration-300 hover:translate-y-[-2px] border border-primary-light/20">
                  Continue as Supporter
                </button>
              </div>
            </div>
          </div>

          <p className="text-center mt-10 text-white/60">
            Already have an account?{' '}
            <Link href="/auth/login" className="text-secondary font-bold hover:text-secondary-light underline underline-offset-4 transition-colors">
              Sign in
            </Link>
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary via-primary-dark to-background-navy px-4 py-12">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <Link href="/" className="inline-block">
            <h1 className="text-4xl font-black text-white">AGA</h1>
          </Link>
        </div>

        <AGACard variant="elevated" padding="lg">
          <div className="flex items-center gap-3 mb-6">
            {role === 'genius' ? (
              <>
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-secondary to-secondary-dark flex items-center justify-center">
                  <Crown className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h2 className="text-2xl font-black text-text-dark">Genius Account</h2>
                  <p className="text-sm text-text-gray">Lead with impact</p>
                </div>
              </>
            ) : (
              <>
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center">
                  <Heart className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h2 className="text-2xl font-black text-text-dark">Supporter Account</h2>
                  <p className="text-sm text-text-gray">Shape the future</p>
                </div>
              </>
            )}
          </div>

          {error && (
            <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-aga text-red-700 text-sm">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-semibold text-text-dark mb-2">Username</label>
                <input
                  type="text"
                  value={formData.username}
                  onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                  required
                  placeholder="username"
                  className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
                />
              </div>
              <div>
                <label className="block text-sm font-semibold text-text-dark mb-2">Display Name</label>
                <input
                  type="text"
                  value={formData.displayName}
                  onChange={(e) => setFormData({ ...formData, displayName: e.target.value })}
                  required
                  placeholder="John Doe"
                  className="w-full px-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-text-dark mb-2">Email</label>
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  required
                  placeholder="you@example.com"
                  className="w-full pl-12 pr-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-text-dark mb-2">Country</label>
              <div className="relative">
                <Globe className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  value={formData.country}
                  onChange={(e) => setFormData({ ...formData, country: e.target.value })}
                  placeholder="e.g., Nigeria"
                  className="w-full pl-12 pr-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-text-dark mb-2">Password</label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="password"
                  value={formData.password}
                  onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                  required
                  placeholder="••••••••"
                  className="w-full pl-12 pr-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-text-dark mb-2">Confirm Password</label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="password"
                  value={formData.confirmPassword}
                  onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                  required
                  placeholder="••••••••"
                  className="w-full pl-12 pr-4 py-3 rounded-aga border border-gray-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition-all"
                />
              </div>
            </div>

            <AGAButton
              type="submit"
              variant={role === 'genius' ? 'secondary' : 'primary'}
              size="lg"
              fullWidth
              loading={isLoading}
            >
              Create Account
            </AGAButton>
          </form>

          <div className="mt-6 pt-6 border-t border-gray-200 space-y-3">
            <button
              type="button"
              onClick={() => setStep('role')}
              className="text-sm text-text-gray hover:text-primary transition-colors"
            >
              ← Change role
            </button>
            <p className="text-center text-sm text-text-gray">
              Already have an account?{' '}
              <Link href="/auth/login" className="text-primary font-semibold hover:underline">
                Sign in
              </Link>
            </p>
          </div>
        </AGACard>
      </div>
    </div>
  );
}
