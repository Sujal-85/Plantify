const mongoose = require('mongoose');

const PostSchema = new mongoose.Schema({
    authorName: { type: String, required: true },
    authorLocation: { type: String, default: 'India' },
    cropName: { type: String, required: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
    image: { type: String }, // Base64 or URL
    tags: [String],
    likes: { type: Number, default: 0 },
    date: { type: Date, default: Date.now },
    comments: [
        {
            authorName: String,
            text: String,
            isExpert: { type: Boolean, default: false },
            date: { type: Date, default: Date.now }
        }
    ]
});

module.exports = mongoose.model('Post', PostSchema);
