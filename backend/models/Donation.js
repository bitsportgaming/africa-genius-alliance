const mongoose = require('mongoose');

const donationSchema = new mongoose.Schema({
    donationId: {
        type: String,
        required: true,
        unique: true
    },
    donorId: {
        type: String,
        required: true
    },
    donorName: {
        type: String,
        default: 'Anonymous'
    },
    recipientId: {
        type: String,
        required: true
    },
    recipientType: {
        type: String,
        enum: ['genius', 'project', 'product'],
        required: true
    },
    amount: {
        type: Number,
        required: true
    },
    currency: {
        type: String,
        default: 'USD'
    },
    paymentMethod: {
        type: String,
        enum: ['card', 'mobile_money', 'bank_transfer', 'crypto'],
        default: 'card'
    },
    paymentStatus: {
        type: String,
        enum: ['pending', 'completed', 'failed', 'refunded'],
        default: 'completed'
    },
    transactionId: {
        type: String,
        default: null
    },
    message: {
        type: String,
        default: ''
    },
    isAnonymous: {
        type: Boolean,
        default: false
    },
    // For transparency tracking
    allocation: {
        category: { type: String, default: 'general' },
        description: { type: String, default: '' }
    }
}, {
    timestamps: true
});

donationSchema.index({ donorId: 1, createdAt: -1 });
donationSchema.index({ recipientId: 1, recipientType: 1 });
donationSchema.index({ paymentStatus: 1 });

module.exports = mongoose.model('Donation', donationSchema);

