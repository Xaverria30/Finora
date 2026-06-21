const express = require('express');
const { db } = require('../firebase');
const { validateFirebaseToken } = require('../middleware');

const router = express.Router();

router.get('/summary', validateFirebaseToken, async (req, res) => {
  try {
    const snapshot = await db.collection('transactions')
      .where('userId', '==', req.user.uid)
      .get();

    let totalIncome = 0;
    let totalExpenses = 0;

    snapshot.forEach(doc => {
      const data = doc.data();
      const amount = parseFloat(data.amount) || 0;
      if (data.type === 'income') {
        totalIncome += amount;
      } else if (data.type === 'expense') {
        totalExpenses += amount;
      }
    });

    res.status(200).json({
      totalIncome,
      totalExpenses,
      balance: totalIncome - totalExpenses
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/analytics/expenses', validateFirebaseToken, async (req, res) => {
  try {
    const snapshot = await db.collection('transactions')
      .where('userId', '==', req.user.uid)
      .where('type', '==', 'expense')
      .get();

    const categoriesMap = {};

    snapshot.forEach(doc => {
      const data = doc.data();
      const categoryId = data.categoryId || 'uncategorized';
      const amount = parseFloat(data.amount) || 0;
      categoriesMap[categoryId] = (categoriesMap[categoryId] || 0) + amount;
    });

    const categoriesSnapshot = await db.collection('categories').get();
    const categoriesInfo = {};
    categoriesSnapshot.forEach(doc => {
      categoriesInfo[doc.id] = doc.data();
    });

    const analytics = Object.keys(categoriesMap).map(key => ({
      categoryId: key,
      categoryName: categoriesInfo[key]?.name || 'uncategorized',
      categoryColor: categoriesInfo[key]?.color || '#E93188',
      amount: categoriesMap[key]
    }));

    res.status(200).json({
      data: analytics
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
