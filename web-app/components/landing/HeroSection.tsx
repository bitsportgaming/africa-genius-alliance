'use client';

import React from 'react';
import Link from 'next/link';
import { AGAButton } from '@/components/ui';
import { ArrowRight, Sparkles } from 'lucide-react';

export const HeroSection: React.FC = () => {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-gradient-to-br from-primary via-primary-dark to-background-navy">
      {/* Animated background elements */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-20 left-20 w-64 h-64 bg-secondary rounded-full blur-3xl animate-pulse" />
        <div className="absolute bottom-20 right-20 w-96 h-96 bg-primary-light rounded-full blur-3xl animate-pulse" style={{ animationDelay: '1s' }} />
      </div>

      <div className="relative z-10 container mx-auto px-4 py-20 md:py-32">
        <div className="max-w-5xl mx-auto text-center">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 text-white mb-8">
            <Sparkles className="w-4 h-4" />
            <span className="text-sm font-medium">Building Africa's Future Through Merit</span>
          </div>

          {/* Main Headline */}
          <h1 className="text-5xl md:text-7xl font-black text-white mb-6 leading-tight">
            Leadership Earned by Merit.
            <br />
            <span className="bg-gradient-to-r from-secondary to-secondary-light bg-clip-text text-transparent">
              Not Politics.
            </span>
          </h1>

          {/* Subtext */}
          <p className="text-xl md:text-2xl text-white/90 mb-12 max-w-3xl mx-auto leading-relaxed">
            Africa Genius Alliance identifies, elevates, and supports Africa's most capable minds
            through transparency, ideas, and measurable impact.
          </p>

          {/* CTAs */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link href="/auth/signup">
              <AGAButton
                variant="secondary"
                size="lg"
                rightIcon={<ArrowRight className="w-5 h-5" />}
                className="min-w-[200px]"
              >
                Join the Beta
              </AGAButton>
            </Link>
            <Link href="/explore">
              <AGAButton
                variant="outline"
                size="lg"
                className="min-w-[200px] !border-white !text-white hover:!bg-white hover:!text-primary"
              >
                Explore Geniuses
              </AGAButton>
            </Link>
          </div>

          {/* Stats */}
          <div className="mt-16 grid grid-cols-2 md:grid-cols-4 gap-8 max-w-4xl mx-auto">
            {[
              { value: '10,000+', label: 'Active Users' },
              { value: '500+', label: 'Verified Geniuses' },
              { value: '50+', label: 'Countries' },
              { value: '1M+', label: 'Votes Cast' },
            ].map((stat, index) => (
              <div key={index} className="text-center">
                <div className="text-3xl md:text-4xl font-bold text-white mb-1">
                  {stat.value}
                </div>
                <div className="text-sm text-white/70">
                  {stat.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Bottom fade */}
      <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-background-cream to-transparent" />
    </section>
  );
};
