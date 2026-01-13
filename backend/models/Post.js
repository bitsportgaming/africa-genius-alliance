const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
    authorId: {
        type: String,
        required: true,
        index: true
    },
    authorName: {
        type: String,
        required: true
    },
    authorAvatar: {
        type: String,
        default: null
    },
    authorPosition: {
        type: String,
        default: ''
    },
    content: {
        type: String,
        required: true,
        maxlength: 500
    },
    mediaURLs: [{
        type: String
    }],
    mediaType: {
        type: String,
        enum: ['none', 'image', 'video'],
        default: 'none'
    },
    postType: {
        type: String,
        enum: ['text', 'image', 'video', 'liveAnnouncement'],
        default: 'text'
    },
    likesCount: {
        type: Number,
        default: 0
    },
    commentsCount: {
        type: Number,
        default: 0
    },
    sharesCount: {
        type: Number,
        default: 0
    },
    likedBy: [{
        type: String
    }],
    isActive: {
        type: Boolean,
        default: true
    },
    isFeatured: {
        type: Boolean,
        default: false
    },
    isFlagged: {
        type: Boolean,
        default: false
    },
    flaggedReason: {
        type: String,
        default: ''
    },
    isAdminPost: {
        type: Boolean,
        default: false
    },
    authorRole: {
        type: String,
        enum: ['regular', 'genius', 'admin', 'superadmin'],
        default: 'regular'
    },
    status: {
        type: String,
        enum: ['active', 'hidden', 'removed'],
        default: 'active'
    },
    moderatedBy: {
        type: String,
        default: null
    },
    moderatedAt: {
        type: Date,
        default: null
    }
}, {
    timestamps: true
});

// Index for efficient querying
postSchema.index({ createdAt: -1 });
postSchema.index({ authorId: 1, createdAt: -1 });

// Virtual for checking if a user liked the post
postSchema.methods.isLikedByUser = function(userId) {
    return this.likedBy.includes(userId);
};

module.exports = mongoose.model('Post', postSchema);

