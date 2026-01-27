const mongoose = require('mongoose');

const ScanResultSchema = new mongoose.Schema({
    userId: { type: String, required: true },
    diseaseName: { type: String, required: true },
    confidence: { type: Number, required: true },
    imagePath: { type: String }, // Storing path or URL
    date: { type: Date, default: Date.now },
    notes: { type: String }
});

module.exports = mongoose.model('ScanResult', ScanResultSchema);
