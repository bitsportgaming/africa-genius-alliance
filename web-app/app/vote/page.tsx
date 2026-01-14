'use client';

import { useState, useEffect } from 'react';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardLayout } from '@/components/layout/DashboardLayout';
import { UserRole, Election } from '@/types';
import { AGACard, AGAButton, AGAPill } from '@/components/ui';
import { Vote as VoteIcon, Trophy, Users, Calendar, ChevronRight, CheckCircle, ExternalLink, RefreshCw } from 'lucide-react';
import { ElectionCard } from '@/components/vote/ElectionCard';
import { VotingModal } from '@/components/vote/VotingModal';
import { votingAPI } from '@/lib/api';
import { useAuth } from '@/lib/store/auth-store';

export default function VotePage() {
  const { user } = useAuth();
  const [selectedElection, setSelectedElection] = useState<Election | null>(null);
  const [showVotingModal, setShowVotingModal] = useState(false);
  const [elections, setElections] = useState<Election[]>([]);
  const [myVotes, setMyVotes] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [countryFilter, setCountryFilter] = useState('');

  // Fetch elections
  const fetchElections = async () => {
    setLoading(true);
    try {
      const response = await votingAPI.getActiveElections();
      if (response.success && response.data) {
        let filtered = response.data;
        if (countryFilter) {
          filtered = filtered.filter(e => e.country === countryFilter);
        }
        setElections(filtered);
      }
    } catch (error) {
      console.error('Failed to fetch elections:', error);
    } finally {
      setLoading(false);
    }
  };

  // Fetch user's vote history
  const fetchMyVotes = async () => {
    if (!user?.userId) return;
    const userId = user.userId;

    // Check each election for user's votes
    const votesPromises = elections.map(async (election) => {
      try {
        const response = await votingAPI.checkVote(election.electionId, userId);
        if (response.success && response.data?.hasVoted) {
          const candidate = election.candidates.find(c => c.candidateId === response.data?.vote?.candidateId);
          return {
            electionId: election.electionId,
            electionTitle: election.title,
            candidateName: candidate?.name || 'Unknown',
            votedAt: response.data.vote?.votedAt,
            transactionHash: response.data.vote?.blockchain?.transactionHash,
            blockNumber: response.data.vote?.blockchain?.blockNumber,
          };
        }
        return null;
      } catch {
        return null;
      }
    });

    const votes = (await Promise.all(votesPromises)).filter(Boolean);
    setMyVotes(votes);
  };

  useEffect(() => {
    fetchElections();
  }, [countryFilter]);

  useEffect(() => {
    if (elections.length > 0) {
      fetchMyVotes();
    }
  }, [elections, user?.userId]);

  const handleVote = (election: Election) => {
    setSelectedElection(election);
    setShowVotingModal(true);
  };

  const handleVoteComplete = () => {
    setShowVotingModal(false);
    setSelectedElection(null);
    fetchElections();
    fetchMyVotes();
  };

  const totalVoters = elections.reduce((sum, e) => sum + (e.totalVoters || 0), 0);

  return (
    <ProtectedRoute requiredRole={UserRole.SUPPORTER}>
      <DashboardLayout>
        <div className="max-w-6xl mx-auto space-y-8">
          {/* Header */}
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-4xl font-black text-text-dark mb-2">
                Vote for Leaders
              </h1>
              <p className="text-lg text-text-gray">
                Your voice matters. Vote based on merit and drive real change across Africa.
              </p>
            </div>
            <button
              onClick={fetchElections}
              disabled={loading}
              className="p-2 rounded-lg bg-primary/10 hover:bg-primary/20 transition-colors"
            >
              <RefreshCw className={`w-5 h-5 text-primary ${loading ? 'animate-spin' : ''}`} />
            </button>
          </div>

          {/* Country Filter */}
          <div className="flex gap-2 flex-wrap">
            {['', 'Nigeria', 'South Africa', 'Kenya', 'Ghana', 'Egypt'].map(country => (
              <button
                key={country}
                onClick={() => setCountryFilter(country)}
                className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                  countryFilter === country
                    ? 'bg-primary text-white'
                    : 'bg-surface-light text-text-gray hover:bg-primary/10'
                }`}
              >
                {country || 'All Countries'}
              </button>
            ))}
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
                  <p className="text-sm text-text-gray mt-1">My Votes</p>
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
                    {elections.length}
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
                    {totalVoters.toLocaleString()}
                  </h3>
                  <p className="text-sm text-text-gray mt-1">Total Voters</p>
                </div>
              </div>
            </AGACard>
          </div>

          {/* How Voting Works */}
          <AGACard variant="hero" padding="lg">
            <h3 className="font-bold text-text-dark mb-4">🗳️ How Classic Voting Works</h3>
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
                <p className="text-sm text-text-gray">Select 1 candidate per election</p>
              </div>
              <div className="text-center">
                <div className="w-12 h-12 rounded-full bg-primary text-white flex items-center justify-center font-bold text-lg mx-auto mb-2">
                  4
                </div>
                <p className="text-sm text-text-gray">Get blockchain verification</p>
              </div>
            </div>
          </AGACard>

          {/* Active Elections */}
          <section>
            <h2 className="text-2xl font-bold text-text-dark mb-4">
              Active Elections ({elections.length})
            </h2>

            {loading ? (
              <div className="text-center py-12">
                <RefreshCw className="w-8 h-8 text-primary animate-spin mx-auto mb-3" />
                <p className="text-text-gray">Loading elections...</p>
              </div>
            ) : elections.length === 0 ? (
              <AGACard variant="elevated" padding="lg">
                <div className="text-center py-8 text-text-gray">
                  <Trophy className="w-16 h-16 text-gray-300 mx-auto mb-3" />
                  <p>No active elections found</p>
                  <p className="text-sm mt-1">Check back later for upcoming elections</p>
                </div>
              </AGACard>
            ) : (
              <div className="space-y-6">
                {elections.map((election) => {
                  const hasVoted = myVotes.some(v => v.electionId === election.electionId);
                  return (
                    <ElectionCard
                      key={election.electionId}
                      election={election}
                      hasVoted={hasVoted}
                      onVote={() => handleVote(election)}
                    />
                  );
                })}
              </div>
            )}
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
                            {vote.electionTitle}
                          </h3>
                          <p className="text-sm text-text-gray mb-2">
                            Voted for: <span className="font-semibold text-text-dark">{vote.candidateName}</span>
                          </p>
                          <div className="flex items-center gap-4 text-xs text-text-gray">
                            <span>Block #{vote.blockNumber || 'Pending'}</span>
                            <span>•</span>
                            <span>{vote.votedAt ? new Date(vote.votedAt).toLocaleDateString() : 'Processing'}</span>
                          </div>
                        </div>
                      </div>
                      <AGAPill variant="success" size="sm">
                        Verified
                      </AGAPill>
                    </div>
                    {vote.transactionHash && (
                      <div className="mt-3 p-3 bg-gray-50 rounded-lg">
                        <p className="text-xs text-text-gray mb-1">Transaction Hash:</p>
                        <div className="flex items-center gap-2">
                          <code className="text-xs text-primary break-all flex-1">
                            {vote.transactionHash}
                          </code>
                          <a
                            href={`https://testnet.bscscan.com/tx/${vote.transactionHash}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-primary hover:text-primary/80"
                          >
                            <ExternalLink className="w-4 h-4" />
                          </a>
                        </div>
                      </div>
                    )}
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
            onClose={handleVoteComplete}
          />
        )}
      </DashboardLayout>
    </ProtectedRoute>
  );
}
