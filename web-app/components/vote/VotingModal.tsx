'use client';

import { useState } from 'react';
import { AGACard, AGAButton, AGAPill } from '@/components/ui';
import { X, Vote, CheckCircle, AlertCircle } from 'lucide-react';
import { votingAPI } from '@/lib/api';

interface VotingModalProps {
  election: any;
  onClose: () => void;
}

export function VotingModal({ election, onClose }: VotingModalProps) {
  const [votes, setVotes] = useState<{ [key: string]: number }>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [transactionHash, setTransactionHash] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleVoteChange = (candidateId: string, value: number) => {
    setVotes((prev) => ({
      ...prev,
      [candidateId]: value,
    }));
    setError(null);
  };

  const totalVotes = Object.values(votes).reduce((sum, v) => sum + v, 0);
  const hasVoted = totalVotes > 0;

  const handleSubmit = async () => {
    if (!hasVoted) {
      setError('Please cast at least one vote');
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      // Submit votes for each candidate
      const votePromises = Object.entries(votes)
        .filter(([_, weight]) => weight > 0)
        .map(([candidateId, weight]) =>
          votingAPI.castVote({
            targetGeniusId: candidateId,
            positionId: election._id,
            weight,
          })
        );

      const results = await Promise.all(votePromises);

      // Get transaction hash from first vote (in real app, would be from blockchain)
      const mockHash = `0x${Math.random().toString(16).substring(2, 42)}`;
      setTransactionHash(mockHash);
      setSubmitted(true);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Failed to submit votes');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (submitted) {
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
            <p className="text-text-gray mb-6">
              Your {totalVotes} vote{totalVotes > 1 ? 's' : ''} ha{totalVotes > 1 ? 've' : 's'} been successfully recorded on the blockchain.
            </p>

            {transactionHash && (
              <div className="mb-6 p-4 bg-gray-50 rounded-lg">
                <p className="text-sm font-semibold text-text-dark mb-2">
                  Transaction Hash
                </p>
                <code className="text-xs text-primary break-all">
                  {transactionHash}
                </code>
              </div>
            )}

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
                {election.electionName}
              </h2>
              <p className="text-text-gray">
                Vote for your preferred candidates (1-4 votes per candidate)
              </p>
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
            <h3 className="font-semibold text-blue-900 mb-2">How to Vote</h3>
            <ul className="text-sm text-blue-700 space-y-1">
              <li>• Each candidate can receive 1-4 votes from you</li>
              <li>• You can vote for multiple candidates</li>
              <li>• Your votes will be recorded on the blockchain</li>
              <li>• You can only vote once per election</li>
            </ul>
          </div>

          {/* Candidates */}
          <div className="space-y-4 mb-6">
            {election.candidates.map((candidate: any) => {
              const candidateVotes = votes[candidate.userId] || 0;

              return (
                <div
                  key={candidate.userId}
                  className={`p-6 rounded-aga border-2 transition-all ${
                    candidateVotes > 0
                      ? 'border-primary bg-primary/5'
                      : 'border-gray-200 bg-white'
                  }`}
                >
                  <div className="flex items-start gap-4 mb-4">
                    {/* Avatar */}
                    <div className="w-16 h-16 rounded-full bg-gradient-accent flex items-center justify-center text-white font-bold text-xl flex-shrink-0">
                      {candidate.avatar}
                    </div>

                    {/* Info */}
                    <div className="flex-1">
                      <h3 className="text-xl font-bold text-text-dark mb-1">
                        {candidate.name}
                      </h3>
                      <p className="text-sm text-text-gray mb-2">
                        {candidate.position}
                      </p>
                      <AGAPill variant="primary" size="sm">
                        {candidate.category}
                      </AGAPill>
                    </div>

                    {/* Current Votes */}
                    <div className="text-right">
                      <div className="text-2xl font-black text-text-dark">
                        {candidate.votes.toLocaleString()}
                      </div>
                      <div className="text-xs text-text-gray">current votes</div>
                    </div>
                  </div>

                  {/* Manifesto */}
                  <p className="text-sm text-text-gray mb-4">
                    {candidate.manifesto}
                  </p>

                  {/* Vote Slider */}
                  <div>
                    <div className="flex items-center justify-between mb-2">
                      <label className="text-sm font-semibold text-text-dark">
                        Your Votes
                      </label>
                      <span className="text-lg font-bold text-primary">
                        {candidateVotes} vote{candidateVotes !== 1 ? 's' : ''}
                      </span>
                    </div>
                    <div className="flex items-center gap-3">
                      <input
                        type="range"
                        min="0"
                        max="4"
                        value={candidateVotes}
                        onChange={(e) =>
                          handleVoteChange(candidate.userId, parseInt(e.target.value))
                        }
                        className="flex-1 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-primary"
                      />
                      <div className="flex gap-1">
                        {[0, 1, 2, 3, 4].map((num) => (
                          <button
                            key={num}
                            onClick={() => handleVoteChange(candidate.userId, num)}
                            className={`w-10 h-10 rounded-lg font-bold transition-all ${
                              candidateVotes === num
                                ? 'bg-primary text-white'
                                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                            }`}
                          >
                            {num}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Summary & Submit */}
          <div className="flex items-center justify-between pt-6 border-t border-gray-200">
            <div>
              <p className="text-sm text-text-gray mb-1">Total Votes to Cast</p>
              <p className="text-3xl font-black text-text-dark">
                {totalVotes} vote{totalVotes !== 1 ? 's' : ''}
              </p>
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
                disabled={!hasVoted}
                leftIcon={<Vote className="w-5 h-5" />}
              >
                Submit Votes
              </AGAButton>
            </div>
          </div>
        </AGACard>
      </div>
    </div>
  );
}
