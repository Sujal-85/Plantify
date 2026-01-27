const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String },
    location: { type: String },
    profileImage: { type: String }, // URL or Base64
    role: { type: String, default: 'Farmer' },
    joinedDate: { type: Date, default: Date.now }
});

module.exports = mongoose.model('User', UserSchema);
