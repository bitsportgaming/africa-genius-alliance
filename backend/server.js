require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const http = require('http');
const { Server } = require('socket.io');

const postsRouter = require('./routes/posts');
const usersRouter = require('./routes/users');
const messagesRouter = require('./routes/messages');
const commentsRouter = require('./routes/comments');
const liveRouter = require('./routes/live');
const authRouter = require('./routes/auth');
const electionsRouter = require('./routes/elections');
const votingRouter = require('./routes/voting');
const projectsRouter = require('./routes/projects');
const fundingRouter = require('./routes/funding');
const proposalsRouter = require('./routes/proposals');
const productsRouter = require('./routes/products');
const adminRouter = require('./routes/admin');
const uploadRouter = require('./routes/upload');
const notificationsRouter = require('./routes/notifications');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST']
    }
});

const PORT = process.env.PORT || 3000;

// Store active streams and their connections
const activeStreams = new Map(); // streamId -> { hostSocketId, viewers: Set<socketId> }

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Serve uploaded files statically
app.use('/uploads', express.static(uploadsDir));

// Routes
app.use('/api/auth', authRouter);
app.use('/api/posts', postsRouter);
app.use('/api/users', usersRouter);
app.use('/api/messages', messagesRouter);
app.use('/api/comments', commentsRouter);
app.use('/api/live', liveRouter);
app.use('/api/elections', electionsRouter);
app.use('/api/voting', votingRouter);
app.use('/api/projects', projectsRouter);
app.use('/api/funding', fundingRouter);
app.use('/api/proposals', proposalsRouter);
app.use('/api/products', productsRouter);
app.use('/api/admin', adminRouter);
app.use('/api/upload', uploadRouter);
app.use('/api/notifications', notificationsRouter);

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        mongodb: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err.message);
    res.status(500).json({ 
        success: false, 
        error: err.message || 'Internal server error' 
    });
});

// In-memory fallback storage when MongoDB is not available
let inMemoryPosts = [];
let useInMemory = false;

// In-memory routes for fallback mode
const setupInMemoryRoutes = () => {
    // Override posts routes with in-memory versions
    app.get('/api/posts', (req, res) => {
        const { page = 1, limit = 20 } = req.query;
        const startIndex = (page - 1) * limit;
        const endIndex = page * limit;
        const paginatedPosts = inMemoryPosts.slice(startIndex, endIndex);

        res.json({
            success: true,
            data: paginatedPosts,
            pagination: {
                page: parseInt(page),
                limit: parseInt(limit),
                total: inMemoryPosts.length,
                pages: Math.ceil(inMemoryPosts.length / limit)
            }
        });
    });

    app.post('/api/posts', (req, res) => {
        const { authorId, authorName, authorAvatar, authorPosition, content } = req.body;

        const newPost = {
            _id: Date.now().toString(),
            authorId: authorId || 'anonymous',
            authorName: authorName || 'Anonymous User',
            authorAvatar: authorAvatar || null,
            authorPosition: authorPosition || null,
            content: content || '',
            mediaURLs: [],
            mediaType: null,
            postType: 'text',
            likesCount: 0,
            commentsCount: 0,
            sharesCount: 0,
            likedBy: [],
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };

        inMemoryPosts.unshift(newPost);
        res.status(201).json({ success: true, data: newPost });
    });

    app.post('/api/posts/:id/like', (req, res) => {
        const { id } = req.params;
        const { userId } = req.body;

        const post = inMemoryPosts.find(p => p._id === id);
        if (!post) {
            return res.status(404).json({ success: false, error: 'Post not found' });
        }

        const likedIndex = post.likedBy.indexOf(userId);
        let liked = false;

        if (likedIndex === -1) {
            post.likedBy.push(userId);
            post.likesCount++;
            liked = true;
        } else {
            post.likedBy.splice(likedIndex, 1);
            post.likesCount--;
        }

        res.json({ success: true, data: post, liked });
    });

    console.log('📦 In-memory routes configured');
};

// WebRTC Signaling via Socket.IO
io.on('connection', (socket) => {
    console.log(`📡 Client connected: ${socket.id}`);

    // Host starts a stream
    socket.on('start-stream', ({ streamId, hostId }) => {
        console.log(`🎬 Stream started: ${streamId} by host ${hostId}`);
        activeStreams.set(streamId, {
            hostSocketId: socket.id,
            hostId,
            viewers: new Set()
        });
        socket.join(streamId);
        socket.streamId = streamId;
        socket.isHost = true;
    });

    // Viewer joins a stream
    socket.on('join-stream', ({ streamId, viewerId }) => {
        const stream = activeStreams.get(streamId);
        if (!stream) {
            socket.emit('error', { message: 'Stream not found' });
            return;
        }
        console.log(`👁 Viewer ${viewerId} joining stream ${streamId}`);
        stream.viewers.add(socket.id);
        socket.join(streamId);
        socket.streamId = streamId;
        socket.viewerId = viewerId;

        // Notify host that a new viewer wants to connect
        io.to(stream.hostSocketId).emit('viewer-joined', {
            viewerId,
            viewerSocketId: socket.id
        });
    });

    // Host sends offer to a specific viewer
    socket.on('offer', ({ targetSocketId, sdp }) => {
        console.log(`📤 Offer from ${socket.id} to ${targetSocketId}`);
        io.to(targetSocketId).emit('offer', {
            sdp,
            hostSocketId: socket.id
        });
    });

    // Viewer sends answer back to host
    socket.on('answer', ({ targetSocketId, sdp }) => {
        console.log(`📥 Answer from ${socket.id} to ${targetSocketId}`);
        io.to(targetSocketId).emit('answer', {
            sdp,
            viewerSocketId: socket.id
        });
    });

    // ICE candidate exchange
    socket.on('ice-candidate', ({ targetSocketId, candidate }) => {
        io.to(targetSocketId).emit('ice-candidate', {
            candidate,
            fromSocketId: socket.id
        });
    });

    // Host ends stream
    socket.on('end-stream', ({ streamId }) => {
        console.log(`🛑 Stream ended: ${streamId}`);
        const stream = activeStreams.get(streamId);
        if (stream) {
            io.to(streamId).emit('stream-ended');
            activeStreams.delete(streamId);
        }
    });

    // Viewer leaves stream
    socket.on('leave-stream', ({ streamId }) => {
        const stream = activeStreams.get(streamId);
        if (stream) {
            stream.viewers.delete(socket.id);
            io.to(stream.hostSocketId).emit('viewer-left', {
                viewerSocketId: socket.id
            });
        }
        socket.leave(streamId);
    });

    // Handle disconnection
    socket.on('disconnect', () => {
        console.log(`📴 Client disconnected: ${socket.id}`);

        if (socket.isHost && socket.streamId) {
            // Host disconnected - end the stream
            const stream = activeStreams.get(socket.streamId);
            if (stream) {
                io.to(socket.streamId).emit('stream-ended');
                activeStreams.delete(socket.streamId);
            }
        } else if (socket.streamId) {
            // Viewer disconnected
            const stream = activeStreams.get(socket.streamId);
            if (stream) {
                stream.viewers.delete(socket.id);
                io.to(stream.hostSocketId).emit('viewer-left', {
                    viewerSocketId: socket.id
                });
            }
        }
    });
});

// Connect to MongoDB and start server
const startServer = async () => {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/aga';

    try {
        await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 5000 });
        console.log('✅ Connected to MongoDB');
    } catch (error) {
        console.warn('⚠️  MongoDB not available:', error.message);
        console.log('📦 Running in IN-MEMORY mode (data will not persist)');
        useInMemory = true;
        setupInMemoryRoutes();
    }

    server.listen(PORT, () => {
        console.log(`🚀 AGA Backend Server running on http://localhost:${PORT}`);
        console.log(`📁 Uploads directory: ${uploadsDir}`);
        console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
        console.log(`🔌 WebRTC Signaling: ws://localhost:${PORT}`);
        console.log(`💾 Storage mode: ${useInMemory ? 'IN-MEMORY' : 'MongoDB'}`);
    });
};

startServer();

