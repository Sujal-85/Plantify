const mongoose = require('mongoose');
const Post = require('./models/Post');
const User = require('./models/User');
const dotenv = require('dotenv');

dotenv.config();

mongoose.connect(process.env.MONGO_URI || 'mongodb+srv://agrivision:agrivision@plantanalysis.fwhhtqi.mongodb.net/agrivision?appName=PlantAnalysis')
    .then(async () => {
        console.log('Connected to MongoDB for seeding...');

        // Clear existing data
        await Post.deleteMany({});
        await User.deleteMany({});

        // Create Users
        const users = await User.insertMany([
            {
                name: 'Saurabh Kumar',
                email: 'saurabh@example.com',
                location: 'Pune, India',
                role: 'Farmer',
                profileImage: 'https://randomuser.me/api/portraits/men/1.jpg'
            },
            {
                name: 'Anjali Gupta',
                email: 'anjali@example.com',
                location: 'Nashik, India',
                role: 'Researcher',
                profileImage: 'https://randomuser.me/api/portraits/women/2.jpg'
            },
            {
                name: 'Rajesh Singh',
                email: 'rajesh@example.com',
                location: 'Punjab, India',
                role: 'Farmer',
                profileImage: 'https://randomuser.me/api/portraits/men/3.jpg'
            }
        ]);

        const saurabh = users[0];
        const anjali = users[1];
        const rajesh = users[2];

        // Create Posts
        const dummyPosts = [
            {
                authorName: saurabh.name,
                authorLocation: saurabh.location,
                cropName: 'Banana',
                title: 'Help identifying problem with my Banana',
                description: 'Plantix has detected a possible problem with my Banana. I was given a few possibilities: Bunchy Top Virus, Potassium Deficiency. Can you help me identify?',
                image: 'https://www.bananalink.org.uk/wp-content/uploads/2019/02/problem-bananas.jpg',
                tags: ['Banana', 'Virus'],
                comments: [
                    {
                        authorName: anjali.name,
                        text: 'Leaf Blotch of Banana. Please check for fungal infections and reduce moisture.',
                        isExpert: true
                    }
                ]
            },
            {
                authorName: rajesh.name,
                authorLocation: rajesh.location,
                cropName: 'Wheat',
                title: 'Yellow rust on Wheat leaves',
                description: 'Found these yellow streaks on my wheat crop this morning. Is it rust? What fungicide should I use?',
                image: 'https://tse3.mm.bing.net/th/id/OIP.SgwLQdlu1LKsvY83oK3qqAHaEL?cb=defcachec2&rs=1&pid=ImgDetMain&o=7&rm=3',
                tags: ['Wheat', 'Rust', 'Fungus'],
                comments: []
            },
            {
                authorName: 'Subrat Malik',
                authorLocation: 'Odisha, India',
                cropName: 'Bean',
                title: 'Help identifying problem with my Bean',
                description: 'My bean leaves have white squiggly lines. I suspect Leaf Miner Flies. Any organic solutions?',
                image: 'https://tse3.mm.bing.net/th/id/OIP.FPV4expM8goPcz1lQeudcgHaEO?cb=defcachec2&rs=1&pid=ImgDetMain&o=7&rm=3',
                tags: ['Bean', 'Pest'],
                comments: []
            },
            {
                authorName: anjali.name,
                authorLocation: anjali.location,
                cropName: 'Tomato',
                title: 'Early Blight symptoms?',
                description: ' concentric rings on lower leaves. Looks like early blight. Confirm?',
                image: 'https://sowmanyplants.com/wp-content/uploads/2023/08/EarlyBlightFeatured.webp',
                tags: ['Tomato', 'Blight'],
                comments: []
            },
            {
                authorName: 'Vikram Patel',
                authorLocation: 'Gujarat, India',
                cropName: 'Cotton',
                title: 'Pink Bollworm infestation',
                description: 'Seeing sign of bollworm. Need advice on trap crops.',
                image: 'https://content.woolovers.com/img/o/cotton3.jpg?mobileinline',
                tags: ['Cotton', 'Pest'],
                comments: []
            },
            {
                authorName: saurabh.name,
                authorLocation: saurabh.location,
                cropName: 'Rice',
                title: 'Brown spots on rice grains',
                description: 'Harvest time approaches and I see these spots. Is quality affected?',
                image: 'https://assets.bonappetit.com/photos/642720f6ec335a4c6f408954/16:9/w_2560%2Cc_limit/Bad_Rice_BonAppetit-1.jpg',
                tags: ['Rice', 'Disease'],
                comments: []
            },
            {
                authorName: rajesh.name,
                authorLocation: rajesh.location,
                cropName: 'Potato',
                title: 'Potato leaves drying up',
                description: 'Sudden drying of leaves. Late blight?',
                image: 'https://images.livemint.com/img/2021/02/07/1600x900/20210109248L_1610278489852_1610278522190_1612705072495.jpg',
                tags: ['Potato', 'Blight'],
                comments: []
            },
            {
                authorName: anjali.name,
                authorLocation: anjali.location,
                cropName: 'Sugarcane',
                title: 'Red Rot in Sugarcane',
                description: 'Stems turning red inside. How to manage for next season?',
                image: "https://th.bing.com/th/id/OIP.WZu9EGc2qHy4M58S3Tfz0QHaEy?w=342&h=181&c=7&r=0&o=7&cb=defcachec2&dpr=1.3&pid=1.7&rm=3",
                tags: ['Sugarcane', 'RedRot'],
                comments: []
            }
        ];

        await Post.insertMany(dummyPosts);
        console.log(`Seeding Complete! Added ${users.length} users and ${dummyPosts.length} posts.`);
        process.exit();
    })
    .catch(err => {
        console.log(err);
        process.exit(1);
    });
