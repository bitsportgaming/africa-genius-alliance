const express = require('express');
const router = express.Router();
const Proposal = require('../models/Proposal');
const crypto = require('crypto');

// GET /api/proposals - Get all proposals
router.get('/', async (req, res) => {
    try {
        const { category, status, limit = 20 } = req.query;
        const query = {};
        
        if (category) query.category = category;
        if (status) query.status = status;
        
        const proposals = await Proposal.find(query)
            .sort({ createdAt: -1 })
            .limit(parseInt(limit));
        
        res.json({ success: true, data: proposals });
    } catch (error) {
        console.error('Get proposals error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/proposals/active - Get active proposals
router.get('/active', async (req, res) => {
    try {
        const proposals = await Proposal.find({ 
            status: 'active',
            endDate: { $gt: new Date() }
        }).sort({ endDate: 1 });
        
        res.json({ success: true, data: proposals });
    } catch (error) {
        console.error('Get active proposals error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/proposals/:proposalId - Get single proposal
router.get('/:proposalId', async (req, res) => {
    try {
        const proposal = await Proposal.findOne({ proposalId: req.params.proposalId });
        
        if (!proposal) {
            return res.status(404).json({ success: false, error: 'Proposal not found' });
        }
        
        res.json({ success: true, data: proposal });
    } catch (error) {
        console.error('Get proposal error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/proposals - Create new proposal
router.post('/', async (req, res) => {
    try {
        const proposalId = crypto.randomBytes(16).toString('hex');
        const proposal = new Proposal({
            proposalId,
            ...req.body
        });
        await proposal.save();
        
        res.status(201).json({ success: true, data: proposal });
    } catch (error) {
        console.error('Create proposal error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// PUT /api/proposals/:proposalId/close - Close voting and determine outcome
router.put('/:proposalId/close', async (req, res) => {
    try {
        const proposal = await Proposal.findOne({ proposalId: req.params.proposalId });
        
        if (!proposal) {
            return res.status(404).json({ success: false, error: 'Proposal not found' });
        }
        
        const totalVotes = proposal.votesFor + proposal.votesAgainst + proposal.votesAbstain;
        const quorumMet = totalVotes >= proposal.quorumRequired;
        const percentageFor = totalVotes > 0 ? (proposal.votesFor / totalVotes) * 100 : 0;
        
        let newStatus = 'rejected';
        if (quorumMet && percentageFor >= proposal.passingThreshold) {
            newStatus = 'passed';
        } else if (!quorumMet) {
            newStatus = 'expired';
        }
        
        proposal.status = newStatus;
        await proposal.save();
        
        res.json({ 
            success: true, 
            data: proposal,
            summary: {
                totalVotes,
                quorumMet,
                percentageFor: Math.round(percentageFor),
                outcome: newStatus
            }
        });
    } catch (error) {
        console.error('Close proposal error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

