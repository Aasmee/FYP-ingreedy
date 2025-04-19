const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
dotenv.config();

const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(" ")[1]; // Expect "Bearer <token>"

  if (!token) return res.status(403).json({ message: 'Token required' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // attaches decoded UID/email to request
    next();
  } catch (err) {
    res.status(401).json({ message: 'Invalid or expired token' });
  }
};

module.exports = verifyToken;
