# SpendWise Expense Tracker

A Flutter expense tracker with a Node.js/Express REST API backend and MySQL database.

Flutter does not connect directly to MySQL. Run the backend API, then Flutter calls that API over HTTP.

## Prerequisites

- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`
- Node.js `>=18`
- MySQL Server `>=8`
- Postman
- Android Studio or VS Code with Flutter support

## Create The MySQL Database

From a MySQL shell or MySQL Workbench, run:

```sql
SOURCE D:/expense_tracker/backend/database/schema.sql;
SOURCE D:/expense_tracker/backend/database/seed.sql;
```

You can also paste and run the contents of these files manually:

- `backend/database/schema.sql`
- `backend/database/seed.sql`

The database name is `expense_tracker_db`.

Seeded demo account:

```text
email: demo@example.com
password: password123
```

## Run The Backend

```bash
cd D:/expense_tracker/backend
copy .env.example .env
npm install
npm run dev
```

Edit `backend/.env` before starting if your MySQL username, password, host, or port are different.

The API runs at:

```text
http://localhost:5000/api
```

Health check:

```text
GET http://localhost:5000/api/health
```

Backend scripts:

```bash
npm run dev
npm start
```

## Test With Postman

Import this collection:

```text
backend/postman/expense_tracker_collection.json
```

Run requests in this order:

1. `Auth / Register` or `Auth / Login`
2. `Auth / Login` saves the JWT into the Postman collection variable `token`.
3. Run protected transaction and budget requests with `Authorization: Bearer {{token}}`.

## API Endpoints

Auth:

```text
POST /api/auth/register
POST /api/auth/login
```

Login/register response:

```json
{
  "token": "...",
  "user": {
    "id": 1,
    "name": "Demo User",
    "email": "demo@example.com"
  }
}
```

Transactions require `Authorization: Bearer <token>`:

```text
GET /api/transactions
POST /api/transactions
PUT /api/transactions/:id
DELETE /api/transactions/:id
```

Create/update transaction body:

```json
{
  "title": "Coffee",
  "amount": 4.75,
  "type": "expense",
  "category": "food",
  "transactionDate": "2026-06-05",
  "note": "Morning coffee"
}
```

Budgets require `Authorization: Bearer <token>`:

```text
GET /api/budgets
POST /api/budgets
PUT /api/budgets/:id
DELETE /api/budgets/:id
```

Create/update budget body:

```json
{
  "category": "food",
  "limitAmount": 650,
  "month": "2026-06"
}
```

## Run Flutter

```bash
cd D:/expense_tracker
flutter pub get
flutter run -d chrome
```

API base URL defaults:

- Chrome/web: `http://localhost:5000/api`
- Android emulator: `http://10.0.2.2:5000/api`
- Real phone: pass your computer LAN API URL:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5000/api
```

## Flutter API Services

The app includes API service classes:

```text
lib/services/api_service.dart
lib/services/auth_service.dart
lib/services/transaction_service.dart
lib/services/budget_service.dart
```

Existing screens still render with the current UI while data migration happens screen-by-screen. New screens or state management can call these services instead of `DummyData`.

## Project Structure

```text
backend/
  database/
    schema.sql
    seed.sql
  postman/
    expense_tracker_collection.json
  src/
    config/
    controllers/
    middleware/
    routes/

lib/
  dummy_data/
  models/
  screens/
  services/
  themes/
  utils/
  widgets/
```

## Main Flutter Dependencies

```yaml
fl_chart: ^0.68.0
google_fonts: ^6.2.1
animations: ^2.0.11
intl: ^0.19.0
http: ^1.2.2
```
