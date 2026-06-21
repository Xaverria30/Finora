const express = require('express');
const { db } = require('../firebase');
const { validateFirebaseToken } = require('../middleware');

const router = express.Router();

async function populateBudgetData(userId, budgetId, data) {
  const now = new Date().toISOString();
  const categoryId = data.categoryId;
  const month = data.month || now.substring(0, 7);

  const catDoc = await db.collection('categories').doc(categoryId).get();
  const categoryName = catDoc.exists ? catDoc.data().name : 'Kategori';

  const txSnapshot = await db.collection('transactions')
    .where('userId', '==', userId)
    .where('categoryId', '==', categoryId)
    .where('type', '==', 'expense')
    .get();

  let spent = 0;
  txSnapshot.forEach(tDoc => {
    const tData = tDoc.data();
    if (tData.date && tData.date.startsWith(month)) {
      spent += parseFloat(tData.amount) || 0.0;
    }
  });

  return {
    id: budgetId,
    userId,
    categoryId,
    categoryName,
    limitAmount: parseFloat(data.limitAmount) || 0.0,
    spent,
    month,
    createdAt: data.createdAt || now,
    updatedAt: data.updatedAt || data.createdAt || now
  };
}

router.get('/', validateFirebaseToken, async (req, res) => {
  try {
    let query = db.collection('budgets').where('userId', '==', req.user.uid);
    if (req.query.month) {
      query = query.where('month', '==', req.query.month);
    }
    
    const snapshot = await query.get();
    
    const budgets = [];
    for (const doc of snapshot.docs) {
      const budget = await populateBudgetData(req.user.uid, doc.id, doc.data());
      budgets.push(budget);
    }
    
    res.status(200).json({ data: budgets });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.get('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const doc = await db.collection('budgets').doc(req.params.id).get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Budget not found' });
    }
    const budget = await populateBudgetData(req.user.uid, doc.id, doc.data());
    res.status(200).json(budget);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.post('/', validateFirebaseToken, async (req, res) => {
  try {
    const now = new Date().toISOString();
    const limitAmount = parseFloat(req.body.limitAmount) || 0.0;
    const budgetData = {
      ...req.body,
      limitAmount,
      userId: req.user.uid,
      createdAt: now,
      updatedAt: now
    };
    
    const docRef = await db.collection('budgets').add(budgetData);
    const budget = await populateBudgetData(req.user.uid, docRef.id, budgetData);
    res.status(201).json(budget);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const docRef = db.collection('budgets').doc(req.params.id);
    const doc = await docRef.get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Budget not found or unauthorized' });
    }
    
    const now = new Date().toISOString();
    const limitAmount = parseFloat(req.body.limitAmount) || 0.0;
    const updateData = {
      ...req.body,
      limitAmount,
      userId: req.user.uid,
      updatedAt: now
    };

    await docRef.set(updateData, { merge: true });
    
    const updated = await docRef.get();
    const budget = await populateBudgetData(req.user.uid, updated.id, updated.data());
    res.status(200).json(budget);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const docRef = db.collection('budgets').doc(req.params.id);
    const doc = await docRef.get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Budget not found or unauthorized' });
    }
    await docRef.delete();
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
