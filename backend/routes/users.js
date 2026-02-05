const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Vote = require('../models/Vote');
const GeniusWaitlist = require('../models/GeniusWaitlist');
const crypto = require('crypto');
const multer = require('multer');
const path = require('path');

// Helper function to generate unique ID
function generateUniqueId() {
    return crypto.randomBytes(16).toString('hex');
}

// Configure multer for verification document uploads
const verificationStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueName = `verification-${generateUniqueId()}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    }
});

const verificationUpload = multer({
    storage: verificationStorage,
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
        if (allowedTypes.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Invalid file type. Only JPEG, PNG, and WebP images are allowed.'), false);
        }
    },
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

// POST /api/users/genius-waitlist - Join the genius waitlist
router.post('/genius-waitlist', async (req, res) => {
    try {
        const { userId, email, displayName } = req.body;

        // Validate required fields
        if (!userId || !email) {
            return res.status(400).json({
                success: false,
                error: 'userId and email are required'
            });
        }

        // Check if already on waitlist
        const existingEntry = await GeniusWaitlist.findOne({
            $or: [{ userId }, { email: email.toLowerCase() }]
        });

        if (existingEntry) {
            // Already on waitlist - return success (idempotent)
            return res.status(200).json({
                success: true,
                message: 'Already on the genius waitlist',
                data: {
                    submittedAt: existingEntry.submittedAt,
                    status: existingEntry.status
                }
            });
        }

        // Create new waitlist entry
        const waitlistEntry = new GeniusWaitlist({
            userId,
            email: email.toLowerCase(),
            displayName: displayName || 'Unknown',
            status: 'pending',
            submittedAt: new Date()
        });

        await waitlistEntry.save();

        console.log(`[Waitlist] New genius waitlist entry: ${email}`);

        // Return success response
        res.status(201).json({
            success: true,
            message: 'Successfully joined the genius waitlist',
            data: {
                submittedAt: waitlistEntry.submittedAt,
                status: waitlistEntry.status
            }
        });
    } catch (error) {
        console.error('Genius waitlist error:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'Failed to join waitlist'
        });
    }
});

// GET /api/users/search - Search geniuses by name, position, bio, or country
router.get('/search', async (req, res) => {
    try {
        const { q, limit = 20 } = req.query;

        if (!q || q.trim().length === 0) {
            return res.json({ success: true, data: [] });
        }

        const searchQuery = q.trim();

        // Search across multiple fields (case-insensitive)
        const geniuses = await User.find({
            role: 'genius',
            $or: [
                { displayName: { $regex: searchQuery, $options: 'i' } },
                { username: { $regex: searchQuery, $options: 'i' } },
                { positionTitle: { $regex: searchQuery, $options: 'i' } },
                { positionCategory: { $regex: searchQuery, $options: 'i' } },
                { bio: { $regex: searchQuery, $options: 'i' } },
                { country: { $regex: searchQuery, $options: 'i' } }
            ]
        })
            .sort({ votesReceived: -1 })
            .limit(parseInt(limit))
            .select('-passwordHash -email'); // Exclude sensitive fields

        console.log(`[Search] Query: "${searchQuery}", Found: ${geniuses.length} results`);

        res.json({ success: true, data: geniuses });
    } catch (error) {
        console.error('Search error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

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

        // Try to find user by userId first, then by _id
        let user = await User.findOne({ userId });
        if (!user && userId) {
            try {
                user = await User.findById(userId);
            } catch (e) {
                // Invalid ObjectId format, ignore
            }
        }

        if (user) {
            // Update existing user
            if (displayName !== undefined) user.displayName = displayName;
            if (profileImageURL !== undefined) user.profileImageURL = profileImageURL;
            if (bio !== undefined) user.bio = bio;
            if (country !== undefined) user.country = country;
            if (role !== undefined) user.role = role;
            if (positionTitle !== undefined) user.positionTitle = positionTitle;
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

/**
 * POST /api/users/:userId/vote - Upvote a genius
 *
 * This is for UPVOTING geniuses to increase their ranking/popularity.
 * This is NOT for formal election voting - use /api/elections/:id/vote for that.
 *
 * Upvoting is used for:
 * - General support of a genius on the platform
 * - Genius ranking/leaderboard positioning
 * - Expressing support without a formal election context
 *
 * Unlike election voting (which is 1 vote per election), upvoting can be done multiple times.
 */
router.post('/:userId/vote', async (req, res) => {
    try {
        const { voterId } = req.body;
        const targetUserId = req.params.userId;

        if (!voterId || voterId === targetUserId) {
            return res.status(400).json({ success: false, error: 'Invalid vote' });
        }

        // Helper function to find user by userId or _id
        const findUser = async (id) => {
            let user = await User.findOne({ userId: id });
            if (!user) {
                try {
                    user = await User.findById(id);
                } catch (e) {
                    // Invalid ObjectId format, ignore
                }
            }
            return user;
        };

        const targetUser = await findUser(targetUserId);
        if (!targetUser) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }

        if (targetUser.role !== 'genius') {
            return res.status(400).json({ success: false, error: 'Can only vote for geniuses' });
        }

        // Check if already voted (for one-vote-per-genius limit)
        const existingVote = await Vote.findOne({
            voterId,
            targetId: targetUser.userId,
            targetType: 'genius'
        });

        if (existingVote) {
            return res.status(400).json({ success: false, error: 'Already voted for this genius' });
        }

        // Create Vote record for history tracking
        const vote = new Vote({
            voterId,
            targetId: targetUser.userId,
            targetType: 'genius',
            outcome: 'voted',
            category: targetUser.positionCategory || 'general'
        });
        await vote.save();

        // Increment votes received for target
        targetUser.votesReceived = (targetUser.votesReceived || 0) + 1;
        targetUser.stats24h = targetUser.stats24h || { votesDelta: 0, followersDelta: 0, rankDelta: 0, profileViewsDelta: 0 };
        targetUser.stats24h.votesDelta = (targetUser.stats24h.votesDelta || 0) + 1;
        await targetUser.save();

        // Also track votes cast by the voter
        const voter = await findUser(voterId);
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

        // Helper function to find user by userId or _id
        const findUser = async (id) => {
            let user = await User.findOne({ userId: id });
            if (!user) {
                try {
                    user = await User.findById(id);
                } catch (e) {
                    // Invalid ObjectId format, ignore
                }
            }
            return user;
        };

        const [targetUser, follower] = await Promise.all([
            findUser(targetUserId),
            findUser(followerId)
        ]);

        if (!targetUser || !follower) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }

        // Use the target's userId for consistency in the following arrays
        const targetUserIdForArray = targetUser.userId;
        const followerIdForArray = follower.userId;

        const isFollowing = follower.following.includes(targetUserIdForArray);

        // Initialize stats24h if not present
        targetUser.stats24h = targetUser.stats24h || { votesDelta: 0, followersDelta: 0, rankDelta: 0, profileViewsDelta: 0 };

        if (isFollowing) {
            follower.following = follower.following.filter(id => id !== targetUserIdForArray);
            targetUser.followers = targetUser.followers.filter(id => id !== followerIdForArray);
            follower.followingCount = Math.max(0, follower.followingCount - 1);
            targetUser.followersCount = Math.max(0, targetUser.followersCount - 1);
            targetUser.stats24h.followersDelta = Math.max(0, (targetUser.stats24h.followersDelta || 0) - 1);
        } else {
            follower.following.push(targetUserIdForArray);
            targetUser.followers.push(followerIdForArray);
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

// POST /api/users/:userId/verification - Submit verification documents
router.post('/:userId/verification', verificationUpload.fields([
    { name: 'idFront', maxCount: 1 },
    { name: 'idBack', maxCount: 1 }
]), async (req, res) => {
    try {
        const { userId } = req.params;
        const { fullName, dateOfBirth } = req.body;

        // Find user
        let user = await User.findOne({ userId });
        if (!user) {
            try {
                user = await User.findById(userId);
            } catch (e) {
                // Invalid ObjectId format
            }
        }

        if (!user) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }

        // Validate required fields
        if (!fullName || !dateOfBirth) {
            return res.status(400).json({
                success: false,
                error: 'Full name and date of birth are required'
            });
        }

        // Get file URLs
        const idFrontURL = req.files?.idFront?.[0]
            ? `/uploads/${req.files.idFront[0].filename}`
            : null;
        const idBackURL = req.files?.idBack?.[0]
            ? `/uploads/${req.files.idBack[0].filename}`
            : null;

        if (!idFrontURL) {
            return res.status(400).json({
                success: false,
                error: 'Front of ID document is required'
            });
        }

        // Update user verification data
        user.verification = {
            fullName,
            dateOfBirth: new Date(dateOfBirth),
            idFrontURL,
            idBackURL,
            submittedAt: new Date(),
            reviewedAt: null,
            reviewedBy: null,
            rejectionReason: ''
        };
        user.verificationStatus = 'pending';
        await user.save();

        res.json({
            success: true,
            message: 'Verification documents submitted successfully',
            data: {
                verificationStatus: user.verificationStatus,
                submittedAt: user.verification.submittedAt
            }
        });
    } catch (error) {
        console.error('Verification submission error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/users/:userId/verification - Get verification status
router.get('/:userId/verification', async (req, res) => {
    try {
        const { userId } = req.params;

        // Find user
        let user = await User.findOne({ userId });
        if (!user) {
            try {
                user = await User.findById(userId);
            } catch (e) {
                // Invalid ObjectId format
            }
        }

        if (!user) {
            return res.status(404).json({ success: false, error: 'User not found' });
        }

        res.json({
            success: true,
            data: {
                verificationStatus: user.verificationStatus || 'unverified',
                verification: user.verification || null
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

