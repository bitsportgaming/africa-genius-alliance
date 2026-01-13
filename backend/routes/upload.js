const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const crypto = require('crypto');
const User = require('../models/User');

// Helper function to generate unique ID
function generateUniqueId() {
    return crypto.randomBytes(16).toString('hex');
}

// Configure multer for profile image uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueName = `profile-${generateUniqueId()}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    }
});

const fileFilter = (req, file, cb) => {
    const allowedImageTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

    if (allowedImageTypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed.'), false);
    }
};

const upload = multer({
    storage,
    fileFilter,
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// POST /api/upload/profile-image - Upload profile image
router.post('/profile-image', upload.single('image'), async (req, res) => {
    try {
        const { userId } = req.body;

        if (!userId) {
            return res.status(400).json({
                success: false,
                error: 'userId is required'
            });
        }

        if (!req.file) {
            return res.status(400).json({
                success: false,
                error: 'No image file provided'
            });
        }

        // Update user's profile image URL
        const imageUrl = `/uploads/${req.file.filename}`;

        const user = await User.findOne({ userId });
        if (!user) {
            return res.status(404).json({
                success: false,
                error: 'User not found'
            });
        }

        user.profileImageURL = imageUrl;
        await user.save();

        res.json({
            success: true,
            imageUrl,
            message: 'Profile image uploaded successfully'
        });
    } catch (error) {
        console.error('Profile image upload error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
