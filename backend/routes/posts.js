const express = require('express');
const router = express.Router();
const Post = require('../models/Post');

// Get all posts
router.get('/', async (req, res) => {
    try {
        const posts = await Post.find().sort({ date: -1 });
        res.json(posts);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Create a post
router.post('/', async (req, res) => {
    const post = new Post({
        authorName: req.body.authorName || 'Anonymous',
        authorLocation: req.body.authorLocation || 'India',
        cropName: req.body.cropName,
        title: req.body.title,
        description: req.body.description,
        image: req.body.image,
        tags: req.body.tags || []
    });

    try {
        const newPost = await post.save();
        res.status(201).json(newPost);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Add a comment/answer
router.post('/:id/comments', async (req, res) => {
    try {
        const post = await Post.findById(req.params.id);
        if (!post) return res.status(404).json({ message: 'Post not found' });

        const comment = {
            authorName: req.body.authorName || 'Community Member',
            text: req.body.text,
            isExpert: req.body.isExpert || false
        };

        post.comments.push(comment);
        await post.save();
        res.json(post);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;
