const mongoose = require('mongoose');

const conversationSchema = new mongoose.Schema({
    participants: [{
        type: String,
        required: true
    }],
    participantNames: [{
        type: String
    }],
    participantAvatars: [{
        type: String
    }],
    lastMessage: {
        content: String,
        senderId: String,
        senderName: String,
        timestamp: Date
    },
    unreadCount: {
        type: Map,
        of: Number,
        default: {}
    },
    isGroup: {
        type: Boolean,
        default: false
    },
    groupName: {
        type: String
    },
    groupAvatar: {
        type: String
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

// Index for faster participant lookups
conversationSchema.index({ participants: 1 });
conversationSchema.index({ updatedAt: -1 });

module.exports = mongoose.model('Conversation', conversationSchema);

