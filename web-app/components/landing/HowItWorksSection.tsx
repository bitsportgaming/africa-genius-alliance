'use client';

import React from 'react';
import { AGACard } from '@/components/ui';
import { Lightbulb, Users, TrendingUp, Rocket } from 'lucide-react';

const steps = [
  {
    icon: Lightbulb,
    title: 'Geniuses Step Forward with Ideas',
    description: 'Africa\'s brightest minds share their vision, solutions, and leadership potential on a transparent platform.',
  },
  {
    icon: Users,
    title: 'Supporters Discover & Vote',
    description: 'Citizens discover leaders based on merit, vote on their ideas, and support those who align with their vision for Africa.',
  },
  {
    icon: TrendingUp,
    title: 'Impact is Ranked Transparently',
    description: 'Real-time rankings reflect genuine support, engagement, and measurable impact—not political connections or wealth.',
  },
  {
    icon: Rocket,
    title: 'Momentum Builds Through Action',
    description: 'Top-ranked geniuses gain visibility, resources, and opportunities to implement their ideas and lead real change.',
  },
];

export const HowItWorksSection: React.FC = () => {
  return (
    <section className="py-20 md:py-32 bg-background-cream">
      <div className="container mx-auto px-4">
        <div className="max-w-6xl mx-auto">
          {/* Section Header */}
          <div className="text-center mb-16">
            <h2 className="text-4xl md:text-5xl font-black text-text-dark mb-4">
              How AGA Works
            </h2>
            <p className="text-lg md:text-xl text-text-gray max-w-2xl mx-auto">
              A transparent, merit-based system for identifying and elevating Africa's next generation of leaders.
            </p>
          </div>

          {/* Steps Grid */}
          <div className="grid md:grid-cols-2 gap-8">
            {steps.map((step, index) => {
              const Icon = step.icon;
              return (
                <AGACard
                  key={index}
                  variant="elevated"
                  padding="lg"
                  className="relative group"
                >
                  {/* Step Number */}
                  <div className="absolute -top-4 -left-4 w-12 h-12 rounded-full bg-gradient-to-br from-secondary to-secondary-dark flex items-center justify-center text-white font-bold text-xl shadow-aga-lg">
                    {index + 1}
                  </div>

                  {/* Icon */}
                  <div className="mb-6 inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-primary/10 to-primary/5 group-hover:from-primary/20 group-hover:to-primary/10 transition-all duration-300">
                    <Icon className="w-8 h-8 text-primary" />
                  </div>

                  {/* Content */}
                  <h3 className="text-2xl font-bold text-text-dark mb-3">
                    {step.title}
                  </h3>
                  <p className="text-text-gray leading-relaxed">
                    {step.description}
                  </p>
                </AGACard>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
};
