USE expense_tracker_db;

-- Password is: password123
INSERT INTO users (name, email, password_hash)
VALUES (
  'Demo User',
  'demo@example.com',
  '$2a$12$LCdP8qJzTqQ.CaLm4nELpOdA96S4zZrY6q44Q1k4FDuF1lFNfTi6K'
)
ON DUPLICATE KEY UPDATE email = email;

SET @demo_user_id = (SELECT id FROM users WHERE email = 'demo@example.com');

INSERT INTO transactions (user_id, title, amount, type, category, transaction_date, note)
VALUES
  (@demo_user_id, 'Salary', 5000.00, 'income', 'salary', '2026-06-01', 'Monthly salary'),
  (@demo_user_id, 'Groceries', 86.45, 'expense', 'food', '2026-06-02', 'Weekly shop'),
  (@demo_user_id, 'Electric Bill', 120.00, 'expense', 'bills', '2026-06-03', NULL),
  (@demo_user_id, 'Movie Night', 42.00, 'expense', 'entertainment', '2026-06-04', NULL);

INSERT INTO budgets (user_id, category, limit_amount, month)
VALUES
  (@demo_user_id, 'food', 600.00, '2026-06'),
  (@demo_user_id, 'bills', 400.00, '2026-06'),
  (@demo_user_id, 'entertainment', 250.00, '2026-06');
