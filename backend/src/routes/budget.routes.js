const express = require('express');
const {
  createBudget,
  deleteBudget,
  getBudgets,
  updateBudget,
} = require('../controllers/budget.controller');
const authenticate = require('../middleware/auth.middleware');

const router = express.Router();

router.use(authenticate);

router.get('/', getBudgets);
router.post('/', createBudget);
router.put('/:id', updateBudget);
router.delete('/:id', deleteBudget);

module.exports = router;
