const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const crypto = require('crypto');

// GET /api/products - Get all products (marketplace)
router.get('/', async (req, res) => {
    try {
        const { category, status = 'active', limit = 20 } = req.query;
        const query = { status };
        
        if (category) query.category = category;
        
        const products = await Product.find(query)
            .sort({ createdAt: -1 })
            .limit(parseInt(limit));
        
        res.json({ success: true, data: products });
    } catch (error) {
        console.error('Get products error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/products/featured - Get featured/top impact products
router.get('/featured', async (req, res) => {
    try {
        const products = await Product.find({ status: 'active' })
            .sort({ totalImpactGenerated: -1 })
            .limit(10);
        
        res.json({ success: true, data: products });
    } catch (error) {
        console.error('Get featured products error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/products/:productId - Get single product
router.get('/:productId', async (req, res) => {
    try {
        const product = await Product.findOne({ productId: req.params.productId });
        
        if (!product) {
            return res.status(404).json({ success: false, error: 'Product not found' });
        }
        
        res.json({ success: true, data: product });
    } catch (error) {
        console.error('Get product error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/products - Create new product
router.post('/', async (req, res) => {
    try {
        const productId = crypto.randomBytes(16).toString('hex');
        const product = new Product({
            productId,
            ...req.body
        });
        await product.save();
        
        res.status(201).json({ success: true, data: product });
    } catch (error) {
        console.error('Create product error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/products/:productId/purchase - Purchase product
router.post('/:productId/purchase', async (req, res) => {
    try {
        const { buyerId, quantity = 1 } = req.body;
        
        const product = await Product.findOne({ productId: req.params.productId });
        if (!product) {
            return res.status(404).json({ success: false, error: 'Product not found' });
        }
        
        if (product.stock !== -1 && product.stock < quantity) {
            return res.status(400).json({ success: false, error: 'Insufficient stock' });
        }
        
        const impactGenerated = (product.price * quantity * product.impactPercentage) / 100;
        
        // Update product
        const updates = {
            $inc: { 
                soldCount: quantity,
                totalImpactGenerated: impactGenerated
            }
        };
        
        if (product.stock !== -1) {
            updates.$inc.stock = -quantity;
        }
        
        const updatedProduct = await Product.findOneAndUpdate(
            { productId: req.params.productId },
            updates,
            { new: true }
        );
        
        res.json({ 
            success: true, 
            data: {
                product: updatedProduct,
                impactGenerated,
                total: product.price * quantity
            }
        });
    } catch (error) {
        console.error('Purchase product error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

