import { useQuery } from '@tanstack/react-query';
import { statsAPI } from '../services/api';
import { Users, FileText, Vote, Star, TrendingUp, Clock } from 'lucide-react';
import { format } from 'date-fns';

export default function DashboardPage() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['adminStats'],
    queryFn: () => statsAPI.getDashboard(),
  });

  const stats = data?.data?.data;

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-aga-secondary"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-400">Failed to load dashboard stats</p>
      </div>
    );
  }

  const statCards = [
    { label: 'Total Users', value: stats?.totalUsers || 0, icon: Users, color: 'bg-blue-500' },
    { label: 'Geniuses', value: stats?.totalGeniuses || 0, icon: Star, color: 'bg-yellow-500' },
    { label: 'Total Posts', value: stats?.totalPosts || 0, icon: FileText, color: 'bg-green-500' },
    { label: 'Active Elections', value: stats?.activeElections || 0, icon: Vote, color: 'bg-purple-500' },
    { label: 'Pending Verification', value: stats?.pendingGeniuses || 0, icon: Clock, color: 'bg-orange-500' },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Dashboard</h1>
        <p className="text-slate-400">Overview of the AGA platform</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
        {statCards.map((stat) => (
          <div key={stat.label} className="stat-card">
            <div className={`stat-icon ${stat.color}`}>
              <stat.icon size={24} className="text-white" />
            </div>
            <div>
              <p className="stat-value">{stat.value.toLocaleString()}</p>
              <p className="stat-label">{stat.label}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Recent Users */}
      <div className="card">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-white">Recent Users</h2>
          <TrendingUp size={20} className="text-aga-secondary" />
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr>
                <th>User</th>
                <th>Email</th>
                <th>Role</th>
                <th>Joined</th>
              </tr>
            </thead>
            <tbody>
              {stats?.recentUsers?.map((user: any) => (
                <tr key={user.userId}>
                  <td>
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-aga-secondary/20 flex items-center justify-center">
                        <span className="text-sm text-aga-secondary">
                          {user.displayName?.charAt(0) || '?'}
                        </span>
                      </div>
                      <span className="font-medium text-white">{user.displayName}</span>
                    </div>
                  </td>
                  <td className="text-slate-400">{user.email}</td>
                  <td>
                    <span className={`badge ${
                      user.role === 'genius' ? 'badge-warning' :
                      user.role === 'admin' ? 'badge-info' : 'badge-success'
                    }`}>
                      {user.role}
                    </span>
                  </td>
                  <td className="text-slate-400">
                    {format(new Date(user.createdAt), 'MMM d, yyyy')}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

