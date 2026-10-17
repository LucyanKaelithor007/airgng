const express = require('express');
const jwt = require('jsonwebtoken');
const db = require('../config/db');
const { asyncHandler, HttpError, ok } = require('../utils/helpers');

const router = express.Router();

const teks = (v) => (v === undefined || v === null ? '' : String(v).trim());

// POST /api/auth/cek-kontak
// Body: { kontak }  ->  { data: { terdaftar: true/false } }
// Dipakai aplikasi untuk memutuskan: akun sudah ada -> langsung masuk,
// belum ada -> tampilkan form "Buat akun Anda".
router.post(
  '/cek-kontak',
  asyncHandler(async (req, res) => {
    const kontak = teks(req.body.kontak);
    if (!kontak) throw new HttpError(400, 'Nomor telepon atau email wajib diisi.');
    const [rows] = await db.query('SELECT id FROM pengguna WHERE kontak = ?', [kontak]);
    ok(res, { terdaftar: rows.length > 0 });
  })
);

// POST /api/auth/login-atau-daftar
// Body: { kontak, nama_depan, nama_belakang, tanggal_lahir, email }
// - Kontak belum terdaftar -> buat akun baru.
// - Kontak sudah terdaftar -> masuk, dan data yang MASIH KOSONG di akun itu
//   dilengkapi dari isian terbaru (data yang sudah terisi tidak ditimpa).
router.post(
  '/login-atau-daftar',
  asyncHandler(async (req, res) => {
    // Log bantu debugging: tampil di terminal backend setiap ada login/daftar
    console.log('[auth] data diterima:', {
      kontak: req.body.kontak,
      nama_depan: req.body.nama_depan,
      nama_belakang: req.body.nama_belakang,
      tanggal_lahir: req.body.tanggal_lahir,
      email: req.body.email,
    });

    const kontak = teks(req.body.kontak);
    const namaDepan = teks(req.body.nama_depan);
    const namaBelakang = teks(req.body.nama_belakang);
    const tanggalLahir = teks(req.body.tanggal_lahir) || null;
    // Bila email kosong tetapi kontak berupa email, pakai kontak sebagai email
    const email = teks(req.body.email) || (kontak.includes('@') ? kontak : null);

    if (!kontak) throw new HttpError(400, 'Nomor telepon atau email wajib diisi.');
    if (tanggalLahir && !/^\d{4}-\d{2}-\d{2}$/.test(tanggalLahir)) {
      throw new HttpError(422, 'Format tanggal lahir harus YYYY-MM-DD, contoh 2004-05-01.');
    }

    const [rows] = await db.query('SELECT * FROM pengguna WHERE kontak = ?', [kontak]);
    let pengguna = rows[0];
    let baru = false;

    if (!pengguna) {
      if (!namaDepan) throw new HttpError(422, 'Nama depan wajib diisi.');
      const [hasil] = await db.query(
        `INSERT INTO pengguna (kontak, email, nama_depan, nama_belakang, tanggal_lahir)
         VALUES (?, ?, ?, ?, ?)`,
        [kontak, email, namaDepan, namaBelakang, tanggalLahir]
      );
      baru = true;
      const [baris] = await db.query('SELECT * FROM pengguna WHERE id = ?', [hasil.insertId]);
      pengguna = baris[0];
    } else {
      // Lengkapi hanya kolom yang masih kosong
      await db.query(
        `UPDATE pengguna SET
           nama_depan    = IF(nama_depan = '' OR nama_depan IS NULL, ?, nama_depan),
           nama_belakang = IF(nama_belakang = '' OR nama_belakang IS NULL, ?, nama_belakang),
           email         = IF(email IS NULL OR email = '', ?, email),
           tanggal_lahir = COALESCE(tanggal_lahir, ?)
         WHERE id = ?`,
        [namaDepan, namaBelakang, email, tanggalLahir, pengguna.id]
      );
      const [baris] = await db.query('SELECT * FROM pengguna WHERE id = ?', [pengguna.id]);
      pengguna = baris[0];
    }

    const token = jwt.sign({ id: pengguna.id }, process.env.JWT_SECRET, { expiresIn: '7d' });
    ok(res, { token, baru, pengguna }, baru ? 201 : 200);
  })
);

module.exports = router;