const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const crypto = require('crypto');
const Post = require('../models/Post');
const User = require('../models/User');
const Notification = require('../models/Notification');

// Helper function to generate unique ID
function generateUniqueId() {
    return crypto.randomBytes(16).toString('hex');
}

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueName = `${generateUniqueId()}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    }
});

const fileFilter = (req, file, cb) => {
    const allowedImageTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    const allowedVideoTypes = [
        'video/mp4',
        'video/quicktime',
        'video/x-m4v',
        'video/avi',
        'video/x-matroska',
        'video/webm',
        'video/3gpp',
        'video/x-msvideo'
    ];

    if (allowedImageTypes.includes(file.mimetype) || allowedVideoTypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        console.log('Rejected file with mimetype:', file.mimetype);
        cb(new Error(`Invalid file type: ${file.mimetype}. Only images and videos are allowed.`), false);
    }
};

const upload = multer({
    storage,
    fileFilter,
    limits: { fileSize: 500 * 1024 * 1024 } // 500MB limit for videos
});

// GET /api/posts - Get all posts (feed)
router.get('/', async (req, res) => {
    try {
        const { page = 1, limit = 20, authorId, userId, feedType = 'all' } = req.query;
        const query = { isActive: true };

        console.log('📝 Posts API called with:', { authorId, userId, feedType });

        // Filter by specific author
        if (authorId) {
            query.authorId = authorId;
        }
        // Filter by feed type for the requesting user
        else if (userId && feedType) {
            if (feedType === 'own') {
                // Show only user's own posts
                query.authorId = userId;
            } else if (feedType === 'following') {
                // Show posts from users they follow
                const User = require('../models/User');
                const mongoose = require('mongoose');

                // Try to find user by userId first, then by _id
                let user = await User.findOne({ userId: userId });
                if (!user && mongoose.Types.ObjectId.isValid(userId)) {
                    user = await User.findById(userId);
                }

                console.log('📝 User found for following filter:', user ? {
                    userId: user.userId,
                    _id: user._id.toString(),
                    following: user.following,
                    followingCount: user.following?.length || 0
                } : 'NOT FOUND');

                if (user && user.following && user.following.length > 0) {
                    query.authorId = { $in: user.following };
                    console.log('📝 Filtering posts by authorIds:', user.following);
                } else {
                    // If not following anyone, return empty array
                    console.log('📝 User not following anyone or user not found, returning empty array');
                    return res.json({
                        success: true,
                        data: [],
                        pagination: {
                            page: parseInt(page),
                            limit: parseInt(limit),
                            total: 0,
                            pages: 0
                        }
                    });
                }
            }
            // feedType === 'all' shows all posts (default behavior)
        }

        const posts = await Post.find(query)
            .sort({ createdAt: -1 })
            .skip((page - 1) * limit)
            .limit(parseInt(limit));

        const total = await Post.countDocuments(query);

        res.json({
            success: true,
            data: posts,
            pagination: {
                page: parseInt(page),
                limit: parseInt(limit),
                total,
                pages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/posts/:id - Get a single post
router.get('/:id', async (req, res) => {
    try {
        const post = await Post.findById(req.params.id);
        if (!post) {
            return res.status(404).json({ success: false, error: 'Post not found' });
        }
        res.json({ success: true, data: post });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/posts - Create a new post with optional media
router.post('/', upload.array('media', 5), async (req, res) => {
    try {
        const { authorId, authorName, authorAvatar, authorPosition, authorCountry, content } = req.body;

        if (!authorId || !content) {
            return res.status(400).json({
                success: false,
                error: 'authorId and content are required'
            });
        }

        let mediaURLs = [];
        let mediaType = 'none';
        let postType = 'text';

        if (req.files && req.files.length > 0) {
            mediaURLs = req.files.map(file => `/uploads/${file.filename}`);
            const firstFile = req.files[0];
            if (firstFile.mimetype.startsWith('video/')) {
                mediaType = 'video';
                postType = 'video';
            } else {
                mediaType = 'image';
                postType = 'image';
            }
        }

        const post = new Post({
            authorId,
            authorName: authorName || 'Anonymous',
            authorAvatar: authorAvatar || null,
            authorPosition: authorPosition || '',
            authorCountry: authorCountry || '',
            content,
            mediaURLs,
            mediaType,
            postType
        });

        await post.save();

        // Create notifications for followers
        try {
            const followers = await User.find({ following: authorId });
            if (followers.length > 0) {
                const notificationPromises = followers.map(follower => {
                    return new Notification({
                        userId: follower.userId,
                        type: 'post',
                        title: `${authorName || 'A genius'} posted`,
                        message: content.substring(0, 100) + (content.length > 100 ? '...' : ''),
                        relatedPostId: post._id,
                        relatedUserId: authorId,
                        relatedUserName: authorName || 'Anonymous'
                    }).save();
                });
                await Promise.all(notificationPromises);
                console.log(`📬 Created ${followers.length} notifications for post ${post._id}`);
            }
        } catch (notifError) {
            console.error('Error creating notifications:', notifError);
            // Don't fail the post creation if notifications fail
        }

        res.status(201).json({ success: true, data: post });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/posts/:id/like - Like a post
router.post('/:id/like', async (req, res) => {
    try {
        const { userId } = req.body;
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }

        const post = await Post.findById(req.params.id);
        if (!post) {
            return res.status(404).json({ success: false, error: 'Post not found' });
        }

        const alreadyLiked = post.likedBy.includes(userId);
        if (alreadyLiked) {
            post.likedBy = post.likedBy.filter(id => id !== userId);
            post.likesCount = Math.max(0, post.likesCount - 1);
        } else {
            post.likedBy.push(userId);
            post.likesCount += 1;
        }

        await post.save();
        res.json({ success: true, data: post, liked: !alreadyLiked });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// DELETE /api/posts/:id - Delete a post
router.delete('/:id', async (req, res) => {
    try {
        const { authorId } = req.body;
        const post = await Post.findById(req.params.id);
        
        if (!post) {
            return res.status(404).json({ success: false, error: 'Post not found' });
        }
        if (post.authorId !== authorId) {
            return res.status(403).json({ success: false, error: 'Unauthorized' });
        }

        post.isActive = false;
        await post.save();
        res.json({ success: true, message: 'Post deleted' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

