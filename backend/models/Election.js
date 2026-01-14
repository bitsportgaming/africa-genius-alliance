const mongoose = require('mongoose');

// Candidate schema (embedded in Election)
const CandidateSchema = new mongoose.Schema({
    candidateId: { type: String, required: true },
    userId: { type: String, required: true },
    name: { type: String, required: true },
    party: { type: String, default: '' },
    bio: { type: String, default: '' },
    avatarURL: { type: String, default: '' },
    manifesto: { type: String, default: '' },
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
    totalVoters: { type: Number, default: 0 },

    // Blockchain fields for BNB Chain
    blockchain: {
        contractAddress: { type: String, default: '' },
        electionIdOnChain: { type: Number, default: 0 }, // Election ID on smart contract
        isDeployed: { type: Boolean, default: false },
        deployTxHash: { type: String, default: '' },
        lastSyncBlock: { type: Number, default: 0 },
        chainId: { type: Number, default: 56 } // 56 = BNB Mainnet, 97 = BNB Testnet
    },

    // Metadata
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

// Election Vote schema - tracks individual votes (classic: 1 vote per user per election)
const ElectionVoteSchema = new mongoose.Schema({
    voteId: { type: String, required: true, unique: true },
    electionId: { type: String, required: true },
    userId: { type: String, required: true },
    candidateId: { type: String, required: true },

    // BNB Chain blockchain transaction info
    blockchain: {
        transactionHash: { type: String, default: '' },
        blockNumber: { type: Number, default: 0 },
        blockHash: { type: String, default: '' },
        gasUsed: { type: String, default: '' },
        status: { type: String, enum: ['pending', 'confirmed', 'failed'], default: 'pending' },
        confirmedAt: { type: Date },
        chainId: { type: Number, default: 56 } // 56 = BNB Mainnet, 97 = BNB Testnet
    },

    votedAt: { type: Date, default: Date.now }
});

// Compound index to prevent double voting (1 vote per user per election)
ElectionVoteSchema.index({ electionId: 1, userId: 1 }, { unique: true });
ElectionVoteSchema.index({ 'blockchain.transactionHash': 1 });
ElectionVoteSchema.index({ electionId: 1, candidateId: 1 });

const Election = mongoose.model('Election', ElectionSchema);
const ElectionVote = mongoose.model('ElectionVote', ElectionVoteSchema);

module.exports = { Election, ElectionVote };

