const pool = require('../config/db');

function mapBudget(row) {
  return {
    id: row.id,
    userId: row.user_id,
    category: row.category,
    limitAmount: row.limit_amount,
    month: row.month,
    spent: row.spent || 0,
    createdAt: row.created_at,
  };
}

function validateBudget(body) {
  const category = typeof body.category === 'string' ? body.category.trim() : '';
  const limitAmount = Number(body.limitAmount);
  const month = typeof body.month === 'string' ? body.month.trim() : '';

  if (!category || body.limitAmount == null || !month) {
    return { error: 'Category, limitAmount, and month are required' };
  }

  if (!Number.isFinite(limitAmount) || limitAmount <= 0) {
    return { error: 'limitAmount must be a positive number' };
  }

  if (!/^\d{4}-\d{2}$/.test(month)) {
    return { error: 'month must be in YYYY-MM format' };
  }

  return { value: { category, limitAmount, month } };
}

async function getBudgets(req, res, next) {
  try {
    const [rows] = await pool.query(
      `SELECT
         b.id,
         b.user_id,
         b.category,
         b.limit_amount,
         b.month,
         b.created_at,
         COALESCE(SUM(t.amount), 0) AS spent
       FROM budgets b
       LEFT JOIN transactions t
         ON t.user_id = b.user_id
        AND LOWER(t.category) = LOWER(b.category)
        AND t.type = 'expense'
        AND DATE_FORMAT(t.transaction_date, '%Y-%m') = b.month
       WHERE b.user_id = ?
       GROUP BY b.id
       ORDER BY b.month DESC, b.category ASC`,
      [req.user.id]
    );

    res.json(rows.map(mapBudget));
  } catch (err) {
    next(err);
  }
}

async function createBudget(req, res, next) {
  try {
    const validation = validateBudget(req.body);

    if (validation.error) {
      return res.status(400).json({ message: validation.error });
    }

    const { category, limitAmount, month } = validation.value;

    const [result] = await pool.query(
      'INSERT INTO budgets (user_id, category, limit_amount, month) VALUES (?, ?, ?, ?)',
      [req.user.id, category, limitAmount, month]
    );

    const [rows] = await pool.query(
      `SELECT id, user_id, category, limit_amount, month, created_at, 0 AS spent
       FROM budgets
       WHERE id = ? AND user_id = ?`,
      [result.insertId, req.user.id]
    );

    res.status(201).json(mapBudget(rows[0]));
  } catch (err) {
    next(err);
  }
}

async function updateBudget(req, res, next) {
  try {
    const validation = validateBudget(req.body);

    if (validation.error) {
      return res.status(400).json({ message: validation.error });
    }

    const { category, limitAmount, month } = validation.value;

    const [result] = await pool.query(
      `UPDATE budgets
       SET category = ?, limit_amount = ?, month = ?
       WHERE id = ? AND user_id = ?`,
      [category, limitAmount, month, req.params.id, req.user.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Budget not found' });
    }

    const [rows] = await pool.query(
      `SELECT id, user_id, category, limit_amount, month, created_at, 0 AS spent
       FROM budgets
       WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );

    res.json(mapBudget(rows[0]));
  } catch (err) {
    next(err);
  }
}

async function deleteBudget(req, res, next) {
  try {
    const [result] = await pool.query('DELETE FROM budgets WHERE id = ? AND user_id = ?', [
      req.params.id,
      req.user.id,
    ]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Budget not found' });
    }

    res.status(204).send();
  } catch (err) {
    next(err);
  }
}

module.exports = {
  createBudget,
  deleteBudget,
  getBudgets,
  updateBudget,
};
