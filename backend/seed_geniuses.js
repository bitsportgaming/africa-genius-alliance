const mongoose = require('mongoose');
const crypto = require('crypto');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/aga');

const userSchema = new mongoose.Schema({
    userId: String,
    username: String,
    displayName: String,
    email: String,
    passwordHash: String,
    profileImageURL: String,
    bio: String,
    country: String,
    role: String,
    positionTitle: String,
    positionCategory: String,
    isVerified: Boolean,
    followersCount: Number,
    followingCount: Number,
    votesReceived: Number,
    votesCast: Number,
    donationsTotal: Number,
    profileViews: Number,
    manifestoShort: String,
    stats24h: {
        votesDelta: Number,
        followersDelta: Number,
        rankDelta: Number,
        profileViewsDelta: Number,
        lastUpdated: Date
    },
    following: [String],
    followers: [String]
}, { timestamps: true });

const User = mongoose.model('User', userSchema);

const geniuses = [
    // Education
    { displayName: "Amina Mensah", country: "Ghana", positionTitle: "Minister of Education", positionCategory: "Education", bio: "Champion of digital literacy and rural education access", manifestoShort: "Every African child deserves quality education", votesReceived: 31442, followersCount: 12500, isVerified: true },
    { displayName: "Dr. Kwame Asante", country: "Kenya", positionTitle: "Director of STEM Programs", positionCategory: "Education", bio: "Building Africa's next generation of scientists", manifestoShort: "STEM education for all", votesReceived: 18320, followersCount: 8900, isVerified: true },
    
    // Health
    { displayName: "Dr. Fatima Diallo", country: "Senegal", positionTitle: "Minister of Health", positionCategory: "Health", bio: "Healthcare innovation and pandemic preparedness", manifestoShort: "Universal healthcare across Africa", votesReceived: 14200, followersCount: 7800, isVerified: true },
    { displayName: "Dr. Ngozi Okafor", country: "Nigeria", positionTitle: "Public Health Director", positionCategory: "Health", bio: "Community health initiatives and disease prevention", manifestoShort: "Healthy communities, prosperous nations", votesReceived: 11500, followersCount: 5400, isVerified: false },
    
    // Infrastructure
    { displayName: "Leila Ben Ali", country: "Morocco", positionTitle: "Minister of Transport", positionCategory: "Infrastructure", bio: "Building the Pan-African rail network", manifestoShort: "Connected Africa through modern infrastructure", votesReceived: 19340, followersCount: 9200, isVerified: true },
    { displayName: "Ahmed Hassan", country: "Egypt", positionTitle: "Infrastructure Director", positionCategory: "Infrastructure", bio: "Smart cities and sustainable development", manifestoShort: "Building tomorrow's cities today", votesReceived: 8900, followersCount: 4100, isVerified: true },
    
    // Trade
    { displayName: "Kofi Asante", country: "Ghana", positionTitle: "Minister of Trade", positionCategory: "Trade", bio: "Promoting intra-African trade and AfCFTA", manifestoShort: "Trade barriers down, opportunities up", votesReceived: 15890, followersCount: 6700, isVerified: false },
    { displayName: "Nala Kimathi", country: "Tanzania", positionTitle: "Economic Policy Advisor", positionCategory: "Trade", bio: "Empowering small businesses across borders", manifestoShort: "African entrepreneurs, global markets", votesReceived: 7200, followersCount: 3200, isVerified: true },
    
    // Security
    { displayName: "Gen. Moussa Traore", country: "Mali", positionTitle: "Security Advisor", positionCategory: "Security", bio: "Regional peace and stability initiatives", manifestoShort: "Peace through cooperation", votesReceived: 9800, followersCount: 4500, isVerified: true },
    { displayName: "Col. Sarah Okonkwo", country: "Nigeria", positionTitle: "Cybersecurity Director", positionCategory: "Security", bio: "Protecting Africa's digital future", manifestoShort: "Secure digital Africa", votesReceived: 6500, followersCount: 2800, isVerified: false },
    
    // Tech
    { displayName: "Nkosi Dlamini", country: "South Africa", positionTitle: "Minister of Digital Economy", positionCategory: "Tech", bio: "Bringing AI, solar and fiber to rural communities", manifestoShort: "Digital transformation for every village", votesReceived: 24580, followersCount: 8113, isVerified: true },
    { displayName: "Ama Adjei", country: "Rwanda", positionTitle: "Innovation Hub Director", positionCategory: "Tech", bio: "Building Africa's Silicon Valley", manifestoShort: "Innovation made in Africa", votesReceived: 12300, followersCount: 5600, isVerified: true }
];

async function seedGeniuses() {
    try {
        console.log('Seeding genius users...');
        
        for (const genius of geniuses) {
            const userId = crypto.randomBytes(16).toString('hex');
            const username = genius.displayName.toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '');
            const email = `${username}@aga.africa`;
            
            const existingUser = await User.findOne({ email });
            if (existingUser) {
                console.log(`Skipping ${genius.displayName} - already exists`);
                continue;
            }
            
            const user = new User({
                userId,
                username,
                displayName: genius.displayName,
                email,
                passwordHash: crypto.createHash('sha256').update('genius123').digest('hex'),
                profileImageURL: null,
                bio: genius.bio,
                country: genius.country,
                role: 'genius',
                positionTitle: genius.positionTitle,
                positionCategory: genius.positionCategory,
                isVerified: genius.isVerified,
                followersCount: genius.followersCount,
                followingCount: 0,
                votesReceived: genius.votesReceived,
                votesCast: 0,
                donationsTotal: 0,
                profileViews: Math.floor(Math.random() * 5000),
                manifestoShort: genius.manifestoShort,
                stats24h: {
                    votesDelta: Math.floor(Math.random() * 200),
                    followersDelta: Math.floor(Math.random() * 50),
                    rankDelta: Math.floor(Math.random() * 3) - 1,
                    profileViewsDelta: Math.floor(Math.random() * 500),
                    lastUpdated: new Date()
                },
                following: [],
                followers: []
            });
            
            await user.save();
            console.log(`Created: ${genius.displayName} (${genius.positionCategory})`);
        }
        
        console.log('Seeding complete!');
        process.exit(0);
    } catch (error) {
        console.error('Error seeding:', error);
        process.exit(1);
    }
}

seedGeniuses();
