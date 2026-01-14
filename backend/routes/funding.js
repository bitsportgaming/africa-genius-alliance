const express = require('express');
const router = express.Router();
const Donation = require('../models/Donation');
const User = require('../models/User');
const Project = require('../models/Project');
const crypto = require('crypto');
const blockchainService = require('../services/blockchainService');

// POST /api/funding/donate - Make a donation
router.post('/donate', async (req, res) => {
    try {
        const { donorId, donorName, recipientId, recipientType, amount, currency, message, isAnonymous, paymentMethod, paymentToken } = req.body;

        const donationId = crypto.randomBytes(16).toString('hex');

        // Process blockchain donation if payment method is crypto
        let blockchainTxHash = null;
        let blockchainDonationId = null;
        let actualPaymentToken = paymentToken || 'USDT'; // Default to USDT

        if (paymentMethod === 'crypto' && recipientType === 'genius') {
            try {
                console.log(`Processing blockchain donation for genius: ${recipientId} with ${actualPaymentToken}`);
                const blockchainResult = await blockchainService.processDonation(
                    recipientId,
                    amount,
                    message || '',
                    isAnonymous || false,
                    actualPaymentToken
                );

                if (blockchainResult.success) {
                    blockchainTxHash = blockchainResult.transactionHash;
                    blockchainDonationId = blockchainResult.donationId;
                    console.log('Blockchain donation successful:', blockchainTxHash);
                    console.log(`Funds automatically forwarded to admin wallet in ${actualPaymentToken}`);
                }
            } catch (blockchainError) {
                console.error('Blockchain donation failed, falling back to database only:', blockchainError.message);
                // Continue with database record even if blockchain fails
            }
        }

        const donation = new Donation({
            donationId,
            donorId,
            donorName: isAnonymous ? 'Anonymous' : donorName,
            recipientId,
            recipientType,
            amount,
            currency: currency || 'USD',
            message,
            isAnonymous,
            paymentMethod: paymentMethod || 'card',
            paymentStatus: 'completed',
            transactionId: blockchainTxHash || donationId // Use blockchain tx hash if available
        });
        await donation.save();

        // Update recipient stats
        if (recipientType === 'genius') {
            await User.findOneAndUpdate(
                { userId: recipientId },
                { $inc: { donationsTotal: amount } }
            );
        } else if (recipientType === 'project') {
            await Project.findOneAndUpdate(
                { projectId: recipientId },
                { $inc: { fundingRaised: amount, supportersCount: 1 } }
            );
        }

        // Update donor stats
        await User.findOneAndUpdate(
            { userId: donorId },
            { $inc: { donationsTotal: amount } }
        );

        res.status(201).json({
            success: true,
            data: donation,
            blockchain: blockchainTxHash ? {
                transactionHash: blockchainTxHash,
                donationId: blockchainDonationId,
                forwardedToAdmin: true,
                explorer: blockchainService.getExplorerUrl(blockchainTxHash)
            } : null
        });
    } catch (error) {
        console.error('Donation error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/funding/history/:userId - Get donation history
router.get('/history/:userId', async (req, res) => {
    try {
        const donations = await Donation.find({ donorId: req.params.userId })
            .sort({ createdAt: -1 })
            .limit(100);
        
        res.json({ success: true, data: donations });
    } catch (error) {
        console.error('Get donation history error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/funding/received/:userId - Get donations received by genius
router.get('/received/:userId', async (req, res) => {
    try {
        const donations = await Donation.find({ 
            recipientId: req.params.userId,
            recipientType: 'genius'
        }).sort({ createdAt: -1 }).limit(100);
        
        const total = donations.reduce((sum, d) => sum + d.amount, 0);
        
        res.json({ success: true, data: { donations, total, count: donations.length } });
    } catch (error) {
        console.error('Get received donations error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/funding/transparency - Get transparency dashboard data
router.get('/transparency', async (req, res) => {
    try {
        // Get all donations
        const allDonations = await Donation.find({ paymentStatus: 'completed' });
        
        const totalRaised = allDonations.reduce((sum, d) => sum + d.amount, 0);
        const totalDonors = new Set(allDonations.map(d => d.donorId)).size;
        
        // Group by recipient type
        const byType = {
            genius: allDonations.filter(d => d.recipientType === 'genius').reduce((sum, d) => sum + d.amount, 0),
            project: allDonations.filter(d => d.recipientType === 'project').reduce((sum, d) => sum + d.amount, 0),
            product: allDonations.filter(d => d.recipientType === 'product').reduce((sum, d) => sum + d.amount, 0)
        };
        
        // Recent donations (anonymized)
        const recentDonations = allDonations
            .sort((a, b) => b.createdAt - a.createdAt)
            .slice(0, 20)
            .map(d => ({
                amount: d.amount,
                currency: d.currency,
                recipientType: d.recipientType,
                createdAt: d.createdAt,
                donorName: d.isAnonymous ? 'Anonymous' : d.donorName
            }));
        
        res.json({
            success: true,
            data: {
                totalRaised,
                totalDonors,
                totalTransactions: allDonations.length,
                byType,
                recentDonations
            }
        });
    } catch (error) {
        console.error('Get transparency data error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/funding/project/:projectId - Get project funding details
router.get('/project/:projectId', async (req, res) => {
    try {
        const project = await Project.findOne({ projectId: req.params.projectId });
        if (!project) {
            return res.status(404).json({ success: false, error: 'Project not found' });
        }
        
        const donations = await Donation.find({ 
            recipientId: req.params.projectId,
            recipientType: 'project'
        }).sort({ createdAt: -1 }).limit(50);
        
        res.json({
            success: true,
            data: {
                fundingGoal: project.fundingGoal,
                fundingRaised: project.fundingRaised,
                supportersCount: project.supportersCount,
                percentageFunded: Math.round((project.fundingRaised / project.fundingGoal) * 100),
                recentDonations: donations.map(d => ({
                    amount: d.amount,
                    donorName: d.isAnonymous ? 'Anonymous' : d.donorName,
                    message: d.message,
                    createdAt: d.createdAt
                }))
            }
        });
    } catch (error) {
        console.error('Get project funding error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

