const pool = require('../config/db');

function mapTransaction(row) {
  return {
    id: row.id,
    userId: row.user_id,
    title: row.title,
    amount: row.amount,
    type: row.type,
    category: row.category,
    transactionDate: row.transaction_date,
    note: row.note,
    createdAt: row.created_at,
  };
}

async function getTransactions(req, res, next) {
  try {
    const [rows] = await pool.query(
      `SELECT id, user_id, title, amount, type, category, transaction_date, note, created_at
       FROM transactions
       WHERE user_id = ?
       ORDER BY transaction_date DESC, id DESC`,
      [req.user.id]
    );

    res.json(rows.map(mapTransaction));
  } catch (err) {
    next(err);
  }
}

async function createTransaction(req, res, next) {
  try {
    const { title, amount, type, category, transactionDate, note } = req.body;

    if (!title || amount == null || !type || !category || !transactionDate) {
      return res.status(400).json({
        message: 'Title, amount, type, category, and transactionDate are required',
      });
    }

    const [result] = await pool.query(
      `INSERT INTO transactions
       (user_id, title, amount, type, category, transaction_date, note)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [req.user.id, title, amount, type, category, transactionDate, note || null]
    );

    const [rows] = await pool.query('SELECT * FROM transactions WHERE id = ? AND user_id = ?', [
      result.insertId,
      req.user.id,
    ]);

    res.status(201).json(mapTransaction(rows[0]));
  } catch (err) {
    next(err);
  }
}

async function updateTransaction(req, res, next) {
  try {
    const { title, amount, type, category, transactionDate, note } = req.body;

    const [result] = await pool.query(
      `UPDATE transactions
       SET title = ?, amount = ?, type = ?, category = ?, transaction_date = ?, note = ?
       WHERE id = ? AND user_id = ?`,
      [title, amount, type, category, transactionDate, note || null, req.params.id, req.user.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Transaction not found' });
    }

    const [rows] = await pool.query('SELECT * FROM transactions WHERE id = ? AND user_id = ?', [
      req.params.id,
      req.user.id,
    ]);

    res.json(mapTransaction(rows[0]));
  } catch (err) {
    next(err);
  }
}

async function deleteTransaction(req, res, next) {
  try {
    const [result] = await pool.query('DELETE FROM transactions WHERE id = ? AND user_id = ?', [
      req.params.id,
      req.user.id,
    ]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Transaction not found' });
    }

    res.status(204).send();
  } catch (err) {
    next(err);
  }
}

module.exports = {
  createTransaction,
  deleteTransaction,
  getTransactions,
  updateTransaction,
};
