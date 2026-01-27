const express = require('express');
const router = express.Router();
const multer = require('multer');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');

const upload = multer({ dest: 'uploads/' });
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Helper to convert file to GoogleGenerativeAI.Part
function fileToGenerativePart(path, mimeType) {
    // Gemini refuses 'application/octet-stream'. Default to 'image/jpeg' if generic.
    const safeMimeType = (mimeType === 'application/octet-stream') ? 'image/jpeg' : mimeType;
    return {
        inlineData: {
            data: Buffer.from(fs.readFileSync(path)).toString('base64'),
            mimeType: safeMimeType,
        },
    };
}

// @route   POST api/ai/diagnose
// @desc    Diagnose plant disease from image
router.post('/diagnose', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: 'No image provided' });

        const model = genAI.getGenerativeModel({ model: 'gemini-3-flash-preview' });
        const prompt = `
      Identify the disease in this plant leaf. Provide output in strictly this JSON format:
      {
        "diseaseName": "Name of disease or 'Healthy'",
        "confidence": 0.95,
        "description": "Short description of the disease.",
        "recommendation": "Key treatment recommendation."
      }
      Just the raw JSON.
    `;

        const imagePart = fileToGenerativePart(req.file.path, req.file.mimetype);
        const result = await model.generateContent([prompt, imagePart]);
        const response = await result.response;
        let text = response.text();

        // Cleanup file
        fs.unlinkSync(req.file.path);

        // Parse JSON
        text = text.replace(/```json/g, '').replace(/```/g, '').trim();
        const data = JSON.parse(text);
        res.json(data);

    } catch (err) {
        console.error('AI Diagnose Error:', err);
        if (req.file) fs.unlinkSync(req.file.path);
        res.status(500).json({ error: 'AI Diagnosis failed', details: err.message });
    }
});

// @route   POST api/ai/identify
// @desc    Identify plant from image
router.post('/identify', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: 'No image provided' });

        const model = genAI.getGenerativeModel({ model: 'gemini-3-flash-preview' });
        const prompt = `
      Identify this plant. Provide the output in strictly this JSON format:
      {
        "name": "Common Name",
        "scientificName": "Scientific Name",
        "indianName": "Indian/Local Name (in English script)",
        "description": "Short description (2 sentences).",
        "uses": "Key uses."
      }
      Do not include markdown formatting like \`\`\`json. Just the raw JSON.
    `;

        const imagePart = fileToGenerativePart(req.file.path, req.file.mimetype);
        const result = await model.generateContent([prompt, imagePart]);
        const response = await result.response;
        let text = response.text();

        // Cleanup file
        fs.unlinkSync(req.file.path);

        // Parse JSON
        text = text.replace(/```json/g, '').replace(/```/g, '').trim();
        const data = JSON.parse(text);
        res.json(data);

    } catch (err) {
        console.error('AI Identify Error:', err);
        if (req.file) fs.unlinkSync(req.file.path);
        res.status(500).json({ error: 'AI Identification failed', details: err.message });
    }
});

// @route   POST api/ai/chat
// @desc    Get chat response from Gemini
router.post('/chat', async (req, res) => {
    try {
        const { message, history } = req.body;
        const model = genAI.getGenerativeModel({ model: 'gemini-3-flash-preview' });

        // Convert history if provided
        const chat = model.startChat({
            history: history || [],
        });

        const result = await chat.sendMessage(message);
        const response = await result.response;
        res.json({ text: response.text() });
    } catch (err) {
        console.error('AI Chat Error:', err);
        res.status(500).json({ error: 'AI Chat failed', details: err.message });
    }
});

// @route   POST api/ai/article
// @desc    Generate plant article
router.post('/article', async (req, res) => {
    try {
        const { plantName } = req.body;
        const model = genAI.getGenerativeModel({ model: 'gemini-3-flash-preview' });
        const prompt = `
      Write a detailed, engaging, and professional research article about the plant "${plantName}".
      The article should include sections: Title, Unlock the Secrets (care tips), Troubleshooting Tips, and Conclusion.
      Format using markdown.
    `;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        res.json({ text: response.text() });
    } catch (err) {
        console.error('AI Article Error:', err);
        res.status(500).json({ error: 'AI Article generation failed', details: err.message });
    }
});

module.exports = router;
