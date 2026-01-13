'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { AGAButton } from '@/components/ui';
import { Mail, MapPin, ArrowRight } from 'lucide-react';

export const Footer: React.FC = () => {
  const [email, setEmail] = useState('');
  const [subscribed, setSubscribed] = useState(false);

  const handleSubscribe = (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Implement email subscription
    setSubscribed(true);
    setEmail('');
  };

  return (
    <footer className="bg-background-navy text-white">
      {/* CTA Section */}
      <div className="border-b border-white/10">
        <div className="container mx-auto px-4 py-16">
          <div className="max-w-4xl mx-auto text-center">
            <h2 className="text-3xl md:text-4xl font-black mb-4">
              Ready to Shape Africa's Future?
            </h2>
            <p className="text-white/80 text-lg mb-8">
              Join thousands of Africans building a merit-based future for our continent.
            </p>

            {/* Email Signup */}
            <form onSubmit={handleSubscribe} className="max-w-md mx-auto">
              {!subscribed ? (
                <div className="flex flex-col sm:flex-row gap-3">
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="Enter your email"
                    required
                    className="flex-1 px-6 py-3 rounded-aga text-text-dark focus:outline-none focus:ring-2 focus:ring-secondary"
                  />
                  <AGAButton
                    variant="secondary"
                    type="submit"
                    rightIcon={<ArrowRight className="w-5 h-5" />}
                  >
                    Join Beta
                  </AGAButton>
                </div>
              ) : (
                <div className="py-3 px-6 bg-green-500/20 border border-green-500/50 rounded-aga text-green-300">
                  Thank you! We'll be in touch soon.
                </div>
              )}
            </form>
          </div>
        </div>
      </div>

      {/* Footer Links */}
      <div className="container mx-auto px-4 py-12">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-12">
          {/* About */}
          <div>
            <h3 className="font-bold text-lg mb-4">About AGA</h3>
            <ul className="space-y-2 text-white/70">
              <li>
                <Link href="/about" className="hover:text-secondary transition-colors">
                  Our Story
                </Link>
              </li>
              <li>
                <Link href="/mission" className="hover:text-secondary transition-colors">
                  Mission
                </Link>
              </li>
              <li>
                <Link href="/team" className="hover:text-secondary transition-colors">
                  Team
                </Link>
              </li>
              <li>
                <Link href="/careers" className="hover:text-secondary transition-colors">
                  Careers
                </Link>
              </li>
            </ul>
          </div>

          {/* Product */}
          <div>
            <h3 className="font-bold text-lg mb-4">Product</h3>
            <ul className="space-y-2 text-white/70">
              <li>
                <Link href="/explore" className="hover:text-secondary transition-colors">
                  Explore Geniuses
                </Link>
              </li>
              <li>
                <Link href="/how-it-works" className="hover:text-secondary transition-colors">
                  How It Works
                </Link>
              </li>
              <li>
                <Link href="/impact" className="hover:text-secondary transition-colors">
                  Impact
                </Link>
              </li>
              <li>
                <Link href="/blog" className="hover:text-secondary transition-colors">
                  Blog
                </Link>
              </li>
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h3 className="font-bold text-lg mb-4">Legal</h3>
            <ul className="space-y-2 text-white/70">
              <li>
                <Link href="/privacy" className="hover:text-secondary transition-colors">
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link href="/terms" className="hover:text-secondary transition-colors">
                  Terms of Service
                </Link>
              </li>
              <li>
                <Link href="/guidelines" className="hover:text-secondary transition-colors">
                  Community Guidelines
                </Link>
              </li>
              <li>
                <Link href="/cookies" className="hover:text-secondary transition-colors">
                  Cookie Policy
                </Link>
              </li>
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h3 className="font-bold text-lg mb-4">Contact</h3>
            <ul className="space-y-3 text-white/70">
              <li className="flex items-start gap-2">
                <Mail className="w-5 h-5 mt-0.5 flex-shrink-0" />
                <a href="mailto:hello@aga.africa" className="hover:text-secondary transition-colors">
                  hello@aga.africa
                </a>
              </li>
              <li className="flex items-start gap-2">
                <MapPin className="w-5 h-5 mt-0.5 flex-shrink-0" />
                <span>Pan-African Initiative</span>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="pt-8 border-t border-white/10 flex flex-col md:flex-row justify-between items-center gap-4">
          <div className="text-white/60 text-sm">
            © 2026 Africa Genius Alliance. All rights reserved.
          </div>
          <div className="flex gap-6">
            {/* Social Media Links - Placeholder */}
            {['Twitter', 'LinkedIn', 'Instagram', 'YouTube'].map((platform) => (
              <a
                key={platform}
                href="#"
                className="text-white/60 hover:text-secondary transition-colors text-sm"
              >
                {platform}
              </a>
            ))}
          </div>
        </div>
      </div>
    </footer>
  );
};
