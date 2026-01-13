const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true,
        unique: true
    },
    username: {
        type: String,
        required: true,
        unique: true
    },
    displayName: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    passwordHash: {
        type: String,
        required: true
    },
    profileImageURL: {
        type: String,
        default: null
    },
    bio: {
        type: String,
        default: ''
    },
    country: {
        type: String,
        default: ''
    },
    role: {
        type: String,
        enum: ['regular', 'genius', 'admin', 'superadmin'],
        default: 'regular'
    },
    status: {
        type: String,
        enum: ['active', 'suspended', 'banned', 'pending'],
        default: 'active'
    },
    suspendedUntil: {
        type: Date,
        default: null
    },
    suspensionReason: {
        type: String,
        default: ''
    },
    lastLoginAt: {
        type: Date,
        default: null
    },
    positionTitle: {
        type: String,
        default: ''
    },
    isVerified: {
        type: Boolean,
        default: false
    },
    followersCount: {
        type: Number,
        default: 0
    },
    followingCount: {
        type: Number,
        default: 0
    },
    votesReceived: {
        type: Number,
        default: 0
    },
    votesCast: {
        type: Number,
        default: 0
    },
    donationsTotal: {
        type: Number,
        default: 0
    },
    profileViews: {
        type: Number,
        default: 0
    },
    positionCategory: {
        type: String,
        default: ''
    },
    manifestoShort: {
        type: String,
        default: ''
    },
    // Genius onboarding fields
    problemSolved: {
        type: String,
        default: ''
    },
    proofLinks: [{
        type: String
    }],
    credentials: [{
        type: String
    }],
    videoIntroURL: {
        type: String,
        default: null
    },
    onboardingCompleted: {
        type: Boolean,
        default: false
    },
    // 24h stats tracking
    stats24h: {
        votesDelta: { type: Number, default: 0 },
        followersDelta: { type: Number, default: 0 },
        rankDelta: { type: Number, default: 0 },
        profileViewsDelta: { type: Number, default: 0 },
        lastUpdated: { type: Date, default: Date.now }
    },
    following: [{
        type: String
    }],
    followers: [{
        type: String
    }]
}, {
    timestamps: true
});

module.exports = mongoose.model('User', userSchema);

