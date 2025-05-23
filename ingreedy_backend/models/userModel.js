const db = require('../db/db');

const getUserByEmail = async (email) => {
  const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
  return rows[0];
};

const createUser = async (username, email, hashedPassword) => {
  const [result] = await db.query(
    'INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
    [username, email, hashedPassword]
  );
  return result.insertId;
};

module.exports = {
  getUserByEmail,
  createUser,
};
