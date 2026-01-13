/**
 * Seed script to create an initial superadmin user
 * Run with: node seed_admin.js
 */

require('dotenv').config();
const mongoose = require('mongoose');
const crypto = require('crypto');
const User = require('./models/User');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/aga';

// Simple password hashing (same as in auth.js)
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

function generateUniqueId() {
    return crypto.randomBytes(16).toString('hex');
}

async function seedAdmin() {
    try {
        console.log('🔌 Connecting to MongoDB...');
        await mongoose.connect(MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        // Check if admin already exists
        const existingAdmin = await User.findOne({ role: 'superadmin' });
        
        if (existingAdmin) {
            console.log('ℹ️  Superadmin already exists:');
            console.log(`   Email: ${existingAdmin.email}`);
            console.log('   To reset, delete the user and run this script again.');
        } else {
            // Create superadmin
            const adminData = {
                userId: generateUniqueId(),
                username: 'superadmin',
                displayName: 'AGA Super Admin',
                email: 'admin@africageniusalliance.org',
                passwordHash: hashPassword('AGA@Admin2024!'),
                role: 'superadmin',
                status: 'active',
                isVerified: true,
                bio: 'Africa Genius Alliance Platform Administrator',
                country: 'Global'
            };

            const admin = new User(adminData);
            await admin.save();

            console.log('✅ Superadmin created successfully!');
            console.log('');
            console.log('🔐 Login Credentials:');
            console.log('   Email: admin@africageniusalliance.org');
            console.log('   Password: AGA@Admin2024!');
            console.log('');
            console.log('⚠️  IMPORTANT: Change this password after first login!');
        }

        await mongoose.disconnect();
        console.log('👋 Done!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Error:', error.message);
        process.exit(1);
    }
}

seedAdmin();

