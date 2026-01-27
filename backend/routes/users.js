const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Get user by email
router.get('/:email', async (req, res) => {
    try {
        const user = await User.findOne({ email: req.params.email });
        if (!user) return res.status(404).json({ message: 'User not found' });
        res.json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Create or Update User
router.post('/', async (req, res) => {
    const { name, email, phone, location, profileImage, role } = req.body;

    try {
        let user = await User.findOne({ email });

        if (user) {
            // Update existing
            user.name = name || user.name;
            user.phone = phone || user.phone;
            user.location = location || user.location;
            user.profileImage = profileImage || user.profileImage;
            user.role = role || user.role;
            await user.save();
            res.json(user);
        } else {
            // Create new
            user = new User({
                name,
                email,
                phone,
                location,
                profileImage,
                role
            });
            await user.save();
            res.status(201).json(user);
        }
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

module.exports = router;
