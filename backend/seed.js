require('dotenv').config();
const mongoose = require('mongoose');
const Conversation = require('./models/Conversation');
const Message = require('./models/Message');
const Post = require('./models/Post');
const Comment = require('./models/Comment');

const mockUsers = [
    { id: 'user1', name: 'Amara Okonkwo', avatar: null, position: 'Tech Innovator' },
    { id: 'user2', name: 'Kwame Asante', avatar: null, position: 'Social Entrepreneur' },
    { id: 'user3', name: 'Fatima Diallo', avatar: null, position: 'Education Pioneer' },
    { id: 'user4', name: 'Tendai Moyo', avatar: null, position: 'Healthcare Leader' },
    { id: 'user5', name: 'Chinwe Eze', avatar: null, position: 'Climate Activist' },
];

const mockConversations = [
    {
        participants: ['currentUser', 'user1'],
        participantNames: ['You', 'Amara Okonkwo'],
        messages: [
            { sender: 'user1', content: 'Hi! I saw your profile and I\'m really impressed with your work.' },
            { sender: 'currentUser', content: 'Thank you so much! Your tech innovation projects are inspiring.' },
            { sender: 'user1', content: 'Would you be interested in collaborating on a project?' },
            { sender: 'currentUser', content: 'Absolutely! What did you have in mind?' },
            { sender: 'user1', content: 'I\'m working on an app to connect African entrepreneurs. Your skills would be perfect.' },
        ]
    },
    {
        participants: ['currentUser', 'user2'],
        participantNames: ['You', 'Kwame Asante'],
        messages: [
            { sender: 'user2', content: 'Congratulations on being selected as a Genius candidate!' },
            { sender: 'currentUser', content: 'Thanks Kwame! It\'s an honor to be part of this community.' },
            { sender: 'user2', content: 'Let me know if you need any advice. Happy to help!' },
        ]
    },
    {
        participants: ['currentUser', 'user3'],
        participantNames: ['You', 'Fatima Diallo'],
        messages: [
            { sender: 'user3', content: 'Hello! I\'d love to discuss education initiatives in West Africa.' },
            { sender: 'currentUser', content: 'That sounds great! Education is so important for our future.' },
            { sender: 'user3', content: 'Exactly! I believe technology can bridge many gaps.' },
            { sender: 'currentUser', content: 'I completely agree. When can we schedule a call?' },
            { sender: 'user3', content: 'How about next Tuesday at 3 PM?' },
            { sender: 'currentUser', content: 'Perfect! I\'ll send you a calendar invite.' },
        ]
    },
];

const mockPosts = [
    {
        authorId: 'user1',
        authorName: 'Amara Okonkwo',
        authorPosition: 'Tech Innovator',
        content: 'Excited to announce our new coding bootcamp for young Africans! 🚀 We\'re partnering with local universities to bring tech education to underserved communities. #AfricaRising #TechForGood',
        comments: [
            { authorId: 'user2', authorName: 'Kwame Asante', content: 'This is amazing! Count me in for mentorship.' },
            { authorId: 'user3', authorName: 'Fatima Diallo', content: 'Incredible initiative! Education is the key to our future.' },
        ]
    },
    {
        authorId: 'user2',
        authorName: 'Kwame Asante',
        authorPosition: 'Social Entrepreneur',
        content: 'Just returned from the African Union summit. The energy and commitment to sustainable development was inspiring! Here are my key takeaways... 🌍',
        comments: [
            { authorId: 'user1', authorName: 'Amara Okonkwo', content: 'Would love to hear more about the tech initiatives discussed!' },
        ]
    },
    {
        authorId: 'user4',
        authorName: 'Tendai Moyo',
        authorPosition: 'Healthcare Leader',
        content: 'Our mobile health clinics have now reached 50,000 patients in rural Zimbabwe! 🏥 Thank you to all our supporters and volunteers who made this possible.',
        comments: [
            { authorId: 'user5', authorName: 'Chinwe Eze', content: 'This is what real impact looks like! Congratulations!' },
            { authorId: 'user3', authorName: 'Fatima Diallo', content: 'Inspiring work Tendai! Healthcare access is so crucial.' },
            { authorId: 'user1', authorName: 'Amara Okonkwo', content: 'How can we support? Would love to contribute!' },
        ]
    },
];

async function seed() {
    try {
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/aga');
        console.log('Connected to MongoDB');

        // Clear existing data
        await Conversation.deleteMany({});
        await Message.deleteMany({});
        await Comment.deleteMany({});
        console.log('Cleared existing data');

        // Seed conversations and messages
        for (const convo of mockConversations) {
            const conversation = new Conversation({
                participants: convo.participants,
                participantNames: convo.participantNames,
                participantAvatars: [],
                isGroup: false
            });

            await conversation.save();
            console.log(`Created conversation: ${convo.participantNames.join(' & ')}`);

            let lastMessage = null;
            for (const msg of convo.messages) {
                const senderIndex = convo.participants.indexOf(msg.sender);
                const message = new Message({
                    conversationId: conversation._id,
                    senderId: msg.sender,
                    senderName: convo.participantNames[senderIndex] || msg.sender,
                    content: msg.content,
                    messageType: 'text'
                });
                await message.save();
                lastMessage = message;
            }

            if (lastMessage) {
                conversation.lastMessage = {
                    content: lastMessage.content,
                    senderId: lastMessage.senderId,
                    senderName: lastMessage.senderName,
                    timestamp: lastMessage.createdAt
                };
                await conversation.save();
            }
        }

        // Seed posts with comments
        for (const postData of mockPosts) {
            const post = new Post({
                authorId: postData.authorId,
                authorName: postData.authorName,
                authorPosition: postData.authorPosition,
                content: postData.content,
                commentsCount: postData.comments.length,
                likesCount: Math.floor(Math.random() * 50) + 10
            });
            await post.save();
            console.log(`Created post by ${postData.authorName}`);

            for (const commentData of postData.comments) {
                const comment = new Comment({
                    postId: post._id,
                    authorId: commentData.authorId,
                    authorName: commentData.authorName,
                    content: commentData.content
                });
                await comment.save();
            }
        }

        console.log('\n✅ Seed completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('Seed failed:', error);
        process.exit(1);
    }
}

seed();

