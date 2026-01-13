const express = require('express');
const router = express.Router();
const Vote = require('../models/Vote');
const User = require('../models/User');
const Project = require('../models/Project');
const Proposal = require('../models/Proposal');
const crypto = require('crypto');

// GET /api/voting/history/:userId - Get user's voting history
router.get('/history/:userId', async (req, res) => {
    try {
        const votes = await Vote.find({ voterId: req.params.userId })
            .sort({ createdAt: -1 })
            .limit(100);
        
        // Enrich with target details
        const enrichedVotes = await Promise.all(votes.map(async (vote) => {
            let targetName = 'Unknown';
            let targetDetails = {};
            
            if (vote.targetType === 'genius') {
                const user = await User.findOne({ userId: vote.targetId });
                if (user) {
                    targetName = user.displayName;
                    targetDetails = { position: user.positionTitle, country: user.country };
                }
            } else if (vote.targetType === 'project') {
                const project = await Project.findOne({ projectId: vote.targetId });
                if (project) {
                    targetName = project.title;
                    targetDetails = { category: project.category, status: project.status };
                }
            } else if (vote.targetType === 'proposal') {
                const proposal = await Proposal.findOne({ proposalId: vote.targetId });
                if (proposal) {
                    targetName = proposal.title;
                    targetDetails = { category: proposal.category, status: proposal.status };
                }
            }
            
            return {
                ...vote.toObject(),
                targetName,
                targetDetails
            };
        }));
        
        res.json({ success: true, data: enrichedVotes });
    } catch (error) {
        console.error('Get voting history error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/voting/genius - Vote for a genius
router.post('/genius', async (req, res) => {
    try {
        const { voterId, geniusId, category } = req.body;
        
        // Check if already voted
        const existingVote = await Vote.findOne({ 
            voterId, 
            targetId: geniusId, 
            targetType: 'genius' 
        });
        
        if (existingVote) {
            return res.status(400).json({ success: false, error: 'Already voted for this genius' });
        }
        
        const vote = new Vote({
            voterId,
            targetId: geniusId,
            targetType: 'genius',
            category
        });
        await vote.save();
        
        // Update genius vote count
        await User.findOneAndUpdate(
            { userId: geniusId },
            { $inc: { votesReceived: 1, 'stats24h.votesDelta': 1 } }
        );
        
        // Update voter's votesCast
        await User.findOneAndUpdate(
            { userId: voterId },
            { $inc: { votesCast: 1 } }
        );
        
        res.json({ success: true, data: vote });
    } catch (error) {
        console.error('Vote for genius error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/voting/project - Vote for a project
router.post('/project', async (req, res) => {
    try {
        const { voterId, projectId } = req.body;
        
        const existingVote = await Vote.findOne({ 
            voterId, 
            targetId: projectId, 
            targetType: 'project' 
        });
        
        if (existingVote) {
            return res.status(400).json({ success: false, error: 'Already voted for this project' });
        }
        
        const vote = new Vote({
            voterId,
            targetId: projectId,
            targetType: 'project'
        });
        await vote.save();
        
        await Project.findOneAndUpdate(
            { projectId },
            { $inc: { votesCount: 1 } }
        );
        
        res.json({ success: true, data: vote });
    } catch (error) {
        console.error('Vote for project error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/voting/proposal - Vote on a proposal
router.post('/proposal', async (req, res) => {
    try {
        const { voterId, proposalId, voteType } = req.body; // voteType: 'for', 'against', 'abstain'
        
        const existingVote = await Vote.findOne({ 
            voterId, 
            targetId: proposalId, 
            targetType: 'proposal' 
        });
        
        if (existingVote) {
            return res.status(400).json({ success: false, error: 'Already voted on this proposal' });
        }
        
        const vote = new Vote({
            voterId,
            targetId: proposalId,
            targetType: 'proposal',
            category: voteType
        });
        await vote.save();
        
        const updateField = voteType === 'for' ? 'votesFor' : 
                           voteType === 'against' ? 'votesAgainst' : 'votesAbstain';
        
        await Proposal.findOneAndUpdate(
            { proposalId },
            { $inc: { [updateField]: 1 } }
        );
        
        res.json({ success: true, data: vote });
    } catch (error) {
        console.error('Vote on proposal error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

