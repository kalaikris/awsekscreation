const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'password',
  database: 'shop'
});

db.connect();

app.post('/order', (req, res) => {
  const { items, address, payment, total } = req.body;
  const orderId = Date.now();
  db.query('INSERT INTO orders (order_id, items, address, payment, total, status) VALUES (?, ?, ?, ?, ?, ?)',
    [orderId, JSON.stringify(items), address, payment, total, 'pending'], (err) => {
      if (err) return res.status(500).send(err);
      res.json({ orderId });
    });
});

app.get('/tracking/:id', (req, res) => {
  db.query('SELECT * FROM orders WHERE order_id = ?', [req.params.id], (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results[0] || { error: 'not found' });
  });
});

app.post('/ticket', (req, res) => {
  const { orderId, issue } = req.body;
  db.query('INSERT INTO tickets (order_id, issue, status) VALUES (?, ?, ?)',
    [orderId, issue, 'open'], (err) => {
      if (err) return res.status(500).send(err);
      res.send({ success: true });
    });
});

app.listen(5000, () => console.log('Server on 5000'));