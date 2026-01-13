const express = require('express');
const router = express.Router();
const { Election, ElectionVote } = require('../models/Election');
const crypto = require('crypto');

// Generate unique ID
const generateId = () => crypto.randomBytes(12).toString('hex');

// Generate fake transaction hash (simulating blockchain)
const generateTxHash = () => '0x' + crypto.randomBytes(32).toString('hex');

// GET /api/elections - Get all elections
router.get('/', async (req, res) => {
    try {
        const { status, country } = req.query;
        let filter = {};
        
        if (status) filter.status = status;
        if (country) filter.country = country;
        
        const elections = await Election.find(filter).sort({ startDate: -1 });
        res.json({ success: true, data: elections });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/elections/active - Get active elections
router.get('/active', async (req, res) => {
    try {
        const now = new Date();
        const elections = await Election.find({
            status: 'active',
            startDate: { $lte: now },
            endDate: { $gte: now }
        });
        res.json({ success: true, data: elections });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/elections/:id - Get election by ID
router.get('/:id', async (req, res) => {
    try {
        const election = await Election.findOne({ electionId: req.params.id });
        if (!election) {
            return res.status(404).json({ success: false, error: 'Election not found' });
        }
        res.json({ success: true, data: election });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/elections/:id/vote - Cast a vote
router.post('/:id/vote', async (req, res) => {
    try {
        const { userId, candidateId, voteCount = 1 } = req.body;
        const electionId = req.params.id;
        
        if (!userId || !candidateId) {
            return res.status(400).json({ success: false, error: 'Missing userId or candidateId' });
        }
        
        // Check if election exists and is active
        const election = await Election.findOne({ electionId });
        if (!election) {
            return res.status(404).json({ success: false, error: 'Election not found' });
        }
        if (election.status !== 'active') {
            return res.status(400).json({ success: false, error: 'Election is not active' });
        }
        
        // Check if candidate exists
        const candidate = election.candidates.find(c => c.candidateId === candidateId);
        if (!candidate) {
            return res.status(404).json({ success: false, error: 'Candidate not found' });
        }
        
        // Check if user already voted
        const existingVote = await ElectionVote.findOne({ electionId, userId });
        if (existingVote) {
            return res.status(400).json({ success: false, error: 'You have already voted in this election' });
        }
        
        // Create vote record
        const vote = new ElectionVote({
            voteId: generateId(),
            electionId,
            userId,
            candidateId,
            voteCount,
            transactionHash: generateTxHash(),
            blockNumber: Math.floor(Math.random() * 1000000) + 18000000
        });
        await vote.save();
        
        // Update candidate votes
        await Election.updateOne(
            { electionId, 'candidates.candidateId': candidateId },
            { 
                $inc: { 
                    'candidates.$.votesReceived': voteCount,
                    totalVotes: voteCount
                }
            }
        );
        
        // Fetch updated election
        const updatedElection = await Election.findOne({ electionId });
        
        res.json({ 
            success: true, 
            data: {
                vote,
                election: updatedElection,
                message: `Successfully cast ${voteCount} vote(s) for ${candidate.name}`
            }
        });
    } catch (error) {
        if (error.code === 11000) {
            return res.status(400).json({ success: false, error: 'You have already voted in this election' });
        }
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/elections/:id/results - Get election results
router.get('/:id/results', async (req, res) => {
    try {
        const election = await Election.findOne({ electionId: req.params.id });
        if (!election) {
            return res.status(404).json({ success: false, error: 'Election not found' });
        }
        
        const results = election.candidates.map(c => ({
            candidateId: c.candidateId,
            name: c.name,
            party: c.party,
            votesReceived: c.votesReceived,
            percentage: election.totalVotes > 0 
                ? Math.round((c.votesReceived / election.totalVotes) * 100) 
                : 0
        })).sort((a, b) => b.votesReceived - a.votesReceived);
        
        res.json({ success: true, data: { election, results, totalVotes: election.totalVotes }});
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/elections/:id/check-vote/:userId - Check if user voted
router.get('/:id/check-vote/:userId', async (req, res) => {
    try {
        const vote = await ElectionVote.findOne({
            electionId: req.params.id,
            userId: req.params.userId
        });
        res.json({ success: true, data: { hasVoted: !!vote, vote } });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/elections - Create new election (admin)
router.post('/', async (req, res) => {
    try {
        const { title, description, position, country, region, startDate, endDate, candidates } = req.body;

        const election = new Election({
            electionId: generateId(),
            title,
            description,
            position,
            country: country || 'Global',
            region: region || '',
            startDate: new Date(startDate),
            endDate: new Date(endDate),
            status: new Date(startDate) <= new Date() ? 'active' : 'upcoming',
            candidates: candidates.map(c => ({
                candidateId: generateId(),
                userId: c.userId || generateId(),
                name: c.name,
                party: c.party || '',
                bio: c.bio || '',
                avatarURL: c.avatarURL || '',
                votesReceived: 0
            }))
        });

        await election.save();
        res.json({ success: true, data: election });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/elections/seed - Seed sample elections
router.post('/seed', async (req, res) => {
    try {
        // Check if elections already exist
        const existing = await Election.countDocuments();
        if (existing > 0) {
            return res.json({ success: true, message: 'Elections already seeded', count: existing });
        }

        const now = new Date();
        const oneWeekLater = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
        const twoWeeksLater = new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000);

        const elections = [
            {
                electionId: 'election-sa-digital-2026',
                title: 'Minister of Digital Economy',
                description: 'Vote for the next Minister of Digital Economy to lead South Africa\'s digital transformation.',
                position: 'Minister of Digital Economy',
                country: 'South Africa',
                region: 'National',
                startDate: now,
                endDate: oneWeekLater,
                status: 'active',
                candidates: [
                    { candidateId: 'cand-nkosi', userId: 'genius-nkosi', name: 'Nkosi Dlamini', party: 'Africa Genius Alliance', bio: 'Tech entrepreneur and blockchain expert', votesReceived: 1247 },
                    { candidateId: 'cand-thabo', userId: 'genius-thabo', name: 'Thabo Mokoena', party: 'Digital Progress Party', bio: 'Former tech minister advisor', votesReceived: 892 },
                    { candidateId: 'cand-zandile', userId: 'genius-zandile', name: 'Zandile Khumalo', party: 'Innovation First', bio: 'Cybersecurity specialist', votesReceived: 543 }
                ],
                totalVotes: 2682
            },
            {
                electionId: 'election-ke-edu-2026',
                title: 'Director of Education Technology',
                description: 'Select the leader for Kenya\'s national education technology initiative.',
                position: 'Director of Education Technology',
                country: 'Kenya',
                region: 'National',
                startDate: now,
                endDate: twoWeeksLater,
                status: 'active',
                candidates: [
                    { candidateId: 'cand-amina', userId: 'genius-amina', name: 'Amina Ochieng', party: 'EdTech Alliance', bio: 'Education reform advocate', votesReceived: 756 },
                    { candidateId: 'cand-james', userId: 'genius-james', name: 'James Kimani', party: 'Future Learning', bio: 'AI in education pioneer', votesReceived: 621 }
                ],
                totalVotes: 1377
            }
        ];

        await Election.insertMany(elections);
        res.json({ success: true, message: 'Elections seeded successfully', count: elections.length });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

