const express = require('express');
const { db } = require('../firebase');
const { validateFirebaseToken } = require('../middleware');
const { sendPushNotification } = require('../utils/notificationSender');

const router = express.Router();

router.get('/', validateFirebaseToken, async (req, res) => {
  try {
    const snapshot = await db.collection('transactions')
      .where('userId', '==', req.user.uid)
      .get();
    
    // Fetch all categories for this user to map names in memory to avoid N+1 queries
    const catSnapshot = await db.collection('categories')
      .where('userId', '==', req.user.uid)
      .get();
    
    const categoriesMap = {};
    catSnapshot.forEach(doc => {
      categoriesMap[doc.id] = doc.data().name;
    });

    const now = new Date().toISOString();

    let transactions = snapshot.docs.map((doc) => {
      const data = doc.data();
      const categoryName = data.categoryId ? (categoriesMap[data.categoryId] || '') : '';
      return {
        id: doc.id,
        ...data,
        categoryName,
        amount: parseFloat(data.amount) || 0.0,
        createdAt: data.createdAt || now,
        updatedAt: data.updatedAt || data.createdAt || now
      };
    });

    // Sort by createdAt descending (latest first)
    transactions.sort((a, b) => {
      const dateA = a.createdAt || a.date || '';
      const dateB = b.createdAt || b.date || '';
      return dateB.localeCompare(dateA);
    });

    // Handle limit and page query params if present
    if (req.query.limit) {
      const limit = parseInt(req.query.limit, 10);
      if (!isNaN(limit) && limit > 0) {
        const page = parseInt(req.query.page, 10) || 1;
        const startIndex = (page - 1) * limit;
        transactions = transactions.slice(startIndex, startIndex + limit);
      }
    }

    res.status(200).json({ data: transactions });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.get('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const doc = await db.collection('transactions').doc(req.params.id).get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    const data = doc.data();
    const now = new Date().toISOString();
    let categoryName = data.categoryId || '';
    if (data.categoryId) {
      const catDoc = await db.collection('categories').doc(data.categoryId).get();
      if (catDoc.exists) categoryName = catDoc.data().name;
    }
    res.status(200).json({
      id: doc.id,
      ...data,
      categoryName,
      amount: parseFloat(data.amount) || 0.0,
      createdAt: data.createdAt || now,
      updatedAt: data.updatedAt || data.createdAt || now
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.post('/', validateFirebaseToken, async (req, res) => {
  try {
    const now = new Date().toISOString();
    const amount = parseFloat(req.body.amount) || 0.0;
    const transactionData = {
      ...req.body,
      amount,
      userId: req.user.uid,
      createdAt: now,
      updatedAt: now
    };
    
    const docRef = await db.collection('transactions').add(transactionData);
    
    sendPushNotification(
      req.user.uid,
      transactionData.type === 'income' ? 'Pemasukan Baru' : 'Pengeluaran Baru',
      `Transaksi sebesar ${transactionData.amount} berhasil dicatat: ${transactionData.description || ''}`,
      {
        type: 'transaction_update',
        transactionId: docRef.id
      }
    );

    res.status(201).json({ id: docRef.id, ...transactionData });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const docRef = db.collection('transactions').doc(req.params.id);
    const doc = await docRef.get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Transaction not found or unauthorized' });
    }
    
    const now = new Date().toISOString();
    const amount = parseFloat(req.body.amount) || 0.0;
    const updateData = {
      ...req.body,
      amount,
      userId: req.user.uid,
      updatedAt: now
    };

    await docRef.set(updateData, { merge: true });
    
    const updated = await docRef.get();
    const updatedData = updated.data();
    res.status(200).json({
      id: updated.id,
      ...updatedData,
      amount: parseFloat(updatedData.amount) || 0.0,
      createdAt: updatedData.createdAt || now,
      updatedAt: updatedData.updatedAt || now
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', validateFirebaseToken, async (req, res) => {
  try {
    const docRef = db.collection('transactions').doc(req.params.id);
    const doc = await docRef.get();
    if (!doc.exists || doc.data().userId !== req.user.uid) {
      return res.status(404).json({ error: 'Transaction not found or unauthorized' });
    }
    await docRef.delete();
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
