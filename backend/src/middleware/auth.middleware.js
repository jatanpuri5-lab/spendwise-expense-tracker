const jwt = require('jsonwebtoken');
const pool = require('../config/db');

async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    const [scheme, token] = authHeader.split(' ');

    if (scheme !== 'Bearer' || !token) {
      return res.status(401).json({ message: 'Authorization token is required' });
    }

    const payload = jwt.verify(token, process.env.JWT_SECRET);
    const [users] = await pool.query('SELECT id, name, email FROM users WHERE id = ?', [
      payload.userId,
    ]);

    if (users.length === 0) {
      return res.status(401).json({ message: 'Invalid token user' });
    }

    req.user = users[0];
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}

module.exports = authenticate;
