'use client';

import { AGACard, AGAPill, AGAButton } from '@/components/ui';
import { Calendar, MapPin, TrendingUp, CheckCircle, Link as LinkIcon } from 'lucide-react';
import { Election, ElectionCandidate } from '@/types';

interface ElectionCardProps {
  election: Election;
  hasVoted?: boolean;
  onVote: () => void;
}

export function ElectionCard({ election, hasVoted = false, onVote }: ElectionCardProps) {
  // Sort candidates by votes received
  const sortedCandidates = [...election.candidates].sort((a, b) => b.votesReceived - a.votesReceived);
  const topCandidate = sortedCandidates[0];

  // Get initials for avatar
  const getInitials = (name: string) => {
    return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
  };

  return (
    <AGACard variant="elevated" padding="lg" className="hover:shadow-aga-lg transition-all">
      <div className="flex flex-col lg:flex-row gap-6">
        {/* Election Info */}
        <div className="flex-1">
          <div className="flex items-start justify-between mb-4">
            <div className="flex-1">
              <h3 className="text-2xl font-bold text-text-dark mb-2">
                {election.title}
              </h3>
              <p className="text-text-gray mb-3">
                {election.description}
              </p>
              <div className="flex flex-wrap items-center gap-3">
                <AGAPill variant="primary" size="sm">
                  <MapPin className="w-3 h-3 mr-1" />
                  {election.country || 'Global'}
                </AGAPill>
                <AGAPill variant="neutral" size="sm">
                  <Calendar className="w-3 h-3 mr-1" />
                  Ends {new Date(election.endDate).toLocaleDateString()}
                </AGAPill>
                <AGAPill variant={election.status === 'active' ? 'success' : 'neutral'} size="sm">
                  {election.status === 'active' ? 'Active' : election.status}
                </AGAPill>
                {election.blockchain?.isDeployed && (
                  <AGAPill variant="secondary" size="sm">
                    <LinkIcon className="w-3 h-3 mr-1" />
                    On-Chain
                  </AGAPill>
                )}
              </div>
            </div>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-3 gap-4 py-4 border-t border-gray-200">
            <div>
              <div className="text-2xl font-black text-text-dark">
                {election.candidates.length}
              </div>
              <div className="text-xs text-text-gray">Candidates</div>
            </div>
            <div>
              <div className="text-2xl font-black text-text-dark">
                {(election.totalVotes || 0).toLocaleString()}
              </div>
              <div className="text-xs text-text-gray">Total Votes</div>
            </div>
            <div>
              <div className="text-2xl font-black text-text-dark">
                {(election.totalVoters || 0).toLocaleString()}
              </div>
              <div className="text-xs text-text-gray">Voters</div>
            </div>
          </div>

          {/* Top Candidate Preview */}
          {topCandidate && (
            <div className="mt-4 p-4 bg-primary/5 rounded-lg border border-primary/20">
              <div className="flex items-center gap-3 mb-2">
                <TrendingUp className="w-5 h-5 text-primary" />
                <span className="font-semibold text-text-dark">Leading Candidate</span>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold">
                  {topCandidate.avatarURL ? (
                    <img src={topCandidate.avatarURL} alt={topCandidate.name} className="w-full h-full rounded-full object-cover" />
                  ) : (
                    getInitials(topCandidate.name)
                  )}
                </div>
                <div className="flex-1">
                  <p className="font-bold text-text-dark">{topCandidate.name}</p>
                  <p className="text-sm text-text-gray">
                    {topCandidate.party && <span className="mr-2">{topCandidate.party}</span>}
                    {topCandidate.votesReceived.toLocaleString()} votes
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Candidates Preview */}
        <div className="lg:w-80">
          <h4 className="font-semibold text-text-dark mb-3">
            Candidates ({election.candidates.length})
          </h4>
          <div className="space-y-2 mb-4">
            {sortedCandidates.slice(0, 3).map((candidate: ElectionCandidate) => (
              <div
                key={candidate.candidateId}
                className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
              >
                <div className="w-10 h-10 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-sm">
                  {candidate.avatarURL ? (
                    <img src={candidate.avatarURL} alt={candidate.name} className="w-full h-full rounded-full object-cover" />
                  ) : (
                    getInitials(candidate.name)
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-semibold text-text-dark text-sm truncate">
                    {candidate.name}
                  </p>
                  <p className="text-xs text-text-gray">
                    {candidate.party && <span className="mr-1">{candidate.party} •</span>}
                    {candidate.votesReceived.toLocaleString()} votes
                  </p>
                </div>
              </div>
            ))}
            {election.candidates.length > 3 && (
              <p className="text-xs text-text-gray text-center py-2">
                +{election.candidates.length - 3} more candidates
              </p>
            )}
          </div>

          {hasVoted ? (
            <div className="flex items-center justify-center gap-2 py-3 px-4 bg-green-50 text-green-700 rounded-lg font-semibold">
              <CheckCircle className="w-5 h-5" />
              You've Voted
            </div>
          ) : (
            <AGAButton
              variant="primary"
              fullWidth
              size="lg"
              onClick={onVote}
            >
              View & Vote
            </AGAButton>
          )}
        </div>
      </div>
    </AGACard>
  );
}
