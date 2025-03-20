/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.https.onRequest(async (req, res) => {
    const { token, title, body } = req.body;

    if (!token || !title || !body) {
        return res.status(400).send("Missing required fields");
    }

    const message = {
        token: token,
        notification: {
            title: title,
            body: body,
        },
    };

    try {
        await admin.messaging().send(message);
        return res.status(200).send("Notification sent successfully");
    } catch (error) {
        console.error("Error sending notification:", error);
        return res.status(500).send("Failed to send notification");
    }
});

exports.sendTopicNotification = functions.https.onRequest(async (req, res) => {
    const { topic, title, body } = req.body;

    if (!topic || !title || !body) {
        return res.status(400).send("Missing required fields");
    }

    const message = {
        topic: topic,
        notification: {
            title: title,
            body: body,
        },
    };

    try {
        await admin.messaging().send(message);
        return res.status(200).send("Topic notification sent successfully");
    } catch (error) {
        console.error("Error sending topic notification:", error);
        return res.status(500).send("Failed to send topic notification");
    }
});

exports.sendMulticastNotification = functions.https.onRequest(async (req, res) => {
    const { tokens, title, body } = req.body;

    if (!tokens || !tokens.length || !title || !body) {
        return res.status(400).send("Missing required fields");
    }

    const message = {
        tokens: tokens,
        notification: {
            title: title,
            body: body,
        },
    };

    try {
        const response = await admin.messaging().sendMulticast(message);
        return res.status(200).send(`Sent messages successfully: ${response.successCount}/${tokens.length}`);
    } catch (error) {
        console.error("Error sending multicast notification:", error);
        return res.status(500).send("Failed to send multicast notification");
    }
});

exports.sendNotificationOnNewAnnouncement = onDocumentCreated(
    "announcements/{announcementId}",
    async (event) => {
        const snapshot = event.data;
        const announcementData = snapshot.data();
        
        // Query for all user tokens
        const usersSnapshot = await admin.firestore().collection('users').get();
        const tokens = [];
        
        usersSnapshot.forEach(doc => {
            const userData = doc.data();
            if (userData.fcmToken) {
                tokens.push(userData.fcmToken);
            }
        });
        
        const chunkedTokens = chunkArray(tokens, 500);
        
        for (const chunk of chunkedTokens) {
            const message = {
                tokens: chunk,
                notification: {
                    title: announcementData.title,
                    body: announcementData.body,
                },
            };
            
            try {
                await admin.messaging().sendMulticast(message);
                console.log(`Sent batch of ${chunk.length} messages`);
            } catch (error) {
                console.error("Error sending batch:", error);
            }
        }
    }
);

function chunkArray(array, size) {
    const chunked = [];
    for (let i = 0; i < array.length; i += size) {
        chunked.push(array.slice(i, i + size));
    }
    return chunked;
}
