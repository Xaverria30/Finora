const express = require('express');
const { db } = require('../firebase');
const { validateFirebaseToken } = require('../middleware');

const router = express.Router();

function sanitizeUser(uid, data) {
  const now = new Date().toISOString();
  return {
    id: uid,
    name: data.name || data.displayName || data.email?.split('@')[0] || 'User',
    email: data.email || '',
    currency: data.currency || 'IDR',
    photoUrl: data.photoUrl || null,
    createdAt: data.createdAt || now,
    updatedAt: data.updatedAt || now
  };
}

router.get('/me', validateFirebaseToken, async (req, res) => {
  try {
    const userDoc = await db.collection('users').doc(req.user.uid).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User profile not found' });
    }
    res.status(200).json(sanitizeUser(req.user.uid, userDoc.data()));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.put('/me', validateFirebaseToken, async (req, res) => {
  try {
    const userRef = db.collection('users').doc(req.user.uid);
    const updateData = {
      ...req.body,
      uid: req.user.uid,
      updatedAt: new Date().toISOString()
    };
    await userRef.set(updateData, { merge: true });
    
    const updatedDoc = await userRef.get();
    res.status(200).json(sanitizeUser(req.user.uid, updatedDoc.data()));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
