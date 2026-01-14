'use client';

import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { AGACard, AGAButton } from '@/components/ui';
import { Megaphone, Target, TrendingUp, Users, Calendar, DollarSign, BarChart3 } from 'lucide-react';

export default function CampaignPage() {
  // Mock campaign data - replace with actual API calls
  const activeCampaigns = [
    {
      id: '1',
      title: 'Youth Empowerment Initiative 2026',
      status: 'active',
      goal: 50000,
      raised: 32500,
      supporters: 234,
      endsIn: '14 days',
      category: 'Education'
    },
    {
      id: '2',
      title: 'Clean Water for Rural Communities',
      status: 'active',
      goal: 100000,
      raised: 78900,
      supporters: 456,
      endsIn: '21 days',
      category: 'Infrastructure'
    }
  ];

  return (
    <ProtectedRoute>
      <DashboardLayout>
        <div className="space-y-8">
          {/* Header */}
          <div>
            <h1 className="text-4xl font-black text-text-dark mb-2">Campaigns</h1>
            <p className="text-lg text-text-gray">
              Create and manage fundraising campaigns for your initiatives
            </p>
          </div>

          {/* Quick Stats */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <AGACard variant="elevated" padding="lg">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                  <Megaphone className="w-6 h-6 text-primary" />
                </div>
                <div>
                  <h3 className="text-3xl font-black text-text-dark">2</h3>
                  <p className="text-sm text-text-gray mt-1">Active Campaigns</p>
                </div>
              </div>
            </AGACard>

            <AGACard variant="elevated" padding="lg">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center">
                  <DollarSign className="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <h3 className="text-3xl font-black text-text-dark">$111K</h3>
                  <p className="text-sm text-text-gray mt-1">Total Raised</p>
                </div>
              </div>
            </AGACard>

            <AGACard variant="elevated" padding="lg">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-secondary/10 flex items-center justify-center">
                  <Users className="w-6 h-6 text-secondary" />
                </div>
                <div>
                  <h3 className="text-3xl font-black text-text-dark">690</h3>
                  <p className="text-sm text-text-gray mt-1">Total Supporters</p>
                </div>
              </div>
            </AGACard>

            <AGACard variant="elevated" padding="lg">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-yellow-500/10 flex items-center justify-center">
                  <TrendingUp className="w-6 h-6 text-yellow-600" />
                </div>
                <div>
                  <h3 className="text-3xl font-black text-text-dark">74%</h3>
                  <p className="text-sm text-text-gray mt-1">Avg. Goal Reached</p>
                </div>
              </div>
            </AGACard>
          </div>

          {/* Create Campaign CTA */}
          <AGACard variant="hero" padding="lg">
            <div className="flex flex-col md:flex-row items-center justify-between gap-6">
              <div>
                <h2 className="text-2xl font-bold text-text-dark mb-2">
                  Launch Your Next Campaign
                </h2>
                <p className="text-text-gray">
                  Turn your vision into reality with transparent, community-backed funding
                </p>
              </div>
              <AGAButton variant="primary" size="lg">
                <Target className="w-5 h-5 mr-2" />
                Create Campaign
              </AGAButton>
            </div>
          </AGACard>

          {/* Active Campaigns */}
          <section>
            <h2 className="text-2xl font-bold text-text-dark mb-4">Active Campaigns</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {activeCampaigns.map((campaign) => {
                const progress = (campaign.raised / campaign.goal) * 100;
                return (
                  <AGACard key={campaign.id} variant="elevated" padding="lg" hoverable>
                    <div className="space-y-4">
                      {/* Header */}
                      <div className="flex items-start justify-between">
                        <div>
                          <span className="inline-block px-3 py-1 bg-primary/10 text-primary text-xs font-bold rounded-full mb-2">
                            {campaign.category}
                          </span>
                          <h3 className="text-xl font-bold text-text-dark">
                            {campaign.title}
                          </h3>
                        </div>
                        <span className="px-3 py-1 bg-green-100 text-green-700 text-xs font-bold rounded-full">
                          {campaign.status.toUpperCase()}
                        </span>
                      </div>

                      {/* Progress */}
                      <div>
                        <div className="flex justify-between text-sm mb-2">
                          <span className="font-semibold text-text-dark">
                            ${campaign.raised.toLocaleString()} raised
                          </span>
                          <span className="text-text-gray">
                            ${campaign.goal.toLocaleString()} goal
                          </span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-3">
                          <div
                            className="bg-gradient-to-r from-primary to-secondary h-3 rounded-full transition-all"
                            style={{ width: `${Math.min(progress, 100)}%` }}
                          />
                        </div>
                        <p className="text-sm text-text-gray mt-2">
                          {progress.toFixed(0)}% funded
                        </p>
                      </div>

                      {/* Stats */}
                      <div className="flex items-center justify-between text-sm text-text-gray">
                        <div className="flex items-center gap-1">
                          <Users className="w-4 h-4" />
                          <span>{campaign.supporters} supporters</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Calendar className="w-4 h-4" />
                          <span>{campaign.endsIn} left</span>
                        </div>
                      </div>

                      {/* Actions */}
                      <div className="flex gap-3 pt-2">
                        <AGAButton variant="primary" size="sm" fullWidth>
                          <BarChart3 className="w-4 h-4 mr-2" />
                          View Analytics
                        </AGAButton>
                        <AGAButton variant="outline" size="sm" fullWidth>
                          Manage
                        </AGAButton>
                      </div>
                    </div>
                  </AGACard>
                );
              })}
            </div>
          </section>

          {/* Past Campaigns */}
          <section>
            <h2 className="text-2xl font-bold text-text-dark mb-4">Past Campaigns</h2>
            <AGACard variant="elevated" padding="lg">
              <div className="text-center py-12">
                <Megaphone className="w-16 h-16 text-gray-300 mx-auto mb-4" />
                <h3 className="text-lg font-bold text-text-dark mb-2">
                  No past campaigns yet
                </h3>
                <p className="text-text-gray">
                  Your completed campaigns will appear here
                </p>
              </div>
            </AGACard>
          </section>
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}
