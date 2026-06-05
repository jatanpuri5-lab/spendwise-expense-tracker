# SpendWise Expense Tracker

## Description

SpendWise is a full-stack expense tracking application built with a Flutter frontend, Node.js and Express.js backend, MySQL database, JWT authentication, and REST API integration.

The application allows users to register and log in, manage income and expense transactions, track budgets, view dashboard summaries and analytics, and store all financial data securely in a MySQL relational database. Flutter communicates with the backend through protected REST API endpoints. The frontend does not connect directly to MySQL.

## Features

- User registration and login
- JWT authentication
- Protected API routes
- Add and view income transactions
- Add and view expense transactions
- Budget tracking
- Dashboard summary
- Analytics screen
- MySQL database integration
- Postman API testing collection
- Clean folder structure with frontend services and backend controllers, routes, and middleware

## Technologies Used

### Frontend

- Flutter
- Dart
- HTTP package
- fl_chart
- Google Fonts

### Backend

- Node.js
- Express.js
- MySQL
- mysql2
- JWT / jsonwebtoken
- bcryptjs
- dotenv
- cors
- nodemon

### Tools

- MySQL Workbench
- Postman
- Git
- GitHub
- VS Code

## Project Structure

```text
expense_tracker/
├── lib/
│   ├── screens/
│   ├── models/
│   ├── services/
│   ├── widgets/
│   ├── themes/
│   └── utils/
│
├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middleware/
│   │   └── routes/
│   ├── database/
│   └── postman/
│
├── assets/
├── test/
├── pubspec.yaml
└── README.md
```

## Setup Instructions

### Frontend Setup

```bash
cd D:\expense_tracker
flutter pub get
flutter run -d chrome
```

### Backend Setup

```bash
cd D:\expense_tracker\backend
npm install
copy .env.example .env
npm run dev
```

After copying `.env.example`, update `.env` with your local MySQL credentials and JWT secret.

## Environment Variables

Create a `.env` file inside the `backend/` folder using this format:

```env
PORT=5000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=expense_tracker_db
JWT_SECRET=replace_with_a_long_random_secret
JWT_EXPIRES_IN=7d
```

> Warning: Do not upload the real `.env` file to GitHub. Keep database passwords and JWT secrets private.

## MySQL Setup

1. Open MySQL Workbench.
2. Create the database:

```sql
CREATE DATABASE expense_tracker_db;
```

3. Run the schema file:

```text
backend/database/schema.sql
```

4. Optional: run the seed file:

```text
backend/database/seed.sql
```

5. Verify the database tables:

```sql
USE expense_tracker_db;
SHOW TABLES;
```

## API Endpoints

### Auth

```text
POST /api/auth/register
POST /api/auth/login
```

### Transactions

```text
GET /api/transactions
POST /api/transactions
PUT /api/transactions/:id
DELETE /api/transactions/:id
```

### Budgets

```text
GET /api/budgets
POST /api/budgets
PUT /api/budgets/:id
DELETE /api/budgets/:id
```

Protected endpoints require this header:

```text
Authorization: Bearer <token>
```

## Postman Testing

A Postman collection is included for API testing:

```text
backend/postman/expense_tracker_collection.json
```

Import this collection into Postman, register or log in to receive a JWT token, and use the token to test protected transaction and budget endpoints.

## Screenshots

Add screenshots here:

- Login Screen
- Dashboard
- Transactions
- Analytics
- MySQL/Postman Testing

## Learning Outcomes

This project demonstrates:

- REST API integration
- JWT authentication and authorization
- Middleware and protected routes
- MySQL relational database design
- Flutter service layer architecture
- Postman API testing
- Full-stack project deployment workflow

## Author

**Name:** Jatan Puri  
**GitHub:** [https://github.com/jatanpuri5-lab](https://github.com/jatanpuri5-lab)
