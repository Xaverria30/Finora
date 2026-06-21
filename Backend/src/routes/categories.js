const express = require('express');
const { db } = require('../firebase');
const { validateFirebaseToken } = require('../middleware');

const router = express.Router();

router.get('/', validateFirebaseToken, async (req, res) => {
  try {
    const snapshot = await db.collection('categories')
      .where('userId', '==', req.user.uid)
      .get();
    const categories = [];
    const now = new Date().toISOString();
    snapshot.forEach(doc => {
      const data = doc.data();
      categories.push({
        id: doc.id,
        ...data,
        createdAt: data.createdAt || now
      });
    });
    res.status(200).json({ data: categories });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.post('/', validateFirebaseToken, async (req, res) => {
  try {
    const now = new Date().toISOString();
    const categoryData = {
      ...req.body,
      userId: req.user.uid,
      createdAt: now
    };
    const docRef = await db.collection('categories').add(categoryData);
    res.status(201).json({ id: docRef.id, ...categoryData });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const docRef = db.collection('categories').doc(req.params.id);
    const doc = await docRef.get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Category not found or unauthorized' });
    }
    const updateData = {
      ...req.body,
      userId: req.user.uid
    };
    await docRef.set(updateData, { merge: true });
    
    const updated = await docRef.get();
    res.status(200).json({ id: updated.id, ...updated.data() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const docRef = db.collection('categories').doc(req.params.id);
    const doc = await docRef.get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Category not found or unauthorized' });
    }
    await docRef.delete();
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
