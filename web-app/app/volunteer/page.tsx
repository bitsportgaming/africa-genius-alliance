'use client';

import { StaticPageLayout } from '@/components/layout/StaticPageLayout';
import { AGAButton } from '@/components/ui';
import { useState } from 'react';
import { Mail, User, MapPin, Briefcase, Heart, CheckCircle2 } from 'lucide-react';

export default function VolunteerPage() {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    country: '',
    skills: '',
    interest: '',
    availability: '',
    message: ''
  });
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // TODO: Implement actual form submission
    await new Promise(resolve => setTimeout(resolve, 1000));

    setSubmitted(true);
    setLoading(false);
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }));
  };

  if (submitted) {
    return (
      <StaticPageLayout title="Thank You!" subtitle="We'll be in touch soon">
        <div className="max-w-2xl mx-auto">
          <div className="bg-white rounded-2xl p-12 shadow-lg text-center">
            <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
              <CheckCircle2 className="w-12 h-12 text-green-600" />
            </div>
            <h2 className="text-3xl font-bold text-text-dark mb-4">
              Application Received!
            </h2>
            <p className="text-text-gray mb-8">
              Thank you for your interest in volunteering with Africa Genius Alliance.
              Our team will review your application and get back to you within 7 business days.
            </p>
            <AGAButton variant="primary" onClick={() => window.location.href = '/'}>
              Return to Home
            </AGAButton>
          </div>
        </div>
      </StaticPageLayout>
    );
  }

  return (
    <StaticPageLayout
      title="Volunteer With Us"
      subtitle="Help Us Build Africa's Future Together"
    >
      <div className="grid lg:grid-cols-2 gap-8">
        {/* Left Column - Info */}
        <div className="space-y-6">
          <div className="bg-gradient-to-br from-primary/10 to-secondary/10 rounded-2xl p-8">
            <h2 className="text-2xl font-bold text-text-dark mb-4">Why Volunteer?</h2>
            <p className="text-text-gray mb-6">
              Join a community of passionate Africans working to transform leadership selection
              and civic engagement across the continent. Your skills and time can make a real difference.
            </p>

            <div className="space-y-4">
              <div className="flex gap-3">
                <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0">
                  <Heart className="w-5 h-5 text-primary" />
                </div>
                <div>
                  <h3 className="font-bold text-text-dark mb-1">Make an Impact</h3>
                  <p className="text-text-gray text-sm">
                    Contribute to building transparent, merit-based leadership systems
                  </p>
                </div>
              </div>

              <div className="flex gap-3">
                <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0">
                  <Briefcase className="w-5 h-5 text-primary" />
                </div>
                <div>
                  <h3 className="font-bold text-text-dark mb-1">Gain Experience</h3>
                  <p className="text-text-gray text-sm">
                    Work on cutting-edge tech and civic engagement projects
                  </p>
                </div>
              </div>

              <div className="flex gap-3">
                <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0">
                  <MapPin className="w-5 h-5 text-primary" />
                </div>
                <div>
                  <h3 className="font-bold text-text-dark mb-1">Pan-African Network</h3>
                  <p className="text-text-gray text-sm">
                    Connect with like-minded changemakers across the continent
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-2xl p-8 shadow-lg">
            <h3 className="text-xl font-bold text-text-dark mb-4">Areas We Need Help</h3>
            <ul className="space-y-2 text-text-gray">
              <li className="flex gap-2">
                <span className="text-primary">•</span>
                <span>Software Development (Web, Mobile, Backend)</span>
              </li>
              <li className="flex gap-2">
                <span className="text-primary">•</span>
                <span>Community Management & Moderation</span>
              </li>
              <li className="flex gap-2">
                <span className="text-primary">•</span>
                <span>Content Creation & Social Media</span>
              </li>
              <li className="flex gap-2">
                <span className="text-primary">•</span>
                <span>Translation & Localization</span>
              </li>
              <li className="flex gap-2">
                <span className="text-primary">•</span>
                <span>Design (UI/UX, Graphics)</span>
              </li>
              <li className="flex gap-2">
                <span className="text-primary">•</span>
                <span>Data Analysis & Research</span>
              </li>
              <li className="flex gap-2">
                <span className="text-primary">•</span>
                <span>Legal & Compliance</span>
              </li>
              <li className="flex gap-2">
                <span className="text-primary">•</span>
                <span>Partnerships & Outreach</span>
              </li>
            </ul>
          </div>
        </div>

        {/* Right Column - Form */}
        <div className="bg-white rounded-2xl p-8 shadow-lg">
          <h2 className="text-2xl font-bold text-text-dark mb-6">Volunteer Application</h2>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-text-dark mb-2">
                <User className="w-4 h-4 inline mr-2" />
                Full Name *
              </label>
              <input
                type="text"
                name="fullName"
                value={formData.fullName}
                onChange={handleChange}
                required
                className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="Your full name"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-text-dark mb-2">
                <Mail className="w-4 h-4 inline mr-2" />
                Email Address *
              </label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                required
                className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="your.email@example.com"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-text-dark mb-2">
                <MapPin className="w-4 h-4 inline mr-2" />
                Country *
              </label>
              <input
                type="text"
                name="country"
                value={formData.country}
                onChange={handleChange}
                required
                className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="Your country"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-text-dark mb-2">
                Area of Interest *
              </label>
              <select
                name="interest"
                value={formData.interest}
                onChange={handleChange}
                required
                className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="">Select an area...</option>
                <option value="software-dev">Software Development</option>
                <option value="community">Community Management</option>
                <option value="content">Content Creation</option>
                <option value="translation">Translation</option>
                <option value="design">Design</option>
                <option value="data">Data Analysis</option>
                <option value="legal">Legal</option>
                <option value="partnerships">Partnerships</option>
                <option value="other">Other</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-dark mb-2">
                Skills & Experience
              </label>
              <textarea
                name="skills"
                value={formData.skills}
                onChange={handleChange}
                rows={3}
                className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="Tell us about your relevant skills and experience..."
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-text-dark mb-2">
                Availability
              </label>
              <select
                name="availability"
                value={formData.availability}
                onChange={handleChange}
                className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="">Select availability...</option>
                <option value="few-hours">A few hours per week</option>
                <option value="part-time">Part-time (10-20 hrs/week)</option>
                <option value="full-time">Full-time commitment</option>
                <option value="flexible">Flexible</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-dark mb-2">
                Why do you want to volunteer with AGA?
              </label>
              <textarea
                name="message"
                value={formData.message}
                onChange={handleChange}
                rows={4}
                className="w-full px-4 py-3 rounded-aga border border-gray-300 focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="Share your motivation and what you hope to contribute..."
              />
            </div>

            <AGAButton
              type="submit"
              variant="primary"
              fullWidth
              loading={loading}
            >
              {loading ? 'Submitting...' : 'Submit Application'}
            </AGAButton>

            <p className="text-xs text-text-gray text-center">
              By submitting this form, you agree to our volunteer terms and privacy policy.
            </p>
          </form>
        </div>
      </div>
    </StaticPageLayout>
  );
}
