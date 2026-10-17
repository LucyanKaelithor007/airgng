const express = require('express');
const db = require('../config/db');
const { wajib } = require('../middleware/auth');
const { asyncHandler, HttpError, ok, KOLOM_PENGINAPAN } = require('../utils/helpers');

const router = express.Router();
router.use(wajib);

// GET /api/favorit -> daftar penginapan favorit pengguna (halaman Favorit)
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const [rows] = await db.query(
      `SELECT ${KOLOM_PENGINAPAN}
         FROM favorit f
         JOIN penginapan p ON p.id = f.penginapan_id
        WHERE f.pengguna_id = ?
        ORDER BY f.created_at DESC`,
      [req.pengguna.id]
    );
    ok(res, rows);
  })
);

// POST /api/favorit  body: { penginapan_id }
router.post(
  '/',
  asyncHandler(async (req, res) => {
    const penginapanId = Number(req.body.penginapan_id);
    if (!penginapanId) throw new HttpError(400, 'penginapan_id wajib diisi.');

    const [cek] = await db.query('SELECT id FROM penginapan WHERE id = ?', [penginapanId]);
    if (cek.length === 0) throw new HttpError(404, 'Penginapan tidak ditemukan.');

    await db.query('INSERT IGNORE INTO favorit (pengguna_id, penginapan_id) VALUES (?, ?)', [
      req.pengguna.id,
      penginapanId,
    ]);
    ok(res, { penginapan_id: penginapanId, is_favorit: true }, 201);
  })
);

// DELETE /api/favorit/:penginapan_id
router.delete(
  '/:penginapanId',
  asyncHandler(async (req, res) => {
    await db.query('DELETE FROM favorit WHERE pengguna_id = ? AND penginapan_id = ?', [
      req.pengguna.id,
      req.params.penginapanId,
    ]);
    ok(res, { penginapan_id: Number(req.params.penginapanId), is_favorit: false });
  })
);

module.exports = router;
