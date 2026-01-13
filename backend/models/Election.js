const mongoose = require('mongoose');

// Candidate schema (embedded in Election)
const CandidateSchema = new mongoose.Schema({
    candidateId: { type: String, required: true },
    userId: { type: String, required: true },
    name: { type: String, required: true },
    party: { type: String, default: '' },
    bio: { type: String, default: '' },
    avatarURL: { type: String, default: '' },
    votesReceived: { type: Number, default: 0 }
});

// Election schema
const ElectionSchema = new mongoose.Schema({
    electionId: { type: String, required: true, unique: true },
    title: { type: String, required: true },
    description: { type: String, default: '' },
    position: { type: String, required: true },
    country: { type: String, default: 'Global' },
    region: { type: String, default: '' },
    
    // Election dates
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    
    // Status: upcoming, active, completed
    status: { 
        type: String, 
        enum: ['upcoming', 'active', 'completed'],
        default: 'upcoming'
    },
    
    // Candidates
    candidates: [CandidateSchema],
    
    // Total votes cast
    totalVotes: { type: Number, default: 0 },
    
    // Metadata
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

// Election Vote schema - tracks individual votes
const ElectionVoteSchema = new mongoose.Schema({
    voteId: { type: String, required: true, unique: true },
    electionId: { type: String, required: true },
    userId: { type: String, required: true },
    candidateId: { type: String, required: true },
    voteCount: { type: Number, default: 1 },
    
    // Transaction info (for blockchain simulation)
    transactionHash: { type: String, default: '' },
    blockNumber: { type: Number, default: 0 },
    
    votedAt: { type: Date, default: Date.now }
});

// Compound index to prevent double voting
ElectionVoteSchema.index({ electionId: 1, userId: 1 }, { unique: true });

const Election = mongoose.model('Election', ElectionSchema);
const ElectionVote = mongoose.model('ElectionVote', ElectionVoteSchema);

module.exports = { Election, ElectionVote };

