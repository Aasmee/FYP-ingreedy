const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { query } = require('../db/db');

const JWT_SECRET = process.env.JWT_SECRET || 'defaultsecret';

// Register a user
exports.register = async (req, res) => {
  const { username, email, password } = req.body;

  try {
    // Check if email or username already exists
    const existingUser = await query(
      'SELECT * FROM users WHERE email = ? OR username = ?',
      [email, username]
    );

    if (existingUser.length > 0) {
      return res.status(409).json({ message: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    await query(
      'INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
      [username, email, hashedPassword]
    );

    return res.status(201).json({ message: 'User registered successfully' });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Login a user
exports.login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const users = await query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    const user = users[0];

    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ uid: user.UID }, JWT_SECRET, { expiresIn: '7d' });

    return res.status(200).json({ token, user: { uid: user.UID, username: user.username, email: user.email } });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
