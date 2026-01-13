import React from 'react';
import { Metadata } from 'next';
import { HeroSection } from '@/components/landing/HeroSection';
import { HowItWorksSection } from '@/components/landing/HowItWorksSection';
import { TwoPathsSection } from '@/components/landing/TwoPathsSection';
import { TransparencySection } from '@/components/landing/TransparencySection';
import { Footer } from '@/components/landing/Footer';

export const metadata: Metadata = {
  title: 'Africa Genius Alliance | Leadership Earned by Merit. Not Politics.',
  description: 'Leadership Earned by Merit. Not Politics. Join Africa\'s premier platform for identifying and supporting exceptional talent through transparent, merit-based recognition.',
  openGraph: {
    title: 'Africa Genius Alliance | Leadership Earned by Merit. Not Politics.',
    description: 'Join Africa\'s premier platform for identifying and supporting exceptional talent.',
    url: 'https://africageniusalliance.com',
  },
};

export default function LandingPage() {
  return (
    <main className="min-h-screen">
      <HeroSection />
      <HowItWorksSection />
      <TwoPathsSection />
      <TransparencySection />
      <Footer />
    </main>
  );
}
