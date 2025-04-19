const express = require('express');
const cors = require('cors');
const db = require('./db/db');

require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;

// Test route
app.get('/', (req, res) => {
  res.send('Ingreedy backend is running');
});

// Load routes
const userRoutes = require('./routes/users');
app.use('/api/users', userRoutes);
const authRoutes = require('./routes/auth');
app.use('/api/auth', authRoutes);

// CORS headers middleware
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  if (req.method === 'OPTIONS') {
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    return res.status(200).json({});
  }
  next();
});

// Database connection and server start
db.testConnection()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('Failed to connect to database:', err);
    process.exit(1);
  });