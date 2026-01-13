const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const crypto = require('crypto');
const Post = require('../models/Post');

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
    const allowedVideoTypes = ['video/mp4', 'video/quicktime', 'video/x-m4v'];
    
    if (allowedImageTypes.includes(file.mimetype) || allowedVideoTypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('Invalid file type. Only images and videos are allowed.'), false);
    }
};

const upload = multer({
    storage,
    fileFilter,
    limits: { fileSize: 50 * 1024 * 1024 } // 50MB limit
});

// GET /api/posts - Get all posts (feed)
router.get('/', async (req, res) => {
    try {
        const { page = 1, limit = 20, authorId } = req.query;
        const query = { isActive: true };
        if (authorId) query.authorId = authorId;

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
        const { authorId, authorName, authorAvatar, authorPosition, content } = req.body;
        
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
            content,
            mediaURLs,
            mediaType,
            postType
        });

        await post.save();
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

