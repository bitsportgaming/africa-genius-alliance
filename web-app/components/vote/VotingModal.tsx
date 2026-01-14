'use client';

import { useState } from 'react';
import { AGACard, AGAButton, AGAPill } from '@/components/ui';
import { X, Vote, CheckCircle, AlertCircle, ExternalLink, Link as LinkIcon } from 'lucide-react';
import { votingAPI } from '@/lib/api';
import { Election, ElectionCandidate } from '@/types';
import { useAuth } from '@/lib/auth/AuthContext';

interface VotingModalProps {
  election: Election;
  onClose: () => void;
}

export function VotingModal({ election, onClose }: VotingModalProps) {
  const { user } = useAuth();
  const [selectedCandidate, setSelectedCandidate] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [voteResult, setVoteResult] = useState<{
    transactionHash: string;
    blockNumber: number;
    candidateName: string;
  } | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleSelectCandidate = (candidateId: string) => {
    setSelectedCandidate(candidateId);
    setError(null);
  };

  const handleSubmit = async () => {
    if (!selectedCandidate) {
      setError('Please select a candidate to vote for');
      return;
    }

    if (!user?.userId) {
      setError('You must be logged in to vote');
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      const response = await votingAPI.castVote(election.electionId, {
        userId: user.userId,
        candidateId: selectedCandidate,
      });

      if (response.success && response.data) {
        const candidate = election.candidates.find(c => c.candidateId === selectedCandidate);
        setVoteResult({
          transactionHash: response.data.vote.blockchain.transactionHash,
          blockNumber: response.data.vote.blockchain.blockNumber,
          candidateName: candidate?.name || 'Unknown',
        });
        setSubmitted(true);
      } else {
        setError(response.error || 'Failed to submit vote');
      }
    } catch (err: any) {
      setError(err.response?.data?.error || err.message || 'Failed to submit vote');
    } finally {
      setIsSubmitting(false);
    }
  };

  // Get initials for avatar
  const getInitials = (name: string) => {
    return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
  };

  if (submitted && voteResult) {
    return (
      <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
        <AGACard variant="elevated" padding="lg" className="max-w-lg w-full">
          <div className="text-center">
            <div className="w-20 h-20 rounded-full bg-green-500 flex items-center justify-center mx-auto mb-4">
              <CheckCircle className="w-10 h-10 text-white" />
            </div>
            <h2 className="text-3xl font-black text-text-dark mb-2">
              Vote Confirmed!
            </h2>
            <p className="text-text-gray mb-2">
              Your vote for <span className="font-semibold text-text-dark">{voteResult.candidateName}</span> has been recorded.
            </p>
            <p className="text-sm text-text-gray mb-6">
              Block #{voteResult.blockNumber} • Verified on BNB Chain
            </p>

            <div className="mb-6 p-4 bg-gray-50 rounded-lg text-left">
              <p className="text-sm font-semibold text-text-dark mb-2 flex items-center gap-2">
                <LinkIcon className="w-4 h-4" />
                Transaction Hash
              </p>
              <div className="flex items-center gap-2">
                <code className="text-xs text-primary break-all flex-1">
                  {voteResult.transactionHash}
                </code>
                <a
                  href={`https://testnet.bscscan.com/tx/${voteResult.transactionHash}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-primary hover:text-primary/80 flex-shrink-0"
                >
                  <ExternalLink className="w-4 h-4" />
                </a>
              </div>
            </div>

            <AGAButton variant="primary" fullWidth onClick={onClose}>
              Done
            </AGAButton>
          </div>
        </AGACard>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4 overflow-y-auto">
      <div className="max-w-4xl w-full my-8">
        <AGACard variant="elevated" padding="lg">
          {/* Header */}
          <div className="flex items-start justify-between mb-6">
            <div>
              <h2 className="text-3xl font-black text-text-dark mb-2">
                {election.title}
              </h2>
              <p className="text-text-gray">
                Select one candidate to cast your vote
              </p>
              {election.blockchain?.isDeployed && (
                <div className="flex items-center gap-1 mt-2 text-xs text-green-600">
                  <LinkIcon className="w-3 h-3" />
                  Votes recorded on BNB Chain
                </div>
              )}
            </div>
            <button
              onClick={onClose}
              className="p-2 hover:bg-gray-100 rounded-full transition-colors"
            >
              <X className="w-6 h-6 text-gray-600" />
            </button>
          </div>

          {/* Error Message */}
          {error && (
            <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-aga flex items-start gap-3">
              <AlertCircle className="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" />
              <p className="text-red-700">{error}</p>
            </div>
          )}

          {/* Voting Info */}
          <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-aga">
            <h3 className="font-semibold text-blue-900 mb-2">Classic Voting</h3>
            <ul className="text-sm text-blue-700 space-y-1">
              <li>• Select <strong>one candidate</strong> to vote for</li>
              <li>• Your vote will be recorded on the blockchain</li>
              <li>• You can only vote once per election</li>
              <li>• Votes are final and cannot be changed</li>
            </ul>
          </div>

          {/* Candidates - Radio Selection */}
          <div className="space-y-4 mb-6">
            {election.candidates
              .sort((a, b) => b.votesReceived - a.votesReceived)
              .map((candidate: ElectionCandidate) => {
              const isSelected = selectedCandidate === candidate.candidateId;

              return (
                <button
                  key={candidate.candidateId}
                  onClick={() => handleSelectCandidate(candidate.candidateId)}
                  className={`w-full p-6 rounded-aga border-2 transition-all text-left ${
                    isSelected
                      ? 'border-primary bg-primary/5 ring-2 ring-primary/20'
                      : 'border-gray-200 bg-white hover:border-gray-300'
                  }`}
                >
                  <div className="flex items-start gap-4">
                    {/* Selection Indicator */}
                    <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center flex-shrink-0 mt-1 ${
                      isSelected ? 'border-primary bg-primary' : 'border-gray-300'
                    }`}>
                      {isSelected && <CheckCircle className="w-4 h-4 text-white" />}
                    </div>

                    {/* Avatar */}
                    <div className="w-16 h-16 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-xl flex-shrink-0">
                      {candidate.avatarURL ? (
                        <img src={candidate.avatarURL} alt={candidate.name} className="w-full h-full rounded-full object-cover" />
                      ) : (
                        getInitials(candidate.name)
                      )}
                    </div>

                    {/* Info */}
                    <div className="flex-1 min-w-0">
                      <h3 className="text-xl font-bold text-text-dark mb-1">
                        {candidate.name}
                      </h3>
                      {candidate.party && (
                        <AGAPill variant="primary" size="sm" className="mb-2">
                          {candidate.party}
                        </AGAPill>
                      )}
                      {candidate.bio && (
                        <p className="text-sm text-text-gray mb-2">
                          {candidate.bio}
                        </p>
                      )}
                      {candidate.manifesto && (
                        <p className="text-sm text-text-gray italic">
                          "{candidate.manifesto}"
                        </p>
                      )}
                    </div>

                    {/* Current Votes */}
                    <div className="text-right flex-shrink-0">
                      <div className="text-2xl font-black text-text-dark">
                        {candidate.votesReceived.toLocaleString()}
                      </div>
                      <div className="text-xs text-text-gray">votes</div>
                    </div>
                  </div>
                </button>
              );
            })}
          </div>

          {/* Summary & Submit */}
          <div className="flex items-center justify-between pt-6 border-t border-gray-200">
            <div>
              {selectedCandidate ? (
                <>
                  <p className="text-sm text-text-gray mb-1">Selected Candidate</p>
                  <p className="text-lg font-bold text-text-dark">
                    {election.candidates.find(c => c.candidateId === selectedCandidate)?.name}
                  </p>
                </>
              ) : (
                <p className="text-text-gray">Select a candidate to vote</p>
              )}
            </div>

            <div className="flex gap-3">
              <AGAButton variant="outline" size="lg" onClick={onClose}>
                Cancel
              </AGAButton>
              <AGAButton
                variant="primary"
                size="lg"
                onClick={handleSubmit}
                loading={isSubmitting}
                disabled={!selectedCandidate}
                leftIcon={<Vote className="w-5 h-5" />}
              >
                Cast Vote
              </AGAButton>
            </div>
          </div>
        </AGACard>
      </div>
    </div>
  );
}
