const mongoose = require('mongoose');

const proposalSchema = new mongoose.Schema({
    proposalId: {
        type: String,
        required: true,
        unique: true
    },
    title: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: true
    },
    category: {
        type: String,
        enum: ['policy', 'funding', 'governance', 'community', 'technical'],
        required: true
    },
    proposerId: {
        type: String,
        required: true
    },
    proposerName: {
        type: String,
        required: true
    },
    status: {
        type: String,
        enum: ['draft', 'active', 'passed', 'rejected', 'expired'],
        default: 'active'
    },
    votesFor: {
        type: Number,
        default: 0
    },
    votesAgainst: {
        type: Number,
        default: 0
    },
    votesAbstain: {
        type: Number,
        default: 0
    },
    quorumRequired: {
        type: Number,
        default: 100 // Minimum votes needed
    },
    passingThreshold: {
        type: Number,
        default: 50 // Percentage needed to pass
    },
    startDate: {
        type: Date,
        default: Date.now
    },
    endDate: {
        type: Date,
        required: true
    },
    implementationDetails: {
        type: String,
        default: ''
    },
    impact: {
        type: String,
        default: ''
    }
}, {
    timestamps: true
});

proposalSchema.index({ status: 1, endDate: 1 });
proposalSchema.index({ proposerId: 1 });
proposalSchema.index({ category: 1, status: 1 });

module.exports = mongoose.model('Proposal', proposalSchema);

