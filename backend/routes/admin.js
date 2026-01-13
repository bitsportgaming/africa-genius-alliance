const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Post = require('../models/Post');
const { Election } = require('../models/Election');
const crypto = require('crypto');
const { generateToken, isAdmin, isSuperAdmin } = require('../middleware/admin');

// Simple password hashing
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

function verifyPassword(password, hash) {
    return hashPassword(password) === hash;
}

// POST /api/admin/login - Admin login
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ success: false, error: 'Email and password required' });
        }

        const user = await User.findOne({ email: email.toLowerCase() });

        if (!user) {
            return res.status(401).json({ success: false, error: 'Invalid credentials' });
        }

        if (!['admin', 'superadmin'].includes(user.role)) {
            return res.status(403).json({ success: false, error: 'Admin access required' });
        }

        if (!verifyPassword(password, user.passwordHash)) {
            return res.status(401).json({ success: false, error: 'Invalid credentials' });
        }

        if (user.status !== 'active') {
            return res.status(403).json({ success: false, error: 'Account is not active' });
        }

        // Update last login
        user.lastLoginAt = new Date();
        await user.save();

        const token = generateToken(user.userId, user.role);
        const userResponse = user.toObject();
        delete userResponse.passwordHash;

        res.json({ success: true, data: { user: userResponse, token } });
    } catch (error) {
        console.error('Admin login error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/admin/stats - Dashboard statistics
router.get('/stats', isAdmin, async (req, res) => {
    try {
        const [totalUsers, totalGeniuses, totalPosts, activeElections] = await Promise.all([
            User.countDocuments(),
            User.countDocuments({ role: 'genius' }),
            Post.countDocuments(),
            Election.countDocuments({ status: 'active' })
        ]);

        const recentUsers = await User.find()
            .sort({ createdAt: -1 })
            .limit(5)
            .select('-passwordHash');

        const pendingGeniuses = await User.countDocuments({ 
            role: 'genius', 
            isVerified: false 
        });

        res.json({
            success: true,
            data: {
                totalUsers,
                totalGeniuses,
                totalPosts,
                activeElections,
                pendingGeniuses,
                recentUsers
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/admin/users - Get all users with filtering
router.get('/users', isAdmin, async (req, res) => {
    try {
        const { page = 1, limit = 20, role, status, search, sort = '-createdAt' } = req.query;
        const query = {};

        if (role) query.role = role;
        if (status) query.status = status;
        if (search) {
            query.$or = [
                { displayName: { $regex: search, $options: 'i' } },
                { username: { $regex: search, $options: 'i' } },
                { email: { $regex: search, $options: 'i' } }
            ];
        }

        const users = await User.find(query)
            .select('-passwordHash')
            .sort(sort)
            .skip((page - 1) * limit)
            .limit(parseInt(limit));

        const total = await User.countDocuments(query);

        res.json({
            success: true,
            data: users,
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

// PUT /api/admin/users/:userId - Update user
router.put('/users/:userId', isAdmin, async (req, res) => {
    try {
        const { role, status, isVerified, suspendedUntil, suspensionReason } = req.body;
        const user = await User.findOne({ userId: req.params.userId });

        if (!user) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }

        // Prevent modifying superadmins unless you are superadmin
        if (user.role === 'superadmin' && req.user.role !== 'superadmin') {
            return res.status(403).json({ success: false, error: 'Cannot modify superadmin' });
        }

        if (role !== undefined) user.role = role;
        if (status !== undefined) user.status = status;
        if (isVerified !== undefined) user.isVerified = isVerified;
        if (suspendedUntil !== undefined) user.suspendedUntil = suspendedUntil;
        if (suspensionReason !== undefined) user.suspensionReason = suspensionReason;

        await user.save();
        const userResponse = user.toObject();
        delete userResponse.passwordHash;

        res.json({ success: true, data: userResponse });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// DELETE /api/admin/users/:userId - Delete user (superadmin only)
router.delete('/users/:userId', isSuperAdmin, async (req, res) => {
    try {
        const user = await User.findOne({ userId: req.params.userId });

        if (!user) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }

        if (user.role === 'superadmin') {
            return res.status(403).json({ success: false, error: 'Cannot delete superadmin' });
        }

        await User.deleteOne({ userId: req.params.userId });
        await Post.deleteMany({ authorId: req.params.userId });

        res.json({ success: true, message: 'User and associated posts deleted' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/admin/posts - Get all posts with filtering
router.get('/posts', isAdmin, async (req, res) => {
    try {
        const { page = 1, limit = 20, status, search, sort = '-createdAt' } = req.query;
        const query = {};

        if (status === 'flagged') query.isFlagged = true;
        if (status === 'featured') query.isFeatured = true;
        if (search) {
            query.content = { $regex: search, $options: 'i' };
        }

        const posts = await Post.find(query)
            .sort(sort)
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

// PUT /api/admin/posts/:postId - Update post (feature, unflag, etc.)
router.put('/posts/:postId', isAdmin, async (req, res) => {
    try {
        const { isFeatured, isFlagged, status } = req.body;
        const post = await Post.findOne({ postId: req.params.postId });

        if (!post) {
            return res.status(404).json({ success: false, error: 'Post not found' });
        }

        if (isFeatured !== undefined) post.isFeatured = isFeatured;
        if (isFlagged !== undefined) post.isFlagged = isFlagged;
        if (status !== undefined) post.status = status;

        await post.save();
        res.json({ success: true, data: post });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// DELETE /api/admin/posts/:postId - Delete post
router.delete('/posts/:postId', isAdmin, async (req, res) => {
    try {
        const result = await Post.deleteOne({ postId: req.params.postId });

        if (result.deletedCount === 0) {
            return res.status(404).json({ success: false, error: 'Post not found' });
        }

        res.json({ success: true, message: 'Post deleted' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/admin/elections - Get all elections
router.get('/elections', isAdmin, async (req, res) => {
    try {
        const { page = 1, limit = 20, status, sort = '-createdAt' } = req.query;
        const query = {};

        if (status) query.status = status;

        const elections = await Election.find(query)
            .sort(sort)
            .skip((page - 1) * limit)
            .limit(parseInt(limit));

        const total = await Election.countDocuments(query);

        res.json({
            success: true,
            data: elections,
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

// POST /api/admin/elections - Create election
router.post('/elections', isAdmin, async (req, res) => {
    try {
        const { title, description, position, country, region, startDate, endDate, candidates } = req.body;

        const election = new Election({
            electionId: crypto.randomBytes(8).toString('hex'),
            title,
            description,
            position,
            country: country || 'Global',
            region: region || '',
            startDate: new Date(startDate),
            endDate: new Date(endDate),
            status: new Date(startDate) <= new Date() ? 'active' : 'upcoming',
            candidates: (candidates || []).map(c => ({
                candidateId: crypto.randomBytes(8).toString('hex'),
                userId: c.userId,
                name: c.name,
                party: c.party || '',
                bio: c.bio || '',
                avatarURL: c.avatarURL || '',
                votesReceived: 0
            }))
        });

        await election.save();
        res.status(201).json({ success: true, data: election });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// PUT /api/admin/elections/:electionId - Update election
router.put('/elections/:electionId', isAdmin, async (req, res) => {
    try {
        const election = await Election.findOne({ electionId: req.params.electionId });

        if (!election) {
            return res.status(404).json({ success: false, error: 'Election not found' });
        }

        const allowedUpdates = ['title', 'description', 'status', 'startDate', 'endDate'];
        allowedUpdates.forEach(field => {
            if (req.body[field] !== undefined) {
                election[field] = field.includes('Date') ? new Date(req.body[field]) : req.body[field];
            }
        });

        await election.save();
        res.json({ success: true, data: election });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// DELETE /api/admin/elections/:electionId - Delete election
router.delete('/elections/:electionId', isAdmin, async (req, res) => {
    try {
        const result = await Election.deleteOne({ electionId: req.params.electionId });

        if (result.deletedCount === 0) {
            return res.status(404).json({ success: false, error: 'Election not found' });
        }

        res.json({ success: true, message: 'Election deleted' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/admin/posts - Create admin post
router.post('/posts', isAdmin, async (req, res) => {
    try {
        const { content, mediaURLs } = req.body;

        if (!content || content.trim().length === 0) {
            return res.status(400).json({ success: false, error: 'Content is required' });
        }

        // Get admin user info
        const adminUser = await User.findOne({ userId: req.user.userId });
        if (!adminUser) {
            return res.status(404).json({ success: false, error: 'Admin user not found' });
        }

        const post = new Post({
            authorId: adminUser.userId,
            authorName: adminUser.displayName || 'AGA Admin',
            authorAvatar: adminUser.profileImageURL || null,
            authorPosition: 'Africa Genius Alliance',
            content: content.trim(),
            mediaURLs: mediaURLs || [],
            mediaType: mediaURLs && mediaURLs.length > 0 ? 'image' : 'none',
            postType: mediaURLs && mediaURLs.length > 0 ? 'image' : 'text',
            isAdminPost: true,
            authorRole: adminUser.role,
            isFeatured: true // Admin posts are automatically featured
        });

        await post.save();
        res.status(201).json({ success: true, data: post });
    } catch (error) {
        console.error('Admin post creation error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/admin/create-admin - Create admin user (superadmin only)
router.post('/create-admin', isSuperAdmin, async (req, res) => {
    try {
        const { username, email, password, displayName, role = 'admin' } = req.body;

        if (!['admin', 'superadmin'].includes(role)) {
            return res.status(400).json({ success: false, error: 'Invalid role' });
        }

        const existingUser = await User.findOne({ $or: [{ email }, { username }] });
        if (existingUser) {
            return res.status(400).json({ success: false, error: 'User already exists' });
        }

        const user = new User({
            userId: crypto.randomBytes(16).toString('hex'),
            username: username.toLowerCase(),
            displayName,
            email: email.toLowerCase(),
            passwordHash: hashPassword(password),
            role,
            status: 'active',
            isVerified: true
        });

        await user.save();
        const userResponse = user.toObject();
        delete userResponse.passwordHash;

        res.status(201).json({ success: true, data: userResponse });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

