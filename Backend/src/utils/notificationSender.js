const { admin, db } = require('../firebase');

async function sendPushNotification(userId, title, body, data = {}) {
  try {
    const snapshot = await db.collection('fcm_tokens')
      .where('userId', '==', userId)
      .get();

    const tokenSet = new Set();
    snapshot.forEach(doc => {
      const tokenData = doc.data();
      if (tokenData.fcmToken) {
        tokenSet.add(tokenData.fcmToken);
      }
    });
    // Deduplikasi: pastikan token yang sama tidak dikirim lebih dari sekali
    const tokens = [...tokenSet];

    if (tokens.length === 0) {
      return;
    }

    const stringData = {};
    Object.keys(data).forEach(key => {
      stringData[key] = String(data[key]);
    });

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title,
        body
      },
      data: stringData
    });

    if (response.failureCount > 0) {
      const batch = db.batch();
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const errorCode = resp.error?.code;
          if (errorCode === 'messaging/invalid-registration-token' ||
              errorCode === 'messaging/registration-token-not-registered') {
            const tokenToDelete = tokens[idx];
            const tokenRef = db.collection('fcm_tokens').doc(tokenToDelete);
            batch.delete(tokenRef);
          }
        }
      });
      await batch.commit();
    }

    console.log(`FCM success: ${response.successCount}, failure: ${response.failureCount}`);
  } catch (err) {
    console.error(err);
  }
}

module.exports = {
  sendPushNotification
};