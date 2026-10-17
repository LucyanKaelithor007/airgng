const express = require('express');
const db = require('../config/db');
const { opsional } = require('../middleware/auth');
const { asyncHandler, ok, KOLOM_PENGINAPAN, JOIN_FAVORIT } = require('../utils/helpers');

const router = express.Router();

// GET /api/jelajahi  (login opsional; bila login, is_favorit terisi)
router.get(
  '/',
  opsional,
  asyncHandler(async (req, res) => {
    const penggunaId = req.pengguna ? req.pengguna.id : 0;

    const [rows] = await db.query(
      `SELECT ${KOLOM_PENGINAPAN}, p.kota
         FROM penginapan p ${JOIN_FAVORIT}
        ORDER BY (SELECT MIN(x.id) FROM penginapan x WHERE x.kota = p.kota), p.id`,
      [penggunaId]
    );

    // Kelompokkan per kota -> satu baris horizontal per kota
    const peta = new Map();
    for (const { kota, ...item } of rows) {
      if (!peta.has(kota)) peta.set(kota, []);
      peta.get(kota).push(item);
    }
    const seksi = [...peta.entries()].map(([kota, items]) => ({
      judul: `Penginapan di ${kota}`,
      items,
    }));

    const [layanan] = await db.query('SELECT nama, gambar FROM layanan ORDER BY id');
    const [destinasi] = await db.query('SELECT nama, deskripsi, gambar FROM destinasi ORDER BY id');

    ok(res, { seksi, layanan, destinasi });
  })
);

module.exports = router;
