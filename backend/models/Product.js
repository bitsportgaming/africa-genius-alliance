const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    productId: {
        type: String,
        required: true,
        unique: true
    },
    name: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: true
    },
    price: {
        type: Number,
        required: true
    },
    currency: {
        type: String,
        default: 'USD'
    },
    category: {
        type: String,
        enum: ['apparel', 'crafts', 'art', 'food', 'tech', 'education', 'other'],
        required: true
    },
    imageURL: {
        type: String,
        default: null
    },
    images: [{
        type: String
    }],
    sellerId: {
        type: String,
        required: true
    },
    sellerName: {
        type: String,
        required: true
    },
    // Impact tracking
    impactCause: {
        type: String,
        required: true
    },
    impactPercentage: {
        type: Number,
        default: 10 // Percentage of price going to cause
    },
    beneficiaryId: {
        type: String,
        default: null // Genius or project that benefits
    },
    beneficiaryType: {
        type: String,
        enum: ['genius', 'project', 'community'],
        default: 'community'
    },
    stock: {
        type: Number,
        default: -1 // -1 means unlimited
    },
    soldCount: {
        type: Number,
        default: 0
    },
    totalImpactGenerated: {
        type: Number,
        default: 0
    },
    status: {
        type: String,
        enum: ['active', 'out_of_stock', 'discontinued'],
        default: 'active'
    },
    rating: {
        average: { type: Number, default: 0 },
        count: { type: Number, default: 0 }
    }
}, {
    timestamps: true
});

productSchema.index({ category: 1, status: 1 });
productSchema.index({ sellerId: 1 });
productSchema.index({ beneficiaryId: 1, beneficiaryType: 1 });

module.exports = mongoose.model('Product', productSchema);

