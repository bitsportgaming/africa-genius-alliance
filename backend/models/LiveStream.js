const mongoose = require('mongoose');

const liveStreamSchema = new mongoose.Schema({
    hostId: {
        type: String,
        required: true,
        index: true
    },
    hostName: {
        type: String,
        required: true
    },
    hostAvatar: {
        type: String,
        default: null
    },
    hostPosition: {
        type: String,
        default: ''
    },
    title: {
        type: String,
        required: true,
        maxlength: 100
    },
    description: {
        type: String,
        default: '',
        maxlength: 500
    },
    thumbnailURL: {
        type: String,
        default: null
    },
    status: {
        type: String,
        enum: ['scheduled', 'live', 'ended'],
        default: 'live'
    },
    scheduledStartTime: {
        type: Date,
        default: null
    },
    actualStartTime: {
        type: Date,
        default: Date.now
    },
    endTime: {
        type: Date,
        default: null
    },
    viewerCount: {
        type: Number,
        default: 0
    },
    peakViewerCount: {
        type: Number,
        default: 0
    },
    totalViews: {
        type: Number,
        default: 0
    },
    currentViewers: [{
        type: String  // Array of user IDs currently watching
    }],
    likesCount: {
        type: Number,
        default: 0
    },
    likedBy: [{
        type: String
    }],
    commentsCount: {
        type: Number,
        default: 0
    },
    category: {
        type: String,
        default: 'general'
    },
    tags: [{
        type: String
    }],
    isRecorded: {
        type: Boolean,
        default: false
    },
    recordingURL: {
        type: String,
        default: null
    },
    streamKey: {
        type: String,
        default: null
    }
}, {
    timestamps: true
});

// Index for finding active streams
liveStreamSchema.index({ status: 1, createdAt: -1 });
liveStreamSchema.index({ hostId: 1, status: 1 });

module.exports = mongoose.model('LiveStream', liveStreamSchema);

