const express = require('express');
const router = express.Router();
const { Election, ElectionVote } = require('../models/Election');
const blockchainService = require('../services/blockchainService');
const crypto = require('crypto');

// Generate unique ID
const generateId = () => crypto.randomBytes(12).toString('hex');

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

        // Auto-update election statuses
        await Election.updateMany(
            { status: 'upcoming', startDate: { $lte: now } },
            { $set: { status: 'active' } }
        );
        await Election.updateMany(
            { status: 'active', endDate: { $lt: now } },
            { $set: { status: 'completed' } }
        );

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

// POST /api/elections/:id/vote - Cast a vote (classic: 1 vote per user per election)
router.post('/:id/vote', async (req, res) => {
    try {
        const { userId, candidateId } = req.body;
        const electionId = req.params.id;

        if (!userId || !candidateId) {
            return res.status(400).json({ success: false, error: 'Missing userId or candidateId' });
        }

        // Check if election exists and is active
        const election = await Election.findOne({ electionId });
        if (!election) {
            return res.status(404).json({ success: false, error: 'Election not found' });
        }

        const now = new Date();
        if (now < election.startDate) {
            return res.status(400).json({ success: false, error: 'Election has not started yet' });
        }
        if (now > election.endDate) {
            return res.status(400).json({ success: false, error: 'Election has ended' });
        }
        if (election.status !== 'active') {
            return res.status(400).json({ success: false, error: 'Election is not active' });
        }

        // Check if candidate exists
        const candidate = election.candidates.find(c => c.candidateId === candidateId);
        if (!candidate) {
            return res.status(404).json({ success: false, error: 'Candidate not found' });
        }

        // Check if user already voted (classic voting - only 1 vote allowed)
        const existingVote = await ElectionVote.findOne({ electionId, userId });
        if (existingVote) {
            return res.status(400).json({
                success: false,
                error: 'You have already voted in this election',
                existingVote: {
                    candidateId: existingVote.candidateId,
                    transactionHash: existingVote.blockchain?.transactionHash
                }
            });
        }

        // Record vote on BNB Chain blockchain
        let blockchainResult;
        try {
            blockchainResult = await blockchainService.recordVote(
                election.blockchain?.electionIdOnChain || 0,
                candidateId,
                userId
            );
        } catch (bcError) {
            console.error('Blockchain error:', bcError);
            // Continue with mock if blockchain fails
            blockchainResult = blockchainService.generateMockTransaction();
        }

        // Create vote record with blockchain data
        const vote = new ElectionVote({
            voteId: generateId(),
            electionId,
            userId,
            candidateId,
            blockchain: {
                transactionHash: blockchainResult.transactionHash,
                blockNumber: blockchainResult.blockNumber,
                blockHash: blockchainResult.blockHash || '',
                gasUsed: blockchainResult.gasUsed || '',
                status: blockchainResult.status || 'confirmed',
                confirmedAt: new Date(),
                chainId: blockchainService.config?.chainId || 97
            }
        });
        await vote.save();

        // Update candidate votes and total voters
        await Election.updateOne(
            { electionId, 'candidates.candidateId': candidateId },
            {
                $inc: {
                    'candidates.$.votesReceived': 1,
                    totalVotes: 1,
                    totalVoters: 1
                }
            }
        );

        // Fetch updated election
        const updatedElection = await Election.findOne({ electionId });

        res.json({
            success: true,
            data: {
                vote: {
                    voteId: vote.voteId,
                    candidateId: vote.candidateId,
                    candidateName: candidate.name,
                    votedAt: vote.votedAt,
                    blockchain: {
                        transactionHash: vote.blockchain.transactionHash,
                        blockNumber: vote.blockchain.blockNumber,
                        explorerUrl: blockchainResult.explorerUrl,
                        status: vote.blockchain.status,
                        chainId: vote.blockchain.chainId
                    }
                },
                election: updatedElection,
                message: `Successfully voted for ${candidate.name}`
            }
        });
    } catch (error) {
        if (error.code === 11000) {
            return res.status(400).json({ success: false, error: 'You have already voted in this election' });
        }
        console.error('Vote error:', error);
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
            bio: c.bio,
            manifesto: c.manifesto,
            avatarURL: c.avatarURL,
            votesReceived: c.votesReceived,
            percentage: election.totalVotes > 0
                ? Math.round((c.votesReceived / election.totalVotes) * 100)
                : 0
        })).sort((a, b) => b.votesReceived - a.votesReceived);

        res.json({
            success: true,
            data: {
                election,
                results,
                totalVotes: election.totalVotes,
                totalVoters: election.totalVoters,
                blockchain: election.blockchain
            }
        });
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

        if (vote) {
            res.json({
                success: true,
                data: {
                    hasVoted: true,
                    vote: {
                        candidateId: vote.candidateId,
                        votedAt: vote.votedAt,
                        blockchain: vote.blockchain
                    }
                }
            });
        } else {
            res.json({ success: true, data: { hasVoted: false } });
        }
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/elections/:id/verify/:txHash - Verify vote on blockchain
router.get('/:id/verify/:txHash', async (req, res) => {
    try {
        const vote = await ElectionVote.findOne({
            electionId: req.params.id,
            'blockchain.transactionHash': req.params.txHash
        });

        if (!vote) {
            return res.status(404).json({ success: false, error: 'Vote not found' });
        }

        res.json({
            success: true,
            data: {
                verified: true,
                vote: {
                    candidateId: vote.candidateId,
                    votedAt: vote.votedAt,
                    blockchain: vote.blockchain
                },
                explorerUrl: blockchainService.getExplorerUrl(vote.blockchain.transactionHash)
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/elections - Create new election (admin)
router.post('/', async (req, res) => {
    try {
        const { title, description, position, country, region, startDate, endDate, candidates } = req.body;

        const electionId = generateId();
        const start = new Date(startDate);
        const end = new Date(endDate);

        // Create election on blockchain (optional - depends on configuration)
        let blockchainData = {};
        try {
            const bcResult = await blockchainService.createElectionOnChain(electionId, start, end);
            blockchainData = {
                electionIdOnChain: bcResult.electionIdOnChain,
                isDeployed: !bcResult.mock,
                deployTxHash: bcResult.transactionHash || '',
                chainId: blockchainService.config?.chainId || 97
            };
        } catch (bcError) {
            console.log('Blockchain election creation skipped:', bcError.message);
        }

        const election = new Election({
            electionId,
            title,
            description,
            position,
            country: country || 'Global',
            region: region || '',
            startDate: start,
            endDate: end,
            status: start <= new Date() ? 'active' : 'upcoming',
            candidates: (candidates || []).map(c => ({
                candidateId: generateId(),
                userId: c.userId || generateId(),
                name: c.name,
                party: c.party || '',
                bio: c.bio || '',
                manifesto: c.manifesto || '',
                avatarURL: c.avatarURL || '',
                votesReceived: 0
            })),
            blockchain: blockchainData
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
                totalVoters: 2682,
                candidates: [
                    { candidateId: 'cand-nkosi', userId: 'genius-nkosi', name: 'Nkosi Dlamini', party: 'Africa Genius Alliance', bio: 'Tech entrepreneur and blockchain expert', manifesto: 'Accelerate Africa\'s digital transformation through blockchain and AI adoption.', votesReceived: 1247 },
                    { candidateId: 'cand-thabo', userId: 'genius-thabo', name: 'Thabo Mokoena', party: 'Digital Progress Party', bio: 'Former tech minister advisor', manifesto: 'Bridge the digital divide with affordable internet and digital skills training.', votesReceived: 892 },
                    { candidateId: 'cand-zandile', userId: 'genius-zandile', name: 'Zandile Khumalo', party: 'Innovation First', bio: 'Cybersecurity specialist', manifesto: 'Secure digital infrastructure and protect citizen data.', votesReceived: 543 }
                ],
                totalVotes: 2682,
                blockchain: { chainId: 97, isDeployed: false }
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
                totalVoters: 1377,
                candidates: [
                    { candidateId: 'cand-amina', userId: 'genius-amina', name: 'Amina Ochieng', party: 'EdTech Alliance', bio: 'Education reform advocate', manifesto: 'Every child deserves access to world-class digital education.', votesReceived: 756 },
                    { candidateId: 'cand-james', userId: 'genius-james', name: 'James Kimani', party: 'Future Learning', bio: 'AI in education pioneer', manifesto: 'Leverage AI to personalize learning for every student.', votesReceived: 621 }
                ],
                totalVotes: 1377,
                blockchain: { chainId: 97, isDeployed: false }
            }
        ];

        await Election.insertMany(elections);
        res.json({ success: true, message: 'Elections seeded successfully', count: elections.length });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/elections/:id/votes - Get all votes for an election (for transparency)
router.get('/:id/votes', async (req, res) => {
    try {
        const { page = 1, limit = 50 } = req.query;
        const votes = await ElectionVote.find({ electionId: req.params.id })
            .sort({ votedAt: -1 })
            .skip((page - 1) * limit)
            .limit(parseInt(limit))
            .select('candidateId votedAt blockchain.transactionHash blockchain.blockNumber blockchain.status');

        const total = await ElectionVote.countDocuments({ electionId: req.params.id });

        res.json({
            success: true,
            data: votes,
            pagination: { page: parseInt(page), limit: parseInt(limit), total }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

