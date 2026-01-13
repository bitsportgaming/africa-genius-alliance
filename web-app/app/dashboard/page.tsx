'use client';

import { useAuth } from '@/lib/store/auth-store';
import { UserRole } from '@/types';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { GeniusDashboard } from '@/components/dashboard/GeniusDashboard';
import { SupporterDashboard } from '@/components/dashboard/SupporterDashboard';

export default function DashboardPage() {
  const { user } = useAuth();
  const isGenius = user?.role === UserRole.GENIUS;

  return (
    <ProtectedRoute>
      <DashboardLayout>
        {isGenius ? <GeniusDashboard /> : <SupporterDashboard />}
      </DashboardLayout>
    </ProtectedRoute>
  );
}
