const express = require('express');
const router = express.Router();
const User = require('../models/User');
const crypto = require('crypto');

// Helper function to generate unique ID
function generateUniqueId() {
    return crypto.randomBytes(16).toString('hex');
}

// GET /api/users/geniuses - Get geniuses by category
router.get('/geniuses', async (req, res) => {
    try {
        const { category, limit = 50 } = req.query;
        const query = { role: 'genius' };

        if (category) {
            // Match category in positionTitle or bio (case-insensitive)
            query.$or = [
                { positionTitle: { $regex: category, $options: 'i' } },
                { bio: { $regex: category, $options: 'i' } },
                { category: { $regex: category, $options: 'i' } }
            ];
        }

        const geniuses = await User.find(query)
            .sort({ votesReceived: -1 })
            .limit(parseInt(limit));

        res.json({ success: true, data: geniuses });
    } catch (error) {
        console.error('Get geniuses by category error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/users - Get all users (for leaderboard, etc.)
router.get('/', async (req, res) => {
    try {
        const { role, limit = 50 } = req.query;
        const query = {};
        if (role) query.role = role;

        const users = await User.find(query)
            .sort({ votesReceived: -1 })
            .limit(parseInt(limit));

        res.json({ success: true, data: users });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/users/:userId - Get a single user
router.get('/:userId', async (req, res) => {
    try {
        const user = await User.findOne({ userId: req.params.userId });
        if (!user) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }
        res.json({ success: true, data: user });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/users - Create or update user
router.post('/', async (req, res) => {
    try {
        const { userId, username, displayName, email, profileImageURL, bio, country, role, positionTitle } = req.body;
        
        let user = await User.findOne({ userId });
        
        if (user) {
            // Update existing user
            Object.assign(user, { displayName, profileImageURL, bio, country, role, positionTitle });
            await user.save();
        } else {
            // Create new user
            user = new User({
                userId: userId || generateUniqueId(),
                username,
                displayName,
                email,
                profileImageURL,
                bio,
                country,
                role: role || 'regular',
                positionTitle
            });
            await user.save();
        }

        res.status(201).json({ success: true, data: user });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/users/:userId/stats - Get user stats for home screen
router.get('/:userId/stats', async (req, res) => {
    try {
        const { userId } = req.params;
        // Support both custom userId and MongoDB _id
        let user = await User.findOne({ userId: userId });
        if (!user) {
            // Try finding by MongoDB _id
            try {
                user = await User.findById(userId);
            } catch (e) {
                // Invalid ObjectId format, ignore
            }
        }
        if (!user) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }

        // Increment profile views
        user.profileViews = (user.profileViews || 0) + 1;
        user.stats24h = user.stats24h || { votesDelta: 0, followersDelta: 0, rankDelta: 0, profileViewsDelta: 0 };
        user.stats24h.profileViewsDelta = (user.stats24h.profileViewsDelta || 0) + 1;
        await user.save();

        // Calculate rank among all geniuses
        let rank = 1;
        if (user.role === 'genius') {
            const higherRanked = await User.countDocuments({
                role: 'genius',
                votesReceived: { $gt: user.votesReceived || 0 }
            });
            rank = higherRanked + 1;
        }

        // Get top geniuses for leaderboard
        const topGeniuses = await User.find({ role: 'genius' })
            .sort({ votesReceived: -1 })
            .limit(10)
            .select('userId username displayName profileImageURL positionTitle country isVerified votesReceived followersCount');

        res.json({
            success: true,
            data: {
                profile: {
                    userId: user.userId,
                    displayName: user.displayName,
                    positionCategory: user.positionCategory || 'General',
                    positionTitle: user.positionTitle || '',
                    manifestoShort: user.manifestoShort || '',
                    isVerified: user.isVerified,
                    rank: rank,
                    votesTotal: user.votesReceived || 0,
                    followersTotal: user.followersCount || 0,
                    profileViews: user.profileViews || 0,
                    stats24h: {
                        votesDelta: user.stats24h?.votesDelta || 0,
                        followersDelta: user.stats24h?.followersDelta || 0,
                        rankDelta: user.stats24h?.rankDelta || 0,
                        profileViewsDelta: user.stats24h?.profileViewsDelta || 0
                    }
                },
                topGeniuses: topGeniuses.map((g, index) => ({
                    id: g.userId,
                    name: g.displayName,
                    positionTitle: g.positionTitle || 'Genius Candidate',
                    country: g.country || '',
                    avatarURL: g.profileImageURL,
                    isVerified: g.isVerified || false,
                    rank: index + 1,
                    votes: g.votesReceived || 0
                })),
                // Supporter stats (for regular users)
                supporterStats: {
                    votesCast: user.votesCast || 0,
                    followsTotal: user.followingCount || 0,
                    donationsTotal: user.donationsTotal || 0
                }
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/users/:userId/vote - Vote for a genius
router.post('/:userId/vote', async (req, res) => {
    try {
        const { voterId } = req.body;
        const targetUserId = req.params.userId;

        if (!voterId || voterId === targetUserId) {
            return res.status(400).json({ success: false, error: 'Invalid vote' });
        }

        const targetUser = await User.findOne({ userId: targetUserId });
        if (!targetUser) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }

        if (targetUser.role !== 'genius') {
            return res.status(400).json({ success: false, error: 'Can only vote for geniuses' });
        }

        // Increment votes received for target
        targetUser.votesReceived = (targetUser.votesReceived || 0) + 1;
        targetUser.stats24h = targetUser.stats24h || { votesDelta: 0, followersDelta: 0, rankDelta: 0, profileViewsDelta: 0 };
        targetUser.stats24h.votesDelta = (targetUser.stats24h.votesDelta || 0) + 1;
        await targetUser.save();

        // Also track votes cast by the voter
        const voter = await User.findOne({ userId: voterId });
        if (voter) {
            voter.votesCast = (voter.votesCast || 0) + 1;
            await voter.save();
        }

        res.json({
            success: true,
            data: {
                votesReceived: targetUser.votesReceived,
                votesCast: voter?.votesCast || 0,
                message: `Vote recorded for ${targetUser.displayName}`
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/users/:userId/follow - Follow/unfollow a user
router.post('/:userId/follow', async (req, res) => {
    try {
        const { followerId } = req.body;
        const targetUserId = req.params.userId;

        if (!followerId || followerId === targetUserId) {
            return res.status(400).json({ success: false, error: 'Invalid follower' });
        }

        const [targetUser, follower] = await Promise.all([
            User.findOne({ userId: targetUserId }),
            User.findOne({ userId: followerId })
        ]);

        if (!targetUser || !follower) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }

        const isFollowing = follower.following.includes(targetUserId);

        // Initialize stats24h if not present
        targetUser.stats24h = targetUser.stats24h || { votesDelta: 0, followersDelta: 0, rankDelta: 0, profileViewsDelta: 0 };

        if (isFollowing) {
            follower.following = follower.following.filter(id => id !== targetUserId);
            targetUser.followers = targetUser.followers.filter(id => id !== followerId);
            follower.followingCount = Math.max(0, follower.followingCount - 1);
            targetUser.followersCount = Math.max(0, targetUser.followersCount - 1);
            targetUser.stats24h.followersDelta = Math.max(0, (targetUser.stats24h.followersDelta || 0) - 1);
        } else {
            follower.following.push(targetUserId);
            targetUser.followers.push(followerId);
            follower.followingCount += 1;
            targetUser.followersCount += 1;
            targetUser.stats24h.followersDelta = (targetUser.stats24h.followersDelta || 0) + 1;
        }

        await Promise.all([follower.save(), targetUser.save()]);

        res.json({ 
            success: true, 
            following: !isFollowing,
            targetUser,
            follower
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

