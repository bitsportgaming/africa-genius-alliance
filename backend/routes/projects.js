const express = require('express');
const router = express.Router();
const Project = require('../models/Project');
const crypto = require('crypto');

// GET /api/projects - Get all projects (with filters)
router.get('/', async (req, res) => {
    try {
        const { category, status, isNational, limit = 20 } = req.query;
        const query = {};
        
        if (category) query.category = category;
        if (status) query.status = status;
        if (isNational === 'true') query.isNationalProject = true;
        
        const projects = await Project.find(query)
            .sort({ createdAt: -1 })
            .limit(parseInt(limit));
        
        res.json({ success: true, data: projects });
    } catch (error) {
        console.error('Get projects error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/projects/national - Get national projects
router.get('/national', async (req, res) => {
    try {
        const projects = await Project.find({ isNationalProject: true, status: 'active' })
            .sort({ fundingRaised: -1 })
            .limit(20);
        
        res.json({ success: true, data: projects });
    } catch (error) {
        console.error('Get national projects error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/projects/:projectId - Get single project
router.get('/:projectId', async (req, res) => {
    try {
        const project = await Project.findOne({ projectId: req.params.projectId });
        
        if (!project) {
            return res.status(404).json({ success: false, error: 'Project not found' });
        }
        
        res.json({ success: true, data: project });
    } catch (error) {
        console.error('Get project error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/projects/user/:userId - Get user's projects
router.get('/user/:userId', async (req, res) => {
    try {
        const projects = await Project.find({ creatorId: req.params.userId })
            .sort({ createdAt: -1 });
        
        res.json({ success: true, data: projects });
    } catch (error) {
        console.error('Get user projects error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/projects - Create new project
router.post('/', async (req, res) => {
    try {
        const projectId = crypto.randomBytes(16).toString('hex');
        const project = new Project({
            projectId,
            ...req.body
        });
        await project.save();
        
        res.status(201).json({ success: true, data: project });
    } catch (error) {
        console.error('Create project error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// PUT /api/projects/:projectId - Update project
router.put('/:projectId', async (req, res) => {
    try {
        const project = await Project.findOneAndUpdate(
            { projectId: req.params.projectId },
            { $set: req.body },
            { new: true }
        );
        
        if (!project) {
            return res.status(404).json({ success: false, error: 'Project not found' });
        }
        
        res.json({ success: true, data: project });
    } catch (error) {
        console.error('Update project error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/projects/:projectId/update - Add project update
router.post('/:projectId/update', async (req, res) => {
    try {
        const { title, content } = req.body;
        
        const project = await Project.findOneAndUpdate(
            { projectId: req.params.projectId },
            { $push: { updates: { title, content, createdAt: new Date() } } },
            { new: true }
        );
        
        if (!project) {
            return res.status(404).json({ success: false, error: 'Project not found' });
        }
        
        res.json({ success: true, data: project });
    } catch (error) {
        console.error('Add project update error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

