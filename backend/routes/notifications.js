const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');

// GET /api/notifications - Get user's notifications
router.get('/', async (req, res) => {
    try {
        const { userId, limit = 50, unreadOnly = false } = req.query;
        
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }

        const query = { userId };
        if (unreadOnly === 'true') {
            query.isRead = false;
        }

        const notifications = await Notification.find(query)
            .sort({ createdAt: -1 })
            .limit(parseInt(limit));

        res.json({ success: true, data: notifications });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/notifications/unread-count - Get unread notification count
router.get('/unread-count', async (req, res) => {
    try {
        const { userId } = req.query;
        
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }

        const count = await Notification.countDocuments({ userId, isRead: false });
        res.json({ success: true, data: { count } });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/notifications/:id/read - Mark notification as read
router.post('/:id/read', async (req, res) => {
    try {
        const { id } = req.params;
        
        await Notification.findByIdAndUpdate(id, { isRead: true });
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/notifications/read-all - Mark all notifications as read
router.post('/read-all', async (req, res) => {
    try {
        const { userId } = req.body;
        
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }

        await Notification.updateMany({ userId, isRead: false }, { isRead: true });
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/notifications - Create a notification (internal use)
router.post('/', async (req, res) => {
    try {
        const { userId, type, title, message, relatedPostId, relatedUserId, relatedUserName, metadata } = req.body;
        
        if (!userId || !type || !title || !message) {
            return res.status(400).json({ success: false, error: 'userId, type, title, and message are required' });
        }

        const notification = new Notification({
            userId,
            type,
            title,
            message,
            relatedPostId,
            relatedUserId,
            relatedUserName,
            metadata
        });

        await notification.save();
        res.status(201).json({ success: true, data: notification });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// DELETE /api/notifications/:id - Delete a notification
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await Notification.findByIdAndDelete(id);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

