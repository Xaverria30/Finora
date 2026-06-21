const express = require('express');
const { db } = require('../firebase');
const { validateFirebaseToken } = require('../middleware');

const router = express.Router();

function sanitizeSavingGoal(docId, data) {
  const now = new Date().toISOString();
  return {
    id: docId,
    userId: data.userId,
    name: data.name,
    description: data.description || '',
    targetAmount: parseFloat(data.targetAmount) || 0.0,
    currentAmount: parseFloat(data.currentAmount) || 0.0,
    deadline: data.deadline || null,
    createdAt: data.createdAt || now,
    updatedAt: data.updatedAt || data.createdAt || now
  };
}

router.get('/', validateFirebaseToken, async (req, res) => {
  try {
    const snapshot = await db.collection('saving-goals')
      .where('userId', '==', req.user.uid)
      .get();
    const savingGoals = [];
    snapshot.forEach(doc => {
      savingGoals.push(sanitizeSavingGoal(doc.id, doc.data()));
    });
    res.status(200).json({ data: savingGoals });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.get('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const doc = await db.collection('saving-goals').doc(req.params.id).get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Saving goal not found' });
    }
    res.status(200).json(sanitizeSavingGoal(doc.id, doc.data()));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.post('/', validateFirebaseToken, async (req, res) => {
  try {
    const now = new Date().toISOString();
    const targetAmount = parseFloat(req.body.targetAmount) || 0.0;
    const currentAmount = parseFloat(req.body.currentAmount) || 0.0;
    const savingGoalData = {
      ...req.body,
      targetAmount,
      currentAmount,
      userId: req.user.uid,
      createdAt: now,
      updatedAt: now
    };
    const docRef = await db.collection('saving-goals').add(savingGoalData);
    res.status(201).json(sanitizeSavingGoal(docRef.id, savingGoalData));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const docRef = db.collection('saving-goals').doc(req.params.id);
    const doc = await docRef.get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Saving goal not found or unauthorized' });
    }
    
    const now = new Date().toISOString();
    const targetAmount = parseFloat(req.body.targetAmount) || 0.0;
    const currentAmount = parseFloat(req.body.currentAmount) || 0.0;
    const updateData = {
      ...req.body,
      targetAmount,
      currentAmount,
      userId: req.user.uid,
      updatedAt: now
    };
    await docRef.set(updateData, { merge: true });
    
    const updated = await docRef.get();
    res.status(200).json(sanitizeSavingGoal(updated.id, updated.data()));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const docRef = db.collection('saving-goals').doc(req.params.id);
    const doc = await docRef.get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Saving goal not found or unauthorized' });
    }
    await docRef.delete();
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.post('/:id/contribute', validateFirebaseToken, async (req, res) => {
  const { amount } = req.body;
  if (amount === undefined || typeof amount !== 'number' || amount <= 0) {
    return res.status(400).json({ error: 'A positive numeric contribution amount is required' });
  }

  try {
    const docRef = db.collection('saving-goals').doc(req.params.id);
    
    await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(docRef);
      if (!doc.exists || doc.data().userId !== req.user.uid) {
        throw new Error('Saving goal not found or unauthorized');
      }

      const currentAmount = parseFloat(doc.data().currentAmount) || 0;
      const newAmount = currentAmount + amount;

      transaction.update(docRef, {
        currentAmount: newAmount,
        updatedAt: new Date().toISOString()
      });
    });

    const updated = await docRef.get();
    res.status(200).json(sanitizeSavingGoal(updated.id, updated.data()));
  } catch (err) {
    console.error(err);
    const status = err.message.includes('not found') ? 404 : 500;
    res.status(status).json({ error: err.message });
  }
});

module.exports = router;
