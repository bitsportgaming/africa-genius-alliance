const express = require('express');
const router = express.Router();
const User = require('../models/User');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// JWT secret from environment or fallback
const JWT_SECRET = process.env.JWT_SECRET || 'aga-secret-key-change-in-production';

// Configure multer for profile image uploads
const uploadsDir = path.join(__dirname, '..', 'uploads', 'profiles');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadsDir),
    filename: (req, file, cb) => {
        const uniqueName = `${req.params.userId}-${Date.now()}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    }
});

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
        if (allowedTypes.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Invalid file type. Only JPEG and PNG allowed.'));
        }
    }
});

// Simple password hashing (in production, use bcrypt)
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

function verifyPassword(password, hash) {
    return hashPassword(password) === hash;
}

// Generate unique ID
function generateUniqueId() {
    return crypto.randomBytes(16).toString('hex');
}

// POST /api/auth/register - Register a new user
router.post('/register', async (req, res) => {
    try {
        const { username, email, password, displayName, role, country, bio } = req.body;

        // Validate required fields
        if (!username || !email || !password || !displayName) {
            return res.status(400).json({ 
                success: false, 
                error: 'Username, email, password, and display name are required' 
            });
        }

        // Check if user already exists
        const existingUser = await User.findOne({ 
            $or: [{ email }, { username }] 
        });

        if (existingUser) {
            const field = existingUser.email === email ? 'email' : 'username';
            return res.status(400).json({ 
                success: false, 
                error: `A user with this ${field} already exists` 
            });
        }

        // Create new user
        const userId = generateUniqueId();
        const user = new User({
            userId,
            username: username.toLowerCase(),
            displayName,
            email: email.toLowerCase(),
            passwordHash: hashPassword(password),
            role: role || 'regular',
            country: country || '',
            bio: bio || ''
        });

        await user.save();

        // Auto-follow the official AGA account
        const AGA_OFFICIAL_ID = 'aga-official'; // Official AGA account user ID
        try {
            // Find or create the official AGA account
            let agaAccount = await User.findOne({
                $or: [
                    { userId: AGA_OFFICIAL_ID },
                    { username: 'aga-official' },
                    { role: 'admin' }
                ]
            });

            if (agaAccount) {
                // Add AGA to user's following list
                if (!user.following.includes(agaAccount.userId)) {
                    user.following.push(agaAccount.userId);
                    user.followingCount = user.following.length;
                    await user.save();
                }

                // Add user to AGA's followers list
                if (!agaAccount.followers.includes(user.userId)) {
                    agaAccount.followers.push(user.userId);
                    agaAccount.followersCount = agaAccount.followers.length;
                    await agaAccount.save();
                }

                console.log(`Auto-followed AGA Official for new user: ${user.username}`);
            }
        } catch (followError) {
            console.error('Auto-follow AGA failed (non-critical):', followError);
            // Non-critical error, continue with registration
        }

        // Return user without password hash
        const userResponse = user.toObject();
        delete userResponse.passwordHash;

        // Generate JWT token
        const token = jwt.sign(
            { userId: user.userId, email: user.email, role: user.role },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.status(201).json({
            success: true,
            data: {
                user: userResponse,
                token
            },
            message: 'Registration successful'
        });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/auth/login - Login user
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validate required fields
        if (!email || !password) {
            return res.status(400).json({ 
                success: false, 
                error: 'Email and password are required' 
            });
        }

        // Find user by email
        const user = await User.findOne({ email: email.toLowerCase() });

        if (!user) {
            return res.status(401).json({ 
                success: false, 
                error: 'Invalid email or password' 
            });
        }

        // Verify password
        if (!verifyPassword(password, user.passwordHash)) {
            return res.status(401).json({ 
                success: false, 
                error: 'Invalid email or password' 
            });
        }

        // Return user without password hash
        const userResponse = user.toObject();
        delete userResponse.passwordHash;

        // Generate JWT token
        const token = jwt.sign(
            { userId: user.userId, email: user.email, role: user.role },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            success: true,
            data: {
                user: userResponse,
                token
            },
            message: 'Login successful'
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/auth/profile/:userId - Get user profile
router.get('/profile/:userId', async (req, res) => {
    try {
        const user = await User.findOne({ userId: req.params.userId });
        
        if (!user) {
            return res.status(404).json({ 
                success: false, 
                error: 'User not found' 
            });
        }

        // Return user without password hash
        const userResponse = user.toObject();
        delete userResponse.passwordHash;

        res.json({ success: true, data: userResponse });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// PUT /api/auth/profile/:userId - Update user profile
router.put('/profile/:userId', async (req, res) => {
    try {
        const { displayName, bio, country, profileImageURL, positionTitle, socialLinks } = req.body;

        const user = await User.findOne({ userId: req.params.userId });

        if (!user) {
            return res.status(404).json({
                success: false,
                error: 'User not found'
            });
        }

        // Update fields
        if (displayName) user.displayName = displayName;
        if (bio !== undefined) user.bio = bio;
        if (country !== undefined) user.country = country;
        if (profileImageURL !== undefined) user.profileImageURL = profileImageURL;
        if (positionTitle !== undefined) user.positionTitle = positionTitle;

        // Update social links
        if (socialLinks !== undefined) {
            if (!user.socialLinks) {
                user.socialLinks = {};
            }
            if (socialLinks.twitter !== undefined) user.socialLinks.twitter = socialLinks.twitter;
            if (socialLinks.instagram !== undefined) user.socialLinks.instagram = socialLinks.instagram;
            if (socialLinks.linkedin !== undefined) user.socialLinks.linkedin = socialLinks.linkedin;
            if (socialLinks.website !== undefined) user.socialLinks.website = socialLinks.website;
        }

        await user.save();

        // Return user without password hash
        const userResponse = user.toObject();
        delete userResponse.passwordHash;

        res.json({ success: true, data: userResponse });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// PUT /api/auth/profile/:userId/genius - Update genius profile (onboarding)
router.put('/profile/:userId/genius', async (req, res) => {
    try {
        const {
            displayName,
            country,
            bio,
            positionCategory,
            positionTitle,
            manifestoShort,
            problemSolved,
            proofLinks,
            credentials,
            videoIntroURL,
            onboardingCompleted
        } = req.body;

        const user = await User.findOne({ userId: req.params.userId });

        if (!user) {
            return res.status(404).json({
                success: false,
                error: 'User not found'
            });
        }

        // Update all genius profile fields
        if (displayName) user.displayName = displayName;
        if (country !== undefined) user.country = country;
        if (bio !== undefined) user.bio = bio;
        if (positionCategory !== undefined) user.positionCategory = positionCategory;
        if (positionTitle !== undefined) user.positionTitle = positionTitle;
        if (manifestoShort !== undefined) user.manifestoShort = manifestoShort;
        if (problemSolved !== undefined) user.problemSolved = problemSolved;
        if (proofLinks !== undefined) user.proofLinks = proofLinks;
        if (credentials !== undefined) user.credentials = credentials;
        if (videoIntroURL !== undefined) user.videoIntroURL = videoIntroURL;
        if (onboardingCompleted !== undefined) user.onboardingCompleted = onboardingCompleted;

        await user.save();

        // Return user without password hash
        const userResponse = user.toObject();
        delete userResponse.passwordHash;

        console.log(`✅ Genius profile updated for user ${req.params.userId}`);
        res.json({ success: true, data: userResponse });
    } catch (error) {
        console.error('Genius profile update error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/auth/profile/:userId/image - Upload profile image
router.post('/profile/:userId/image', upload.single('image'), async (req, res) => {
    try {
        const user = await User.findOne({ userId: req.params.userId });

        if (!user) {
            return res.status(404).json({
                success: false,
                error: 'User not found'
            });
        }

        if (!req.file) {
            return res.status(400).json({
                success: false,
                error: 'No image file provided'
            });
        }

        // Build the public URL for the uploaded image
        const imageURL = `${process.env.API_BASE_URL || 'https://africageniusalliance.com'}/uploads/profiles/${req.file.filename}`;

        // Update user's profile image URL
        user.profileImageURL = imageURL;
        await user.save();

        // Return user without password hash
        const userResponse = user.toObject();
        delete userResponse.passwordHash;

        console.log(`✅ Profile image uploaded for user ${req.params.userId}: ${imageURL}`);
        res.json({ success: true, data: userResponse });
    } catch (error) {
        console.error('Profile image upload error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/auth/change-password - Change user password
router.post('/change-password', async (req, res) => {
    try {
        const { userId, currentPassword, newPassword } = req.body;

        // Validate required fields
        if (!userId || !currentPassword || !newPassword) {
            return res.status(400).json({
                success: false,
                error: 'User ID, current password, and new password are required'
            });
        }

        // Validate new password length
        if (newPassword.length < 6) {
            return res.status(400).json({
                success: false,
                error: 'New password must be at least 6 characters'
            });
        }

        // Check if new password is same as current password
        if (currentPassword === newPassword) {
            return res.status(400).json({
                success: false,
                error: 'New password must be different from current password'
            });
        }

        // Find user
        const user = await User.findOne({ userId });

        if (!user) {
            return res.status(404).json({
                success: false,
                error: 'User not found'
            });
        }

        // Verify current password
        if (!verifyPassword(currentPassword, user.passwordHash)) {
            return res.status(401).json({
                success: false,
                error: 'Current password is incorrect'
            });
        }

        // Update password
        user.passwordHash = hashPassword(newPassword);
        await user.save();

        console.log(`✅ Password changed for user ${userId}`);
        res.json({ success: true, message: 'Password changed successfully' });
    } catch (error) {
        console.error('Change password error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

