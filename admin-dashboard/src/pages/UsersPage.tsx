import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { usersAPI, User } from '../services/api';
import { Search, Check, X, Shield, Ban, UserCheck } from 'lucide-react';
import { format } from 'date-fns';

export default function UsersPage() {
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [page, setPage] = useState(1);
  const [_selectedUser, setSelectedUser] = useState<User | null>(null);
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['adminUsers', page, search, roleFilter, statusFilter],
    queryFn: () => usersAPI.getAll({ page, limit: 20, search, role: roleFilter, status: statusFilter }),
  });

  const updateMutation = useMutation({
    mutationFn: ({ userId, data }: { userId: string; data: Partial<User> }) =>
      usersAPI.update(userId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminUsers'] });
      setSelectedUser(null);
    },
  });

  const users = data?.data?.data || [];
  const pagination = data?.data?.pagination;

  const handleAction = (user: User, action: string) => {
    switch (action) {
      case 'verify':
        updateMutation.mutate({ userId: user.userId, data: { isVerified: true } });
        break;
      case 'suspend':
        updateMutation.mutate({ userId: user.userId, data: { status: 'suspended' } });
        break;
      case 'activate':
        updateMutation.mutate({ userId: user.userId, data: { status: 'active' } });
        break;
      case 'makeAdmin':
        updateMutation.mutate({ userId: user.userId, data: { role: 'admin' } });
        break;
      case 'removeAdmin':
        updateMutation.mutate({ userId: user.userId, data: { role: 'regular' } });
        break;
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white">Users</h1>
          <p className="text-slate-400">Manage platform users</p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-4">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" size={18} />
          <input
            type="text"
            placeholder="Search users..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10"
          />
        </div>
        <select value={roleFilter} onChange={(e) => setRoleFilter(e.target.value)} className="min-w-[150px]">
          <option value="">All Roles</option>
          <option value="regular">Regular</option>
          <option value="genius">Genius</option>
          <option value="admin">Admin</option>
        </select>
        <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="min-w-[150px]">
          <option value="">All Status</option>
          <option value="active">Active</option>
          <option value="suspended">Suspended</option>
          <option value="banned">Banned</option>
        </select>
      </div>

      {/* Users Table */}
      <div className="table-container bg-slate-800">
        <table>
          <thead>
            <tr>
              <th>User</th>
              <th>Email</th>
              <th>Role</th>
              <th>Status</th>
              <th>Verified</th>
              <th>Joined</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan={7} className="text-center py-8">Loading...</td></tr>
            ) : users.length === 0 ? (
              <tr><td colSpan={7} className="text-center py-8 text-slate-400">No users found</td></tr>
            ) : (
              users.map((user: User) => (
                <tr key={user.userId}>
                  <td>
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-aga-secondary/20 flex items-center justify-center overflow-hidden">
                        {user.profileImageURL ? (
                          <img src={user.profileImageURL} alt="" className="w-full h-full object-cover" />
                        ) : (
                          <span className="text-sm text-aga-secondary">{user.displayName?.charAt(0)}</span>
                        )}
                      </div>
                      <div>
                        <p className="font-medium text-white">{user.displayName}</p>
                        <p className="text-xs text-slate-400">@{user.username}</p>
                      </div>
                    </div>
                  </td>
                  <td className="text-slate-400">{user.email}</td>
                  <td><span className={`badge ${user.role === 'genius' ? 'badge-warning' : user.role === 'admin' ? 'badge-info' : 'badge-success'}`}>{user.role}</span></td>
                  <td><span className={`badge ${user.status === 'active' ? 'badge-success' : user.status === 'suspended' ? 'badge-warning' : 'badge-danger'}`}>{user.status}</span></td>
                  <td>{user.isVerified ? <Check className="text-green-400" size={18} /> : <X className="text-slate-500" size={18} />}</td>
                  <td className="text-slate-400">{format(new Date(user.createdAt), 'MMM d, yyyy')}</td>
                  <td>
                    <div className="flex gap-2">
                      {!user.isVerified && <button onClick={() => handleAction(user, 'verify')} className="p-1 hover:bg-slate-700 rounded" title="Verify"><UserCheck size={16} className="text-green-400" /></button>}
                      {user.status === 'active' ? (
                        <button onClick={() => handleAction(user, 'suspend')} className="p-1 hover:bg-slate-700 rounded" title="Suspend"><Ban size={16} className="text-yellow-400" /></button>
                      ) : (
                        <button onClick={() => handleAction(user, 'activate')} className="p-1 hover:bg-slate-700 rounded" title="Activate"><Check size={16} className="text-green-400" /></button>
                      )}
                      {user.role !== 'admin' && user.role !== 'superadmin' && (
                        <button onClick={() => handleAction(user, 'makeAdmin')} className="p-1 hover:bg-slate-700 rounded" title="Make Admin"><Shield size={16} className="text-blue-400" /></button>
                      )}
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {pagination && pagination.pages > 1 && (
        <div className="flex justify-center gap-2">
          <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="btn btn-secondary">Previous</button>
          <span className="px-4 py-2 text-slate-400">Page {page} of {pagination.pages}</span>
          <button onClick={() => setPage(p => Math.min(pagination.pages, p + 1))} disabled={page === pagination.pages} className="btn btn-secondary">Next</button>
        </div>
      )}
    </div>
  );
}

