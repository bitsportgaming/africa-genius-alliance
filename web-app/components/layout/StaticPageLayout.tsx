'use client';

import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { Footer } from '@/components/landing/Footer';

interface StaticPageLayoutProps {
  children: React.ReactNode;
  title: string;
  subtitle?: string;
}

export function StaticPageLayout({ children, title, subtitle }: StaticPageLayoutProps) {
  return (
    <div className="min-h-screen bg-background-cream">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-40">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between h-16">
            <Link href="/" className="flex items-center gap-2">
              <div className="w-10 h-10 rounded-xl bg-gradient-primary flex items-center justify-center">
                <span className="text-white font-black text-xl">A</span>
              </div>
              <span className="text-2xl font-black text-primary">AGA</span>
            </Link>
            <Link href="/" className="flex items-center gap-2 text-text-gray hover:text-text-dark transition-colors">
              <ArrowLeft className="w-5 h-5" />
              <span>Back to Home</span>
            </Link>
          </div>
        </div>
      </header>

      {/* Hero */}
      <div className="bg-gradient-to-br from-primary to-primary-dark py-16">
        <div className="container mx-auto px-4 text-center">
          <h1 className="text-4xl md:text-5xl font-black text-white mb-4">{title}</h1>
          {subtitle && <p className="text-xl text-white/80 max-w-2xl mx-auto">{subtitle}</p>}
        </div>
      </div>

      {/* Content */}
      <main className="container mx-auto px-4 py-12">
        <div className="max-w-4xl mx-auto prose prose-lg">
          {children}
        </div>
      </main>

      {/* Footer */}
      <Footer />
    </div>
  );
}

