import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { electionsAPI, Election, CreateElectionData, Candidate } from '../services/api';
import { Plus, Edit, Trash2, Users, Calendar, X, UserPlus, Vote, ExternalLink } from 'lucide-react';
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
                  <p className="text-sm text-slate-400">{election.position} • {election.country || 'Global'}</p>
                </div>
                <span className={`badge ${getStatusColor(election.status)}`}>{election.status}</span>
              </div>

              <p className="text-slate-300 text-sm mb-4 line-clamp-2">{election.description}</p>

              <div className="flex flex-wrap items-center gap-3 text-sm text-slate-400 mb-4">
                <span className="flex items-center gap-1">
                  <Calendar size={14} />
                  {format(new Date(election.startDate), 'MMM d')} - {format(new Date(election.endDate), 'MMM d, yyyy')}
                </span>
                <span className="flex items-center gap-1">
                  <Users size={14} />
                  {election.candidates?.length || 0} candidates
                </span>
                <span className="flex items-center gap-1">
                  <Vote size={14} />
                  {election.totalVotes || 0} votes
                </span>
              </div>

              {/* Blockchain Status */}
              <div className="mb-4 p-2 rounded bg-slate-700/50 text-xs">
                <span className={`inline-flex items-center gap-1 ${election.blockchain?.isDeployed ? 'text-green-400' : 'text-yellow-400'}`}>
                  {election.blockchain?.isDeployed ? '🔗 On BNB Chain' : '⏳ Pending Deployment'}
                  {election.blockchain?.deployTxHash && (
                    <a
                      href={`https://testnet.bscscan.com/tx/${election.blockchain.deployTxHash}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-blue-400 hover:underline"
                    >
                      <ExternalLink size={12} />
                    </a>
                  )}
                </span>
              </div>

              {election.candidates?.length > 0 && (
                <div className="mb-4">
                  <p className="text-xs text-slate-500 mb-2">Top Candidates</p>
                  <div className="space-y-2">
                    {election.candidates
                      .sort((a, b) => b.votesReceived - a.votesReceived)
                      .slice(0, 3)
                      .map((c) => (
                      <div key={c.candidateId} className="flex items-center justify-between text-sm">
                        <div>
                          <span className="text-slate-300">{c.name}</span>
                          {c.party && <span className="text-slate-500 text-xs ml-2">({c.party})</span>}
                        </div>
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

interface CandidateInput {
  name: string;
  party: string;
  bio: string;
  manifesto: string;
}

function CreateElectionModal({ onClose }: { onClose: () => void }) {
  const [formData, setFormData] = useState<CreateElectionData>({
    title: '', description: '', position: '', country: '', startDate: '', endDate: '', candidates: []
  });
  const [candidates, setCandidates] = useState<CandidateInput[]>([]);
  const [showAddCandidate, setShowAddCandidate] = useState(false);
  const [newCandidate, setNewCandidate] = useState<CandidateInput>({ name: '', party: '', bio: '', manifesto: '' });
  const queryClient = useQueryClient();

  const createMutation = useMutation({
    mutationFn: (data: CreateElectionData) => electionsAPI.create(data),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['adminElections'] }); onClose(); },
  });

  const handleAddCandidate = () => {
    if (newCandidate.name.trim()) {
      setCandidates([...candidates, newCandidate]);
      setNewCandidate({ name: '', party: '', bio: '', manifesto: '' });
      setShowAddCandidate(false);
    }
  };

  const handleRemoveCandidate = (index: number) => {
    setCandidates(candidates.filter((_, i) => i !== index));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (candidates.length < 2) {
      alert('Please add at least 2 candidates');
      return;
    }
    createMutation.mutate({ ...formData, candidates });
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-slate-800 rounded-xl border border-slate-700 w-full max-w-2xl max-h-[90vh] overflow-auto">
        <div className="flex items-center justify-between p-4 border-b border-slate-700">
          <h2 className="text-lg font-semibold text-white">Create Election</h2>
          <button onClick={onClose} className="text-slate-400 hover:text-white"><X size={20} /></button>
        </div>
        <form onSubmit={handleSubmit} className="p-4 space-y-4">
          {/* Basic Info */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-slate-300 mb-1">Title *</label>
              <input value={formData.title} onChange={(e) => setFormData({...formData, title: e.target.value})} required className="w-full" placeholder="e.g., Minister of Digital Economy" />
            </div>
            <div>
              <label className="block text-sm text-slate-300 mb-1">Position *</label>
              <input value={formData.position} onChange={(e) => setFormData({...formData, position: e.target.value})} required className="w-full" placeholder="e.g., Minister" />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-slate-300 mb-1">Country</label>
              <select value={formData.country} onChange={(e) => setFormData({...formData, country: e.target.value})} className="w-full">
                <option value="">Global</option>
                <option value="Nigeria">Nigeria</option>
                <option value="South Africa">South Africa</option>
                <option value="Kenya">Kenya</option>
                <option value="Ghana">Ghana</option>
                <option value="Egypt">Egypt</option>
                <option value="Ethiopia">Ethiopia</option>
                <option value="Tanzania">Tanzania</option>
                <option value="Rwanda">Rwanda</option>
              </select>
            </div>
            <div>
              <label className="block text-sm text-slate-300 mb-1">Region</label>
              <input value={formData.region || ''} onChange={(e) => setFormData({...formData, region: e.target.value})} className="w-full" placeholder="e.g., National, Lagos" />
            </div>
          </div>

          <div>
            <label className="block text-sm text-slate-300 mb-1">Description</label>
            <textarea value={formData.description} onChange={(e) => setFormData({...formData, description: e.target.value})} className="w-full" rows={2} placeholder="Brief description of the election..." />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-slate-300 mb-1">Start Date *</label>
              <input type="datetime-local" value={formData.startDate} onChange={(e) => setFormData({...formData, startDate: e.target.value})} required className="w-full" />
            </div>
            <div>
              <label className="block text-sm text-slate-300 mb-1">End Date *</label>
              <input type="datetime-local" value={formData.endDate} onChange={(e) => setFormData({...formData, endDate: e.target.value})} required className="w-full" />
            </div>
          </div>

          {/* Candidates Section */}
          <div className="border-t border-slate-700 pt-4">
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-sm font-semibold text-white">Candidates ({candidates.length})</h3>
              <button type="button" onClick={() => setShowAddCandidate(true)} className="btn btn-secondary text-xs py-1 px-2 flex items-center gap-1">
                <UserPlus size={14} /> Add Candidate
              </button>
            </div>

            {candidates.length === 0 && (
              <p className="text-slate-500 text-sm text-center py-4">No candidates added yet. Add at least 2 candidates.</p>
            )}

            <div className="space-y-2 max-h-40 overflow-auto">
              {candidates.map((c, idx) => (
                <div key={idx} className="flex items-center justify-between p-2 bg-slate-700/50 rounded">
                  <div>
                    <span className="text-white text-sm">{c.name}</span>
                    {c.party && <span className="text-slate-400 text-xs ml-2">({c.party})</span>}
                  </div>
                  <button type="button" onClick={() => handleRemoveCandidate(idx)} className="text-red-400 hover:text-red-300">
                    <Trash2 size={14} />
                  </button>
                </div>
              ))}
            </div>

            {/* Add Candidate Form */}
            {showAddCandidate && (
              <div className="mt-3 p-3 bg-slate-700/30 rounded border border-slate-600">
                <div className="grid grid-cols-2 gap-2 mb-2">
                  <input
                    value={newCandidate.name}
                    onChange={(e) => setNewCandidate({...newCandidate, name: e.target.value})}
                    placeholder="Candidate Name *"
                    className="w-full text-sm"
                  />
                  <input
                    value={newCandidate.party}
                    onChange={(e) => setNewCandidate({...newCandidate, party: e.target.value})}
                    placeholder="Party/Affiliation"
                    className="w-full text-sm"
                  />
                </div>
                <input
                  value={newCandidate.bio}
                  onChange={(e) => setNewCandidate({...newCandidate, bio: e.target.value})}
                  placeholder="Short bio"
                  className="w-full text-sm mb-2"
                />
                <textarea
                  value={newCandidate.manifesto}
                  onChange={(e) => setNewCandidate({...newCandidate, manifesto: e.target.value})}
                  placeholder="Manifesto / Key policies"
                  className="w-full text-sm mb-2"
                  rows={2}
                />
                <div className="flex gap-2">
                  <button type="button" onClick={() => setShowAddCandidate(false)} className="btn btn-secondary text-xs py-1 flex-1">Cancel</button>
                  <button type="button" onClick={handleAddCandidate} disabled={!newCandidate.name.trim()} className="btn btn-primary text-xs py-1 flex-1">Add</button>
                </div>
              </div>
            )}
          </div>

          <div className="flex gap-2 pt-4 border-t border-slate-700">
            <button type="button" onClick={onClose} className="btn btn-secondary flex-1">Cancel</button>
            <button type="submit" disabled={createMutation.isPending || candidates.length < 2} className="btn btn-primary flex-1">
              {createMutation.isPending ? 'Creating...' : `Create Election (${candidates.length} candidates)`}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

