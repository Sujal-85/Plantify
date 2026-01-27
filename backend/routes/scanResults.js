const express = require('express');
const router = express.Router();
const ScanResult = require('../models/ScanResult');

// Get all scans for a user
router.get('/:userId', async (req, res) => {
    try {
        const results = await ScanResult.find({ userId: req.params.userId }).sort({ date: -1 });
        res.json(results);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Save a new scan result
router.post('/', async (req, res) => {
    const { userId, diseaseName, confidence, imagePath, date, notes } = req.body;

    const scanResult = new ScanResult({
        userId,
        diseaseName,
        confidence,
        imagePath,
        date: date || Date.now(),
        notes
    });

    try {
        const newResult = await scanResult.save();
        res.status(201).json(newResult);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

module.exports = router;
