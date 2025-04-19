const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'aasmee',
  password: process.env.DB_PASSWORD || '123',
  database: process.env.DB_NAME || 'fyp',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test database connection
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('Database connection established successfully');
    connection.release();
    return true;
  } catch (error) {
    console.error('Database connection failed:', error);
    throw error;
  }
}

// Add the query function to fix the error
async function query(sql, params) {
  try {
    const [results] = await pool.execute(sql, params);
    return results;
  } catch (error) {
    console.error('Query error:', error);
    throw error;
  }
}

// Updated db.js initDb function
async function initDb() {
  try {
    // Creating the 'users' table (updated to include profile_pic)
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS users (
        UID INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(255) NOT NULL UNIQUE,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        profile_pic VARCHAR(255) DEFAULT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Creating the 'followers' table for follow relationships
    await pool.execute(`
      CREATE TABLE IF NOT EXISTS followers (
        id INT AUTO_INCREMENT PRIMARY KEY,
        follower_user_id INT NOT NULL,
        followed_user_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (follower_user_id) REFERENCES users(UID),
        FOREIGN KEY (followed_user_id) REFERENCES users(UID),
        UNIQUE KEY unique_follow (follower_user_id, followed_user_id)
      )
    `);

    // Update 'saved_recipes' table to distinguish between user's own recipes and saved ones
    // await pool.execute(`
    //   ALTER TABLE saved_recipes ADD COLUMN IF NOT EXISTS is_own_recipe BOOLEAN DEFAULT 0
    // `);

    // Rest of the existing tables...
    // ... (ingredients, pantry, etc.)

    console.log('Database tables initialized');
  } catch (error) {
    console.error('Failed to initialize database tables:', error);
    throw error;
  }
}

// Call initDb when this module is imported
initDb().catch(console.error);

module.exports = {
  pool,
  testConnection,
  query  // Export the query function
};