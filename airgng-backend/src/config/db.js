const mysql = require('mysql2/promise');

// Pool koneksi MySQL (XAMPP). dateStrings: tanggal dikirim sebagai teks "YYYY-MM-DD"
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'airgng',
  waitForConnections: true,
  connectionLimit: 10,
  dateStrings: true,
});

module.exports = pool;
