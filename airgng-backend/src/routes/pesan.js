const express = require('express');
const db = require('../config/db');
const { wajib } = require('../middleware/auth');
const { asyncHandler, ok } = require('../utils/helpers');

const router = express.Router();
router.use(wajib);

// GET /api/pesan -> daftar percakapan (kosong bila belum ada)
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const [rows] = await db.query(
      `SELECT id, nama_tuan_rumah, pesan_terakhir, waktu, foto, belum_dibaca
         FROM percakapan WHERE pengguna_id = ? ORDER BY id DESC`,
      [req.pengguna.id]
    );
    ok(res, rows);
  })
);

module.exports = router;
