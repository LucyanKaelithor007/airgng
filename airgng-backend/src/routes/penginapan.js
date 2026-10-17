const express = require('express');
const db = require('../config/db');
const { opsional } = require('../middleware/auth');
const { asyncHandler, HttpError, ok, KOLOM_PENGINAPAN, JOIN_FAVORIT } = require('../utils/helpers');

const router = express.Router();

// GET /api/penginapan/:id  -> data untuk halaman Detail Kamar
router.get(
  '/:id',
  opsional,
  asyncHandler(async (req, res) => {
    const penggunaId = req.pengguna ? req.pengguna.id : 0;

    const [rows] = await db.query(
      `SELECT ${KOLOM_PENGINAPAN},
              p.tipe, p.deskripsi, p.jumlah_ulasan, p.kapasitas_tamu, p.tuan_rumah
         FROM penginapan p ${JOIN_FAVORIT}
        WHERE p.id = ?`,
      [penggunaId, req.params.id]
    );
    if (rows.length === 0) throw new HttpError(404, 'Penginapan tidak ditemukan.');

    const [galeri] = await db.query(
      'SELECT gambar FROM penginapan_gambar WHERE penginapan_id = ? ORDER BY urutan',
      [req.params.id]
    );
    const [ulasan] = await db.query(
      `SELECT nama_pengulas, rating, komentar, tanggal
         FROM ulasan WHERE penginapan_id = ? ORDER BY tanggal DESC LIMIT 20`,
      [req.params.id]
    );

    ok(res, { ...rows[0], galeri: galeri.map((g) => g.gambar), ulasan });
  })
);

module.exports = router;
