const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true,
        index: true
    },
    type: {
        type: String,
        enum: ['post', 'vote', 'follow', 'comment', 'mention', 'system'],
        required: true
    },
    title: {
        type: String,
        required: true
    },
    message: {
        type: String,
        required: true
    },
    // Reference to related content
    relatedPostId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Post'
    },
    relatedUserId: {
        type: String
    },
    relatedUserName: {
        type: String
    },
    // Read status
    isRead: {
        type: Boolean,
        default: false
    },
    // Additional metadata
    metadata: {
        type: mongoose.Schema.Types.Mixed
    }
}, {
    timestamps: true
});

// Index for faster queries
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, isRead: 1 });

module.exports = mongoose.model('Notification', notificationSchema);

