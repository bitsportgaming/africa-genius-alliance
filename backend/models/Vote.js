const mongoose = require('mongoose');

const voteSchema = new mongoose.Schema({
    voterId: {
        type: String,
        required: true
    },
    targetId: {
        type: String,
        required: true
    },
    targetType: {
        type: String,
        enum: ['genius', 'project', 'proposal'],
        required: true
    },
    category: {
        type: String,
        default: null
    },
    voteWeight: {
        type: Number,
        default: 1
    },
    outcome: {
        type: String,
        enum: ['pending', 'counted', 'expired', 'voted', 'for', 'against', 'abstain', 'supported'],
        default: 'voted'
    }
}, {
    timestamps: true
});

// Index for efficient queries
voteSchema.index({ voterId: 1, targetId: 1, targetType: 1 }, { unique: true });
voteSchema.index({ targetId: 1, targetType: 1 });
voteSchema.index({ voterId: 1, createdAt: -1 });

module.exports = mongoose.model('Vote', voteSchema);

