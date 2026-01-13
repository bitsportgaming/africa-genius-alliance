const express = require('express');
const router = express.Router();
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');

// GET /api/messages/conversations - Get user's conversations
router.get('/conversations', async (req, res) => {
    try {
        const { userId } = req.query;
        
        if (!userId) {
            return res.status(400).json({ success: false, error: 'userId is required' });
        }

        const conversations = await Conversation.find({
            participants: userId,
            isActive: true
        }).sort({ updatedAt: -1 });

        res.json({ success: true, data: conversations });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/messages/conversations - Create or get existing conversation
router.post('/conversations', async (req, res) => {
    try {
        const { participants, participantNames, participantAvatars, isGroup, groupName } = req.body;

        if (!participants || participants.length < 2) {
            return res.status(400).json({ success: false, error: 'At least 2 participants required' });
        }

        // For 1:1 chats, check if conversation already exists
        if (!isGroup) {
            const existingConvo = await Conversation.findOne({
                participants: { $all: participants, $size: participants.length },
                isGroup: false
            });

            if (existingConvo) {
                return res.json({ success: true, data: existingConvo, existing: true });
            }
        }

        const conversation = new Conversation({
            participants,
            participantNames: participantNames || [],
            participantAvatars: participantAvatars || [],
            isGroup: isGroup || false,
            groupName: groupName || null,
            unreadCount: new Map(participants.map(p => [p, 0]))
        });

        await conversation.save();
        res.status(201).json({ success: true, data: conversation });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/messages/conversations/:id - Get messages for a conversation
router.get('/conversations/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { page = 1, limit = 50 } = req.query;

        const messages = await Message.find({ conversationId: id, isDeleted: false })
            .sort({ createdAt: -1 })
            .skip((page - 1) * limit)
            .limit(parseInt(limit));

        const total = await Message.countDocuments({ conversationId: id, isDeleted: false });

        res.json({
            success: true,
            data: messages.reverse(),
            pagination: {
                page: parseInt(page),
                limit: parseInt(limit),
                total,
                pages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/messages/conversations/:id - Send a message
router.post('/conversations/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { senderId, senderName, senderAvatar, content, messageType } = req.body;

        if (!senderId || !content) {
            return res.status(400).json({ success: false, error: 'senderId and content are required' });
        }

        const conversation = await Conversation.findById(id);
        if (!conversation) {
            return res.status(404).json({ success: false, error: 'Conversation not found' });
        }

        const message = new Message({
            conversationId: id,
            senderId,
            senderName: senderName || 'Unknown',
            senderAvatar,
            content,
            messageType: messageType || 'text',
            readBy: [{ userId: senderId, readAt: new Date() }]
        });

        await message.save();

        // Update conversation's last message
        conversation.lastMessage = {
            content,
            senderId,
            senderName: senderName || 'Unknown',
            timestamp: new Date()
        };

        // Increment unread count for other participants
        conversation.participants.forEach(p => {
            if (p !== senderId) {
                const current = conversation.unreadCount.get(p) || 0;
                conversation.unreadCount.set(p, current + 1);
            }
        });

        await conversation.save();

        res.status(201).json({ success: true, data: message });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/messages/conversations/:id/read - Mark messages as read
router.post('/conversations/:id/read', async (req, res) => {
    try {
        const { id } = req.params;
        const { userId } = req.body;

        const conversation = await Conversation.findById(id);
        if (conversation) {
            conversation.unreadCount.set(userId, 0);
            await conversation.save();
        }

        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

