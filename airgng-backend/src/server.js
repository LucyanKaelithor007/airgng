require('dotenv').config(); // harus paling atas, sebelum modul lain membaca process.env

const path = require('path');
const express = require('express');
const cors = require('cors');
const db = require('./config/db');

const app = express();

app.use(cors()); // wajib agar Flutter Web (Chrome) boleh memanggil API
app.use(express.json());

// Gambar: http://localhost:3000/uploads/penginapan_1.jpg
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

app.get('/', (req, res) => res.json({ message: 'API Airgng berjalan' }));

app.use('/api/auth', require('./routes/auth'));
app.use('/api/jelajahi', require('./routes/jelajahi'));
app.use('/api/penginapan', require('./routes/penginapan'));
app.use('/api/favorit', require('./routes/favorit'));
app.use('/api/pemesanan', require('./routes/pemesanan'));
app.use('/api/pesan', require('./routes/pesan'));
app.use('/api/profil', require('./routes/profil'));

// 404
app.use((req, res) => res.status(404).json({ message: 'Endpoint tidak ditemukan.' }));

// Penangan error terpusat -> { message } sesuai yang dibaca ApiClient di Flutter
app.use((err, req, res, next) => {
  const status = err.status || 500;
  if (status === 500) console.error(err);
  res.status(status).json({ message: status === 500 ? 'Terjadi kesalahan pada server.' : err.message });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', async () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
  try {
    await db.query('SELECT 1');
    console.log('Terhubung ke database MySQL.');
  } catch (e) {
    console.error('GAGAL terhubung ke MySQL:', e.message);
    console.error('Pastikan MySQL di XAMPP sudah Start dan schema.sql sudah di-import.');
  }
});
