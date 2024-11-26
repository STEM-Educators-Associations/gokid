const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();

exports.sendNotification = onRequest((request, response) => {
    const token = request.body.token;
    const title = request.body.title;
    const body = request.body.body;

    if (!token) {
        logger.error("Token eksik");
        return response.status(400).send("Token eksik");
    }

    if (!title || !body) {
        logger.error("Başlık veya içerik eksik");
        return response.status(400).send("Başlık veya içerik eksik");
    }

    const message = {
        notification: {
            title: title,
            body: body,
        },
        token: token,
    };

    admin.messaging().send(message)
        .then((res) => {
            logger.info("Bildirim başarıyla gönderildi:", res);
            return response.send("Bildirim başarıyla gönderildi.");
        })
        .catch((error) => {
            logger.error("Bildirim gönderme hatası:", error);
            return response.status(500).send("Bildirim gönderme hatası.");
        });
});
