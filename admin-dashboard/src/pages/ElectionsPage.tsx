import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { electionsAPI, Election, CreateElectionData } from '../services/api';
import { Plus, Edit, Trash2, Users, Calendar, X } from 'lucide-react';
import { format } from 'date-fns';

export default function ElectionsPage() {
  const [statusFilter, setStatusFilter] = useState('');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [page] = useState(1);
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['adminElections', page, statusFilter],
    queryFn: () => electionsAPI.getAll({ page, limit: 20, status: statusFilter }),
  });

  const deleteMutation = useMutation({
    mutationFn: (electionId: string) => electionsAPI.delete(electionId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['adminElections'] }),
  });

  const elections = data?.data?.data || [];

  const handleDelete = (election: Election) => {
    if (confirm(`Delete election "${election.title}"?`)) {
      deleteMutation.mutate(election.electionId);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'badge-success';
      case 'upcoming': return 'badge-info';
      case 'completed': return 'badge-warning';
      default: return 'badge-info';
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white">Elections</h1>
          <p className="text-slate-400">Manage elections and candidates</p>
        </div>
        <button onClick={() => setShowCreateModal(true)} className="btn btn-primary flex items-center gap-2">
          <Plus size={18} /> Create Election
        </button>
      </div>

      {/* Filters */}
      <div className="flex gap-4">
        <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} className="min-w-[150px]">
          <option value="">All Status</option>
          <option value="upcoming">Upcoming</option>
          <option value="active">Active</option>
          <option value="completed">Completed</option>
        </select>
      </div>

      {/* Elections Grid */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {isLoading ? (
          <div className="col-span-full text-center py-8 text-slate-400">Loading...</div>
        ) : elections.length === 0 ? (
          <div className="col-span-full text-center py-8 text-slate-400">No elections found</div>
        ) : (
          elections.map((election: Election) => (
            <div key={election.electionId} className="card">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h3 className="font-semibold text-white">{election.title}</h3>
                  <p className="text-sm text-slate-400">{election.position}</p>
                </div>
                <span className={`badge ${getStatusColor(election.status)}`}>{election.status}</span>
              </div>
              
              <p className="text-slate-300 text-sm mb-4 line-clamp-2">{election.description}</p>
              
              <div className="flex items-center gap-4 text-sm text-slate-400 mb-4">
                <span className="flex items-center gap-1">
                  <Calendar size={14} />
                  {format(new Date(election.startDate), 'MMM d')} - {format(new Date(election.endDate), 'MMM d, yyyy')}
                </span>
                <span className="flex items-center gap-1">
                  <Users size={14} />
                  {election.candidates?.length || 0} candidates
                </span>
              </div>

              {election.candidates?.length > 0 && (
                <div className="mb-4">
                  <p className="text-xs text-slate-500 mb-2">Top Candidates</p>
                  <div className="space-y-2">
                    {election.candidates.slice(0, 3).map((c) => (
                      <div key={c.candidateId} className="flex items-center justify-between text-sm">
                        <span className="text-slate-300">{c.name}</span>
                        <span className="text-aga-secondary">{c.votesReceived} votes</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div className="flex gap-2 pt-4 border-t border-slate-700">
                <button className="btn btn-secondary flex-1 flex items-center justify-center gap-1 py-2">
                  <Edit size={14} /> Edit
                </button>
                <button 
                  onClick={() => handleDelete(election)}
                  className="btn btn-danger flex items-center justify-center gap-1 py-2 px-3"
                >
                  <Trash2 size={14} />
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Create Modal */}
      {showCreateModal && (
        <CreateElectionModal onClose={() => setShowCreateModal(false)} />
      )}
    </div>
  );
}

function CreateElectionModal({ onClose }: { onClose: () => void }) {
  const [formData, setFormData] = useState<CreateElectionData>({
    title: '', description: '', position: '', startDate: '', endDate: '', candidates: []
  });
  const queryClient = useQueryClient();

  const createMutation = useMutation({
    mutationFn: (data: CreateElectionData) => electionsAPI.create(data),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['adminElections'] }); onClose(); },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    createMutation.mutate(formData);
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-slate-800 rounded-xl border border-slate-700 w-full max-w-lg max-h-[90vh] overflow-auto">
        <div className="flex items-center justify-between p-4 border-b border-slate-700">
          <h2 className="text-lg font-semibold text-white">Create Election</h2>
          <button onClick={onClose} className="text-slate-400 hover:text-white"><X size={20} /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-4 space-y-4">
          <div>
            <label className="block text-sm text-slate-300 mb-1">Title</label>
            <input value={formData.title} onChange={(e) => setFormData({...formData, title: e.target.value})} required className="w-full" />
          </div>
          <div>
            <label className="block text-sm text-slate-300 mb-1">Position</label>
            <input value={formData.position} onChange={(e) => setFormData({...formData, position: e.target.value})} required className="w-full" />
          </div>
          <div>
            <label className="block text-sm text-slate-300 mb-1">Description</label>
            <textarea value={formData.description} onChange={(e) => setFormData({...formData, description: e.target.value})} className="w-full" rows={3} />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-slate-300 mb-1">Start Date</label>
              <input type="datetime-local" value={formData.startDate} onChange={(e) => setFormData({...formData, startDate: e.target.value})} required className="w-full" />
            </div>
            <div>
              <label className="block text-sm text-slate-300 mb-1">End Date</label>
              <input type="datetime-local" value={formData.endDate} onChange={(e) => setFormData({...formData, endDate: e.target.value})} required className="w-full" />
            </div>
          </div>
          <div className="flex gap-2 pt-4">
            <button type="button" onClick={onClose} className="btn btn-secondary flex-1">Cancel</button>
            <button type="submit" disabled={createMutation.isPending} className="btn btn-primary flex-1">
              {createMutation.isPending ? 'Creating...' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

