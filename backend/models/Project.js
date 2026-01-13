const mongoose = require('mongoose');

const projectSchema = new mongoose.Schema({
    projectId: {
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
        enum: ['technology', 'education', 'health', 'trade', 'environment', 'governance', 'arts', 'agriculture'],
        required: true
    },
    creatorId: {
        type: String,
        required: true
    },
    creatorName: {
        type: String,
        required: true
    },
    fundingGoal: {
        type: Number,
        required: true,
        default: 0
    },
    fundingRaised: {
        type: Number,
        default: 0
    },
    currency: {
        type: String,
        default: 'USD'
    },
    status: {
        type: String,
        enum: ['draft', 'active', 'funded', 'completed', 'cancelled'],
        default: 'active'
    },
    imageURL: {
        type: String,
        default: null
    },
    location: {
        country: { type: String, default: '' },
        region: { type: String, default: '' }
    },
    votesCount: {
        type: Number,
        default: 0
    },
    supportersCount: {
        type: Number,
        default: 0
    },
    impactMetrics: {
        peopleHelped: { type: Number, default: 0 },
        jobsCreated: { type: Number, default: 0 },
        communitiesReached: { type: Number, default: 0 }
    },
    milestones: [{
        title: String,
        description: String,
        targetAmount: Number,
        completed: { type: Boolean, default: false },
        completedAt: Date
    }],
    updates: [{
        title: String,
        content: String,
        createdAt: { type: Date, default: Date.now }
    }],
    isNationalProject: {
        type: Boolean,
        default: false
    },
    endDate: {
        type: Date,
        default: null
    }
}, {
    timestamps: true
});

projectSchema.index({ category: 1, status: 1 });
projectSchema.index({ creatorId: 1 });
projectSchema.index({ isNationalProject: 1, status: 1 });

module.exports = mongoose.model('Project', projectSchema);

