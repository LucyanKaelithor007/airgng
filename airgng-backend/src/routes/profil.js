const express = require('express');
const db = require('../config/db');
const { wajib } = require('../middleware/auth');
const { asyncHandler, HttpError, ok } = require('../utils/helpers');

const router = express.Router();
router.use(wajib);

// GET /api/profil
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const [rows] = await db.query(
      `SELECT id, kontak, email, nama_depan, nama_belakang, tanggal_lahir, created_at
         FROM pengguna WHERE id = ?`,
      [req.pengguna.id]
    );
    if (rows.length === 0) throw new HttpError(404, 'Pengguna tidak ditemukan.');
    ok(res, rows[0]);
  })
);

// PUT /api/profil  body: { nama_depan, nama_belakang, email, tanggal_lahir }
router.put(
  '/',
  asyncHandler(async (req, res) => {
    const { nama_depan, nama_belakang, email, tanggal_lahir } = req.body;
    if (!nama_depan || !String(nama_depan).trim()) {
      throw new HttpError(422, 'Nama depan wajib diisi.');
    }
    await db.query(
      `UPDATE pengguna SET nama_depan = ?, nama_belakang = ?, email = ?, tanggal_lahir = ?
        WHERE id = ?`,
      [nama_depan.trim(), (nama_belakang || '').trim(), email || null, tanggal_lahir || null, req.pengguna.id]
    );
    const [rows] = await db.query(
      `SELECT id, kontak, email, nama_depan, nama_belakang, tanggal_lahir
         FROM pengguna WHERE id = ?`,
      [req.pengguna.id]
    );
    ok(res, rows[0]);
  })
);

module.exports = router;
