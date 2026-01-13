const User = require('../models/User');
const crypto = require('crypto');

// Simple JWT-like token generation (in production, use proper JWT)
function generateToken(userId, role) {
    const payload = JSON.stringify({ userId, role, exp: Date.now() + 24 * 60 * 60 * 1000 });
    const signature = crypto.createHmac('sha256', process.env.JWT_SECRET || 'aga-admin-secret-key')
        .update(payload)
        .digest('hex');
    return Buffer.from(payload).toString('base64') + '.' + signature;
}

function verifyToken(token) {
    try {
        const [payloadB64, signature] = token.split('.');
        const payload = Buffer.from(payloadB64, 'base64').toString();
        const expectedSig = crypto.createHmac('sha256', process.env.JWT_SECRET || 'aga-admin-secret-key')
            .update(payload)
            .digest('hex');
        
        if (signature !== expectedSig) return null;
        
        const data = JSON.parse(payload);
        if (data.exp < Date.now()) return null;
        
        return data;
    } catch (e) {
        return null;
    }
}

// Middleware to check if user is authenticated
async function isAuthenticated(req, res, next) {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ success: false, error: 'No token provided' });
    }
    
    const token = authHeader.substring(7);
    const decoded = verifyToken(token);
    
    if (!decoded) {
        return res.status(401).json({ success: false, error: 'Invalid or expired token' });
    }
    
    const user = await User.findOne({ userId: decoded.userId });
    if (!user || user.status !== 'active') {
        return res.status(401).json({ success: false, error: 'User not found or inactive' });
    }
    
    req.user = user;
    req.userId = decoded.userId;
    next();
}

// Middleware to check if user is admin
async function isAdmin(req, res, next) {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ success: false, error: 'No token provided' });
    }
    
    const token = authHeader.substring(7);
    const decoded = verifyToken(token);
    
    if (!decoded) {
        return res.status(401).json({ success: false, error: 'Invalid or expired token' });
    }
    
    const user = await User.findOne({ userId: decoded.userId });
    if (!user) {
        return res.status(401).json({ success: false, error: 'User not found' });
    }
    
    if (!['admin', 'superadmin'].includes(user.role)) {
        return res.status(403).json({ success: false, error: 'Admin access required' });
    }
    
    if (user.status !== 'active') {
        return res.status(403).json({ success: false, error: 'Account is not active' });
    }
    
    req.user = user;
    req.userId = decoded.userId;
    next();
}

// Middleware to check if user is superadmin
async function isSuperAdmin(req, res, next) {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ success: false, error: 'No token provided' });
    }
    
    const token = authHeader.substring(7);
    const decoded = verifyToken(token);
    
    if (!decoded) {
        return res.status(401).json({ success: false, error: 'Invalid or expired token' });
    }
    
    const user = await User.findOne({ userId: decoded.userId });
    if (!user || user.role !== 'superadmin') {
        return res.status(403).json({ success: false, error: 'Super admin access required' });
    }
    
    if (user.status !== 'active') {
        return res.status(403).json({ success: false, error: 'Account is not active' });
    }
    
    req.user = user;
    req.userId = decoded.userId;
    next();
}

module.exports = {
    generateToken,
    verifyToken,
    isAuthenticated,
    isAdmin,
    isSuperAdmin
};

