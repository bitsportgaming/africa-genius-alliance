'use client';

import React from 'react';
import { AGACard } from '@/components/ui';
import { Shield, TrendingUp, Lock, CheckCircle } from 'lucide-react';

export const TransparencySection: React.FC = () => {
  const features = [
    {
      icon: TrendingUp,
      title: 'Merit-Based Ranking',
      description: 'Rankings reflect genuine support, votes, and measurable impact—not money or political connections.',
    },
    {
      icon: Shield,
      title: 'Open Metrics',
      description: 'Every vote, follower, and engagement is tracked and displayed publicly. No hidden algorithms.',
    },
    {
      icon: Lock,
      title: 'Anti-Manipulation',
      description: 'Built-in safeguards prevent vote manipulation, bot activity, and artificial inflation.',
    },
    {
      icon: CheckCircle,
      title: 'Blockchain-Ready',
      description: 'Architecture designed for future blockchain integration to ensure permanent transparency.',
    },
  ];

  return (
    <section className="py-20 md:py-32 bg-gradient-to-br from-primary/5 to-primary/10">
      <div className="container mx-auto px-4">
        <div className="max-w-6xl mx-auto">
          {/* Section Header */}
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-black text-text-dark mb-4">
              Transparency & Trust
            </h2>
            <p className="text-lg md:text-xl text-text-gray max-w-3xl mx-auto">
              AGA is built on radical transparency. Every metric is public, every vote counts, and every leader earns their position through measurable merit.
            </p>
          </div>

          {/* Features Grid */}
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <AGACard
                  key={index}
                  variant="elevated"
                  padding="lg"
                  className="text-center group hover:scale-105"
                >
                  <div className="mb-4 inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-primary to-primary-dark group-hover:shadow-aga-lg transition-all duration-300">
                    <Icon className="w-8 h-8 text-white" />
                  </div>
                  <h3 className="text-xl font-bold text-text-dark mb-2">
                    {feature.title}
                  </h3>
                  <p className="text-text-gray text-sm leading-relaxed">
                    {feature.description}
                  </p>
                </AGACard>
              );
            })}
          </div>

          {/* Trust Statement */}
          <AGACard variant="hero" padding="lg" className="mt-12 text-center">
            <blockquote className="text-xl md:text-2xl font-semibold text-text-dark italic">
              "Leadership should never be a mystery. At AGA, you see exactly who supports each genius, how they rank, and why they rise."
            </blockquote>
            <p className="mt-4 text-text-gray">— AGA Core Philosophy</p>
          </AGACard>
        </div>
      </div>
    </section>
  );
};
