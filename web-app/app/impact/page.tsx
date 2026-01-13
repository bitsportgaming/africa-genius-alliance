'use client';

import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { useAuth } from '@/lib/store/auth-store';
import { UserRole } from '@/types';
import { GeniusImpactView } from '@/components/impact/GeniusImpactView';
import { SupporterImpactView } from '@/components/impact/SupporterImpactView';

export default function ImpactPage() {
  const { user } = useAuth();
  const isGenius = user?.role === UserRole.GENIUS;

  return (
    <ProtectedRoute>
      <DashboardLayout>
        {isGenius ? <GeniusImpactView /> : <SupporterImpactView />}
      </DashboardLayout>
    </ProtectedRoute>
  );
}
