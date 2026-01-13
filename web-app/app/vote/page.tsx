'use client';

import { useState } from 'react';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { UserRole } from '@/types';
import { AGACard, AGAButton, AGAPill } from '@/components/ui';
import { Vote as VoteIcon, Trophy, Users, Calendar, ChevronRight, CheckCircle } from 'lucide-react';
import { ElectionCard } from '@/components/vote/ElectionCard';
import { VotingModal } from '@/components/vote/VotingModal';

export default function VotePage() {
  const [selectedElection, setSelectedElection] = useState<any>(null);
  const [showVotingModal, setShowVotingModal] = useState(false);

  // Mock data - Replace with real API calls
  const activeElections = [
    {
      _id: '1',
      electionName: 'Presidential Election 2024',
      description: 'National presidential election to select the next leader',
      positions: ['President', 'Vice President'],
      startDate: '2024-01-01',
      endDate: '2024-12-31',
      country: 'Nigeria',
      region: 'National',
      isActive: true,
      candidates: [
        {
          userId: '1',
          name: 'Amina Okafor',
          avatar: 'AO',
          position: 'Presidential Candidate',
          votes: 5432,
          category: 'Political',
          manifesto: 'Healthcare reform and economic development for all Nigerians.',
        },
        {
          userId: '2',
          name: 'Kwame Mensah',
          avatar: 'KM',
          position: 'Presidential Candidate',
          votes: 4891,
          category: 'Political',
          manifesto: 'Education and infrastructure development as national priorities.',
        },
        {
          userId: '3',
          name: 'Zainab Hassan',
          avatar: 'ZH',
          position: 'Presidential Candidate',
          votes: 4567,
          category: 'Political',
          manifesto: 'Universal healthcare and social welfare programs.',
        },
      ],
      totalVotes: 14890,
      totalVoters: 8234,
    },
    {
      _id: '2',
      electionName: 'Minister of Education - Ghana',
      description: 'Selection of the Minister of Education for Ghana',
      positions: ['Minister of Education'],
      startDate: '2024-06-01',
      endDate: '2024-12-31',
      country: 'Ghana',
      region: 'National',
      isActive: true,
      candidates: [
        {
          userId: '4',
          name: 'Thabo Ndlovu',
          avatar: 'TN',
          position: 'Education Reform Leader',
          votes: 3234,
          category: 'Political',
          manifesto: 'Technology-driven education transformation.',
        },
        {
          userId: '5',
          name: 'Fatima Diallo',
          avatar: 'FD',
          position: 'Education Specialist',
          votes: 2998,
          category: 'Technical',
          manifesto: 'Quality education accessible to every child.',
        },
      ],
      totalVotes: 6232,
      totalVoters: 3456,
    },
  ];

  const myVotes = [
    {
      electionName: 'City Council - Lagos',
      candidate: 'Samuel Adebayo',
      votes: 4,
      date: '2024-01-10',
      transactionHash: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
    },
  ];

  const handleVote = (election: any) => {
    setSelectedElection(election);
    setShowVotingModal(true);
  };

  return (
    <ProtectedRoute requiredRole={UserRole.SUPPORTER}>
      <DashboardLayout>
        <div className="max-w-6xl mx-auto space-y-8">
          {/* Header */}
          <div>
            <h1 className="text-4xl font-black text-text-dark mb-2">
              Vote for Leaders
            </h1>
            <p className="text-lg text-text-gray">
              Your voice matters. Vote based on merit and drive real change across Africa.
            </p>
          </div>

          {/* Stats Overview */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <AGACard variant="elevated" padding="lg">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                  <VoteIcon className="w-6 h-6 text-primary" />
                </div>
                <div>
                  <h3 className="text-3xl font-black text-text-dark">
                    {myVotes.length}
                  </h3>
                  <p className="text-sm text-text-gray mt-1">Votes Cast</p>
                </div>
              </div>
            </AGACard>

            <AGACard variant="elevated" padding="lg">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-secondary/10 flex items-center justify-center">
                  <Trophy className="w-6 h-6 text-secondary" />
                </div>
                <div>
                  <h3 className="text-3xl font-black text-text-dark">
                    {activeElections.length}
                  </h3>
                  <p className="text-sm text-text-gray mt-1">Active Elections</p>
                </div>
              </div>
            </AGACard>

            <AGACard variant="elevated" padding="lg">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 rounded-xl bg-green-500/10 flex items-center justify-center">
                  <Users className="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <h3 className="text-3xl font-black text-text-dark">
                    {activeElections.reduce((sum, e) => sum + e.totalVoters, 0).toLocaleString()}
                  </h3>
                  <p className="text-sm text-text-gray mt-1">Total Voters</p>
                </div>
              </div>
            </AGACard>
          </div>

          {/* How Voting Works */}
          <AGACard variant="hero" padding="lg">
            <h3 className="font-bold text-text-dark mb-4">🗳️ How Voting Works</h3>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="text-center">
                <div className="w-12 h-12 rounded-full bg-primary text-white flex items-center justify-center font-bold text-lg mx-auto mb-2">
                  1
                </div>
                <p className="text-sm text-text-gray">Browse active elections</p>
              </div>
              <div className="text-center">
                <div className="w-12 h-12 rounded-full bg-primary text-white flex items-center justify-center font-bold text-lg mx-auto mb-2">
                  2
                </div>
                <p className="text-sm text-text-gray">Compare candidates</p>
              </div>
              <div className="text-center">
                <div className="w-12 h-12 rounded-full bg-primary text-white flex items-center justify-center font-bold text-lg mx-auto mb-2">
                  3
                </div>
                <p className="text-sm text-text-gray">Cast 1-4 votes per candidate</p>
              </div>
              <div className="text-center">
                <div className="w-12 h-12 rounded-full bg-primary text-white flex items-center justify-center font-bold text-lg mx-auto mb-2">
                  4
                </div>
                <p className="text-sm text-text-gray">Get blockchain confirmation</p>
              </div>
            </div>
          </AGACard>

          {/* Active Elections */}
          <section>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-2xl font-bold text-text-dark">
                Active Elections ({activeElections.length})
              </h2>
              <select className="px-4 py-2 rounded-lg border border-gray-200 text-text-dark focus:outline-none focus:ring-2 focus:ring-primary/20">
                <option>All Countries</option>
                <option>Nigeria</option>
                <option>Ghana</option>
                <option>Kenya</option>
                <option>South Africa</option>
              </select>
            </div>

            <div className="space-y-6">
              {activeElections.map((election) => (
                <ElectionCard
                  key={election._id}
                  election={election}
                  onVote={() => handleVote(election)}
                />
              ))}
            </div>
          </section>

          {/* My Voting History */}
          <section>
            <h2 className="text-2xl font-bold text-text-dark mb-4">
              My Voting History
            </h2>
            {myVotes.length > 0 ? (
              <div className="space-y-4">
                {myVotes.map((vote, index) => (
                  <AGACard key={index} variant="elevated" padding="lg">
                    <div className="flex items-start justify-between">
                      <div className="flex items-start gap-4">
                        <CheckCircle className="w-6 h-6 text-green-500 mt-1" />
                        <div>
                          <h3 className="font-bold text-text-dark mb-1">
                            {vote.electionName}
                          </h3>
                          <p className="text-sm text-text-gray mb-2">
                            Voted for: <span className="font-semibold text-text-dark">{vote.candidate}</span>
                          </p>
                          <div className="flex items-center gap-4 text-xs text-text-gray">
                            <span>
                              {vote.votes} vote{vote.votes > 1 ? 's' : ''}
                            </span>
                            <span>•</span>
                            <span>{vote.date}</span>
                          </div>
                        </div>
                      </div>
                      <AGAPill variant="success" size="sm">
                        Confirmed
                      </AGAPill>
                    </div>
                    <div className="mt-3 p-3 bg-gray-50 rounded-lg">
                      <p className="text-xs text-text-gray mb-1">Transaction Hash:</p>
                      <code className="text-xs text-primary break-all">
                        {vote.transactionHash}
                      </code>
                    </div>
                  </AGACard>
                ))}
              </div>
            ) : (
              <AGACard variant="elevated" padding="lg">
                <div className="text-center py-8 text-text-gray">
                  <VoteIcon className="w-16 h-16 text-gray-300 mx-auto mb-3" />
                  <p>You haven't cast any votes yet</p>
                  <p className="text-sm mt-1">Start voting in active elections above</p>
                </div>
              </AGACard>
            )}
          </section>
        </div>

        {/* Voting Modal */}
        {showVotingModal && selectedElection && (
          <VotingModal
            election={selectedElection}
            onClose={() => {
              setShowVotingModal(false);
              setSelectedElection(null);
            }}
          />
        )}
      </DashboardLayout>
    </ProtectedRoute>
  );
}
