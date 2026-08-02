const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');
const client = require('prom-client');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Prometheus metrics setup
const register = new client.Registry();
client.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});
register.registerMetric(httpRequestDuration);

const httpRequestTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});
register.registerMetric(httpRequestTotal);

const activeConnections = new client.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});
register.registerMetric(activeConnections);

// Middleware to track request metrics
app.use((req, res, next) => {
  const start = Date.now();
  activeConnections.inc();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;

    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);

    httpRequestTotal
      .labels(req.method, route, res.statusCode)
      .inc();

    activeConnections.dec();
  });

  next();
});

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

// Prometheus metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Frontend metrics endpoint (receives React load times)
const frontendLoadTime = new client.Histogram({
  name: 'react_app_load_time_seconds',
  help: 'React application load time in seconds',
  labelNames: ['metric_type'],
  buckets: [0.5, 1, 2, 3, 5, 10]
});
register.registerMetric(frontendLoadTime);

app.post('/metrics/frontend', (req, res) => {
  const { metric, value, labels } = req.body;

  if (metric === 'react_load_time' && value) {
    frontendLoadTime.labels('total_load').observe(value);
    if (labels?.dom_ready) frontendLoadTime.labels('dom_ready').observe(labels.dom_ready);
    if (labels?.first_paint) frontendLoadTime.labels('first_paint').observe(labels.first_paint);
  }

  res.sendStatus(200);
});

app.listen(5000, () => console.log('Server on 5000'));