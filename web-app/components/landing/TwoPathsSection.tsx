'use client';

import React from 'react';
import Link from 'next/link';
import { AGACard, AGAButton } from '@/components/ui';
import { Crown, Heart, Mic, Vote, BarChart, Eye, ArrowRight } from 'lucide-react';

export const TwoPathsSection: React.FC = () => {
  return (
    <section className="py-20 md:py-32 bg-white">
      <div className="container mx-auto px-4">
        <div className="max-w-6xl mx-auto">
          {/* Section Header */}
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-black text-text-dark mb-4">
              Two Ways to Make an Impact
            </h2>
            <p className="text-lg md:text-xl text-text-gray max-w-2xl mx-auto">
              Whether you're ready to lead or want to support transformative change, AGA has a path for you.
            </p>
          </div>

          {/* Two Paths Grid */}
          <div className="grid md:grid-cols-2 gap-8">
            {/* Genius Path */}
            <AGACard
              variant="hero"
              padding="lg"
              className="border-2 border-secondary/30 hover:border-secondary/60 transition-all"
            >
              <div className="flex items-center gap-3 mb-6">
                <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-secondary to-secondary-dark flex items-center justify-center">
                  <Crown className="w-7 h-7 text-white" />
                </div>
                <h3 className="text-3xl font-black text-text-dark">For Geniuses</h3>
              </div>

              <p className="text-lg text-text-gray mb-8">
                Step forward as a leader. Share your vision, build support, and drive the change Africa needs.
              </p>

              <div className="space-y-4 mb-8">
                {[
                  { icon: Mic, text: 'Lead with ideas and vision' },
                  { icon: Vote, text: 'Post your manifesto & go live' },
                  { icon: BarChart, text: 'Track your impact in real-time' },
                  { icon: Eye, text: 'Build trust through transparency' },
                ].map((item, index) => {
                  const Icon = item.icon;
                  return (
                    <div key={index} className="flex items-start gap-3">
                      <div className="flex-shrink-0 w-6 h-6 rounded-full bg-secondary/20 flex items-center justify-center mt-0.5">
                        <Icon className="w-4 h-4 text-secondary-dark" />
                      </div>
                      <span className="text-text-dark">{item.text}</span>
                    </div>
                  );
                })}
              </div>

              <Link href="/auth/signup?role=genius">
                <AGAButton
                  variant="secondary"
                  fullWidth
                  rightIcon={<ArrowRight className="w-5 h-5" />}
                >
                  Become a Genius
                </AGAButton>
              </Link>
            </AGACard>

            {/* Supporter Path */}
            <AGACard
              variant="hero"
              padding="lg"
              className="border-2 border-primary/30 hover:border-primary/60 transition-all"
            >
              <div className="flex items-center gap-3 mb-6">
                <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center">
                  <Heart className="w-7 h-7 text-white" />
                </div>
                <h3 className="text-3xl font-black text-text-dark">For Supporters</h3>
              </div>

              <p className="text-lg text-text-gray mb-8">
                Discover and support Africa's brightest minds. Your voice shapes who rises to leadership.
              </p>

              <div className="space-y-4 mb-8">
                {[
                  { icon: Eye, text: 'Discover leaders based on merit' },
                  { icon: Vote, text: 'Vote on ideas and manifestos' },
                  { icon: BarChart, text: 'Follow progress and impact' },
                  { icon: Heart, text: 'Shape the future of leadership' },
                ].map((item, index) => {
                  const Icon = item.icon;
                  return (
                    <div key={index} className="flex items-start gap-3">
                      <div className="flex-shrink-0 w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center mt-0.5">
                        <Icon className="w-4 h-4 text-primary-dark" />
                      </div>
                      <span className="text-text-dark">{item.text}</span>
                    </div>
                  );
                })}
              </div>

              <Link href="/auth/signup?role=supporter">
                <AGAButton
                  variant="primary"
                  fullWidth
                  rightIcon={<ArrowRight className="w-5 h-5" />}
                >
                  Become a Supporter
                </AGAButton>
              </Link>
            </AGACard>
          </div>
        </div>
      </div>
    </section>
  );
};
