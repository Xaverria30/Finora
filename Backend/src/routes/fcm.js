const express = require('express');
const { db } = require('../firebase');

const router = express.Router();

router.post('/register', async (req, res) => {
  const { userId, fcmToken, deviceName, deviceInfo } = req.body;
  if (!userId || !fcmToken) {
    return res.status(400).json({ error: 'userId and fcmToken are required' });
  }

  try {
    const tokenRef = db.collection('fcm_tokens').doc(fcmToken);
    await tokenRef.set({
      userId,
      fcmToken,
      deviceName: deviceName || 'unknown',
      deviceInfo: deviceInfo || 'unknown',
      updatedAt: new Date().toISOString()
    });
    res.status(200).json({ message: 'FCM token registered successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
