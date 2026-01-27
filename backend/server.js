require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json({ limit: '50mb' })); // Allow large images if base64
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI || 'mongodb+srv://agrivision:agrivision@plantanalysis.fwhhtqi.mongodb.net/agrivision?appName=PlantAnalysis')
    .then(() => console.log('MongoDB Connected'))
    .catch(err => console.log(err));

// Routes
const postsRoute = require('./routes/posts');
const usersRoute = require('./routes/users');
const scanResultsRoute = require('./routes/scanResults');
const aiRoute = require('./routes/ai');

app.use('/api/posts', postsRoute);
app.use('/api/users', usersRoute);
app.use('/api/scan-results', scanResultsRoute);
app.use('/api/ai', aiRoute);

app.get('/', (req, res) => {
    res.send('Plant Analysis Community API');
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
