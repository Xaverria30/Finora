const express = require('express');
const authRouter = require('./routes/auth');
const usersRouter = require('./routes/users');
const categoriesRouter = require('./routes/categories');
const transactionsRouter = require('./routes/transactions');
const budgetsRouter = require('./routes/budgets');
const savingGoalsRouter = require('./routes/saving-goals');
const dashboardRouter = require('./routes/dashboard');
const fcmRouter = require('./routes/fcm');

const router = express.Router();

router.use('/auth', authRouter);
router.use('/users', usersRouter);
router.use('/categories', categoriesRouter);
router.use('/transactions', transactionsRouter);
router.use('/budgets', budgetsRouter);
router.use('/saving-goals', savingGoalsRouter);
router.use('/dashboard', dashboardRouter);
router.use('/fcm', fcmRouter);

module.exports = router;
