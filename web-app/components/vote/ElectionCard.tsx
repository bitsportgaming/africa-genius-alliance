'use client';

import { AGACard, AGAPill, AGAButton } from '@/components/ui';
import { Calendar, MapPin, Users, TrendingUp } from 'lucide-react';

interface ElectionCardProps {
  election: any;
  onVote: () => void;
}

export function ElectionCard({ election, onVote }: ElectionCardProps) {
  const topCandidate = election.candidates.sort((a: any, b: any) => b.votes - a.votes)[0];

  return (
    <AGACard variant="elevated" padding="lg" className="hover:shadow-aga-lg transition-all">
      <div className="flex flex-col lg:flex-row gap-6">
        {/* Election Info */}
        <div className="flex-1">
          <div className="flex items-start justify-between mb-4">
            <div className="flex-1">
              <h3 className="text-2xl font-bold text-text-dark mb-2">
                {election.electionName}
              </h3>
              <p className="text-text-gray mb-3">
                {election.description}
              </p>
              <div className="flex flex-wrap items-center gap-3">
                <AGAPill variant="primary" size="sm">
                  <MapPin className="w-3 h-3 mr-1" />
                  {election.country}
                </AGAPill>
                <AGAPill variant="neutral" size="sm">
                  <Calendar className="w-3 h-3 mr-1" />
                  Ends {new Date(election.endDate).toLocaleDateString()}
                </AGAPill>
                <AGAPill variant="success" size="sm">
                  Active
                </AGAPill>
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
                {election.totalVotes.toLocaleString()}
              </div>
              <div className="text-xs text-text-gray">Total Votes</div>
            </div>
            <div>
              <div className="text-2xl font-black text-text-dark">
                {election.totalVoters.toLocaleString()}
              </div>
              <div className="text-xs text-text-gray">Voters</div>
            </div>
          </div>

          {/* Top Candidate Preview */}
          <div className="mt-4 p-4 bg-primary/5 rounded-lg border border-primary/20">
            <div className="flex items-center gap-3 mb-2">
              <TrendingUp className="w-5 h-5 text-primary" />
              <span className="font-semibold text-text-dark">Leading Candidate</span>
            </div>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold">
                {topCandidate.avatar}
              </div>
              <div className="flex-1">
                <p className="font-bold text-text-dark">{topCandidate.name}</p>
                <p className="text-sm text-text-gray">{topCandidate.votes.toLocaleString()} votes</p>
              </div>
            </div>
          </div>
        </div>

        {/* Candidates Preview */}
        <div className="lg:w-80">
          <h4 className="font-semibold text-text-dark mb-3">
            Candidates ({election.candidates.length})
          </h4>
          <div className="space-y-2 mb-4">
            {election.candidates.slice(0, 3).map((candidate: any, index: number) => (
              <div
                key={index}
                className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
              >
                <div className="w-10 h-10 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-sm">
                  {candidate.avatar}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-semibold text-text-dark text-sm truncate">
                    {candidate.name}
                  </p>
                  <p className="text-xs text-text-gray">
                    {candidate.votes.toLocaleString()} votes
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

          <AGAButton
            variant="primary"
            fullWidth
            size="lg"
            onClick={onVote}
          >
            View & Vote
          </AGAButton>
        </div>
      </div>
    </AGACard>
  );
}
