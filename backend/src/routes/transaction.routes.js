const express = require('express');
const {
  createTransaction,
  deleteTransaction,
  getTransactions,
  updateTransaction,
} = require('../controllers/transaction.controller');
const authenticate = require('../middleware/auth.middleware');

const router = express.Router();

router.use(authenticate);

router.get('/', getTransactions);
router.post('/', createTransaction);
router.put('/:id', updateTransaction);
router.delete('/:id', deleteTransaction);

module.exports = router;
