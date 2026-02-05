const express = require('express');
const router = express.Router();
const LiveStream = require('../models/LiveStream');

// GET /api/live - Get all active live streams
router.get('/', async (req, res) => {
    try {
        const { status = 'live', limit = 20 } = req.query;
        const streams = await LiveStream.find({ status })
            .sort({ viewerCount: -1, createdAt: -1 })
            .limit(parseInt(limit));
        res.json({ success: true, data: streams });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/live/host/:hostId - Get live stream by host
router.get('/host/:hostId', async (req, res) => {
    try {
        const stream = await LiveStream.findOne({ hostId: req.params.hostId, status: 'live' });
        if (!stream) {
            return res.json({ success: true, data: null, isLive: false });
        }
        res.json({ success: true, data: stream, isLive: true });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/live/host/:hostId/scheduled - Get scheduled live streams for a host
router.get('/host/:hostId/scheduled', async (req, res) => {
    try {
        const streams = await LiveStream.find({
            hostId: req.params.hostId,
            status: 'scheduled',
            scheduledStartTime: { $gte: new Date() } // Only future scheduled streams
        }).sort({ scheduledStartTime: 1 });
        res.json({ success: true, data: streams });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/live/host/:hostId/all - Get all streams (live and scheduled) for a host
router.get('/host/:hostId/all', async (req, res) => {
    try {
        const streams = await LiveStream.find({
            hostId: req.params.hostId,
            $or: [
                { status: 'live' },
                { status: 'scheduled', scheduledStartTime: { $gte: new Date() } }
            ]
        }).sort({ status: 1, scheduledStartTime: 1 }); // Live first, then scheduled
        res.json({ success: true, data: streams });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/live/:id - Get a specific live stream
router.get('/:id', async (req, res) => {
    try {
        const stream = await LiveStream.findById(req.params.id);
        if (!stream) {
            return res.status(404).json({ success: false, error: 'Live stream not found' });
        }
        res.json({ success: true, data: stream });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/live/schedule - Schedule a live stream for later
router.post('/schedule', async (req, res) => {
    try {
        const { hostId, hostName, hostAvatar, hostPosition, title, description, category, tags, scheduledStartTime } = req.body;
        if (!hostId || !hostName || !title || !scheduledStartTime) {
            return res.status(400).json({ success: false, error: 'hostId, hostName, title, and scheduledStartTime are required' });
        }

        const scheduledDate = new Date(scheduledStartTime);
        if (scheduledDate <= new Date()) {
            return res.status(400).json({ success: false, error: 'Scheduled time must be in the future' });
        }

        const streamKey = hostId + '-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
        const stream = new LiveStream({
            hostId, hostName, hostAvatar, hostPosition, title,
            description: description || '', category: category || 'general', tags: tags || [],
            status: 'scheduled', scheduledStartTime: scheduledDate, streamKey
        });
        await stream.save();
        res.status(201).json({ success: true, data: stream });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/live/start - Start a new live stream
router.post('/start', async (req, res) => {
    try {
        const { hostId, hostName, hostAvatar, hostPosition, title, description, category, tags } = req.body;
        if (!hostId || !hostName || !title) {
            return res.status(400).json({ success: false, error: 'hostId, hostName, and title are required' });
        }
        const existingStream = await LiveStream.findOne({ hostId, status: 'live' });
        if (existingStream) {
            return res.status(400).json({ success: false, error: 'You already have an active live stream', data: existingStream });
        }
        const streamKey = hostId + '-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
        const stream = new LiveStream({
            hostId, hostName, hostAvatar, hostPosition, title,
            description: description || '', category: category || 'general', tags: tags || [],
            status: 'live', actualStartTime: new Date(), streamKey
        });
        await stream.save();
        res.status(201).json({ success: true, data: stream });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/live/:id/stop - End a live stream
router.post('/:id/stop', async (req, res) => {
    try {
        const stream = await LiveStream.findById(req.params.id);
        if (!stream) {
            return res.status(404).json({ success: false, error: 'Live stream not found' });
        }
        stream.status = 'ended';
        stream.endTime = new Date();
        stream.currentViewers = [];
        stream.viewerCount = 0;
        await stream.save();
        res.json({ success: true, data: stream });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/live/:id/join - Join a live stream as viewer
router.post('/:id/join', async (req, res) => {
    try {
        const { userId } = req.body;
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }
        const stream = await LiveStream.findById(req.params.id);
        if (!stream || stream.status !== 'live') {
            return res.status(404).json({ success: false, error: 'Live stream not found or not active' });
        }
        if (!stream.currentViewers.includes(userId)) {
            stream.currentViewers.push(userId);
            stream.viewerCount = stream.currentViewers.length;
            stream.totalViews += 1;
            if (stream.viewerCount > stream.peakViewerCount) {
                stream.peakViewerCount = stream.viewerCount;
            }
            await stream.save();
        }
        res.json({ success: true, data: stream });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/live/:id/leave - Leave a live stream
router.post('/:id/leave', async (req, res) => {
    try {
        const { userId } = req.body;
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }
        const stream = await LiveStream.findById(req.params.id);
        if (!stream) {
            return res.status(404).json({ success: false, error: 'Live stream not found' });
        }
        stream.currentViewers = stream.currentViewers.filter(id => id !== userId);
        stream.viewerCount = stream.currentViewers.length;
        await stream.save();
        res.json({ success: true, data: stream });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/live/:id/like - Like/unlike a live stream
router.post('/:id/like', async (req, res) => {
    try {
        const { userId } = req.body;
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }
        const stream = await LiveStream.findById(req.params.id);
        if (!stream) {
            return res.status(404).json({ success: false, error: 'Live stream not found' });
        }
        const alreadyLiked = stream.likedBy.includes(userId);
        if (alreadyLiked) {
            stream.likedBy = stream.likedBy.filter(id => id !== userId);
            stream.likesCount = Math.max(0, stream.likesCount - 1);
        } else {
            stream.likedBy.push(userId);
            stream.likesCount += 1;
        }
        await stream.save();
        res.json({ success: true, data: stream, liked: !alreadyLiked });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/live/seed - Seed mock live streams for testing
router.post('/seed', async (req, res) => {
    try {
        // Clear existing live streams
        await LiveStream.deleteMany({ status: 'live' });

        const mockStreams = [
            {
                hostId: 'genius1',
                hostName: 'Amara Okonkwo',
                hostPosition: 'Tech Innovator',
                title: 'Building the Future of African Tech',
                description: 'Join me as I discuss the latest innovations in African technology',
                status: 'live',
                viewerCount: 127,
                peakViewerCount: 145,
                likesCount: 89,
                category: 'technology'
            },
            {
                hostId: 'genius2',
                hostName: 'Kwame Asante',
                hostPosition: 'Education Leader',
                title: 'Q&A: Education Reform in Africa',
                description: 'Live Q&A session about education reform initiatives',
                status: 'live',
                viewerCount: 84,
                peakViewerCount: 102,
                likesCount: 56,
                category: 'education'
            },
            {
                hostId: 'genius3',
                hostName: 'Fatima Diallo',
                hostPosition: 'Healthcare Advocate',
                title: 'Healthcare Access for All',
                description: 'Discussing healthcare accessibility in rural communities',
                status: 'live',
                viewerCount: 63,
                peakViewerCount: 78,
                likesCount: 41,
                category: 'healthcare'
            }
        ];

        const created = await LiveStream.insertMany(mockStreams);
        res.json({ success: true, data: created, message: `Created ${created.length} mock live streams` });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
