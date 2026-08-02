# Shopping App

React frontend + Node.js backend + MySQL.

## Setup

### Frontend (React)
```bash
cd react
npm install
npm start
```
Runs on http://localhost:3000

### Backend (Node.js)
```bash
cd nodejs
npm install
npm start
```
Runs on http://localhost:5000

### MySQL
Create database and tables:
```sql
CREATE DATABASE shop;
USE shop;

CREATE TABLE orders (
  order_id BIGINT,
  items JSON,
  address TEXT,
  payment TEXT,
  total INT,
  status VARCHAR(20)
);

CREATE TABLE tickets (
  order_id BIGINT,
  issue TEXT,
  status VARCHAR(20)
);
```

Update DB creds in nodejs/server.js if needed:
```js
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'password',
  database: 'shop'
});
```

## Endpoints

### POST /order
Create order.
Body: `{ items, address, payment, total }`
Response: `{ orderId }`

### GET /tracking/:id
Track order by ID.
Response: order object or `{ error: 'not found' }`

### POST /ticket
Submit support ticket.
Body: `{ orderId, issue }`
Response: `{ success: true }`

## Flow
1. Add TV/phone to cart
2. Open cart → Checkout
3. Enter address + payment → Place order
4. Use /tracking with orderId
5. Use /ticket for issues