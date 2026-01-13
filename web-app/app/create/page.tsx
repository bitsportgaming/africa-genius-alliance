'use client';

import { useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { UserRole } from '@/types';
import { AGACard } from '@/components/ui';
import { FileText, Radio, Calendar, FileEdit } from 'lucide-react';
import { CreatePostTab } from '@/components/create/CreatePostTab';
import { GoLiveTab } from '@/components/create/GoLiveTab';
import { ScheduleLiveTab } from '@/components/create/ScheduleLiveTab';
import { ProposalTab } from '@/components/create/ProposalTab';

type TabType = 'post' | 'live' | 'schedule' | 'proposal';

export default function CreatePage() {
  const searchParams = useSearchParams();
  const initialTab = (searchParams.get('tab') as TabType) || 'post';
  const [activeTab, setActiveTab] = useState<TabType>(initialTab);

  const tabs = [
    {
      id: 'post' as TabType,
      label: 'Post Update',
      icon: FileText,
      description: 'Share text, images, or videos',
    },
    {
      id: 'live' as TabType,
      label: 'Go Live',
      icon: Radio,
      description: 'Stream live to your followers',
    },
    {
      id: 'schedule' as TabType,
      label: 'Schedule Live',
      icon: Calendar,
      description: 'Plan a future live stream',
    },
    {
      id: 'proposal' as TabType,
      label: 'Proposal',
      icon: FileEdit,
      description: 'Write your manifesto',
    },
  ];

  return (
    <ProtectedRoute requiredRole={UserRole.GENIUS}>
      <DashboardLayout>
        <div className="max-w-5xl mx-auto space-y-6">
          {/* Header */}
          <div>
            <h1 className="text-4xl font-black text-text-dark mb-2">
              Create Content
            </h1>
            <p className="text-lg text-text-gray">
              Share your vision, connect with supporters, and drive impact
            </p>
          </div>

          {/* Tab Navigation */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.id;

              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`relative p-6 rounded-aga border-2 transition-all duration-200 text-left ${
                    isActive
                      ? 'border-primary bg-primary/5 shadow-aga'
                      : 'border-gray-200 bg-white hover:border-primary/30 hover:shadow-sm'
                  }`}
                >
                  <div
                    className={`w-12 h-12 rounded-xl mb-3 flex items-center justify-center transition-all ${
                      isActive
                        ? 'bg-primary text-white'
                        : 'bg-gray-100 text-gray-600'
                    }`}
                  >
                    <Icon className="w-6 h-6" />
                  </div>
                  <h3
                    className={`font-bold mb-1 ${
                      isActive ? 'text-primary' : 'text-text-dark'
                    }`}
                  >
                    {tab.label}
                  </h3>
                  <p className="text-xs text-text-gray">{tab.description}</p>

                  {/* Active Indicator */}
                  {isActive && (
                    <div className="absolute bottom-0 left-0 right-0 h-1 bg-primary rounded-b-aga" />
                  )}
                </button>
              );
            })}
          </div>

          {/* Tab Content */}
          <AGACard variant="elevated" padding="lg">
            {activeTab === 'post' && <CreatePostTab />}
            {activeTab === 'live' && <GoLiveTab />}
            {activeTab === 'schedule' && <ScheduleLiveTab />}
            {activeTab === 'proposal' && <ProposalTab />}
          </AGACard>

          {/* Tips Section */}
          <AGACard variant="hero" padding="lg">
            <h3 className="font-bold text-text-dark mb-3">💡 Tips for Maximum Impact</h3>
            <ul className="space-y-2 text-sm text-text-gray">
              <li className="flex items-start gap-2">
                <span className="text-primary mt-0.5">•</span>
                <span>
                  <strong>Be Authentic:</strong> Share your genuine vision and connect with your values
                </span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-primary mt-0.5">•</span>
                <span>
                  <strong>Stay Consistent:</strong> Regular updates keep your supporters engaged
                </span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-primary mt-0.5">•</span>
                <span>
                  <strong>Use Multimedia:</strong> Images and videos get 3x more engagement
                </span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-primary mt-0.5">•</span>
                <span>
                  <strong>Go Live Often:</strong> Live streams build stronger connections with supporters
                </span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-primary mt-0.5">•</span>
                <span>
                  <strong>Track Metrics:</strong> Monitor your impact dashboard to see what resonates
                </span>
              </li>
            </ul>
          </AGACard>
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}
