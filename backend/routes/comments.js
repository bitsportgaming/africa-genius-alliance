const express = require('express');
const router = express.Router();
const Comment = require('../models/Comment');
const Post = require('../models/Post');

// GET /api/comments/:postId - Get comments for a post
router.get('/:postId', async (req, res) => {
    try {
        const { postId } = req.params;
        const { page = 1, limit = 20 } = req.query;

        const comments = await Comment.find({ 
            postId, 
            isDeleted: false,
            parentId: null // Only top-level comments
        })
            .sort({ createdAt: -1 })
            .skip((page - 1) * limit)
            .limit(parseInt(limit));

        const total = await Comment.countDocuments({ postId, isDeleted: false, parentId: null });

        res.json({
            success: true,
            data: comments,
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

// GET /api/comments/:postId/:commentId/replies - Get replies to a comment
router.get('/:postId/:commentId/replies', async (req, res) => {
    try {
        const { commentId } = req.params;

        const replies = await Comment.find({ 
            parentId: commentId, 
            isDeleted: false 
        }).sort({ createdAt: 1 });

        res.json({ success: true, data: replies });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/comments/:postId - Create a comment
router.post('/:postId', async (req, res) => {
    try {
        const { postId } = req.params;
        const { authorId, authorName, authorAvatar, content, parentId } = req.body;

        if (!authorId || !content) {
            return res.status(400).json({ success: false, error: 'authorId and content are required' });
        }

        const post = await Post.findById(postId);
        if (!post) {
            return res.status(404).json({ success: false, error: 'Post not found' });
        }

        const comment = new Comment({
            postId,
            authorId,
            authorName: authorName || 'Anonymous',
            authorAvatar,
            content,
            parentId: parentId || null
        });

        await comment.save();

        // Update post's comment count
        post.commentsCount += 1;
        await post.save();

        // If it's a reply, update parent's reply count
        if (parentId) {
            await Comment.findByIdAndUpdate(parentId, { $inc: { repliesCount: 1 } });
        }

        res.status(201).json({ success: true, data: comment });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/comments/:postId/:commentId/like - Like/unlike a comment
router.post('/:postId/:commentId/like', async (req, res) => {
    try {
        const { commentId } = req.params;
        const { userId } = req.body;

        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }

        const comment = await Comment.findById(commentId);
        if (!comment) {
            return res.status(404).json({ success: false, error: 'Comment not found' });
        }

        const likedIndex = comment.likedBy.indexOf(userId);
        let liked = false;

        if (likedIndex === -1) {
            comment.likedBy.push(userId);
            comment.likesCount += 1;
            liked = true;
        } else {
            comment.likedBy.splice(likedIndex, 1);
            comment.likesCount -= 1;
        }

        await comment.save();
        res.json({ success: true, data: comment, liked });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// DELETE /api/comments/:postId/:commentId - Delete a comment
router.delete('/:postId/:commentId', async (req, res) => {
    try {
        const { postId, commentId } = req.params;
        const { authorId } = req.body;

        const comment = await Comment.findById(commentId);
        if (!comment) {
            return res.status(404).json({ success: false, error: 'Comment not found' });
        }

        if (comment.authorId !== authorId) {
            return res.status(403).json({ success: false, error: 'Not authorized' });
        }

        comment.isDeleted = true;
        comment.content = '[Deleted]';
        await comment.save();

        // Update post's comment count
        await Post.findByIdAndUpdate(postId, { $inc: { commentsCount: -1 } });

        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

