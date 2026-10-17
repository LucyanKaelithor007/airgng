const crypto = require('crypto');
const express = require('express');
const db = require('../config/db');
const { wajib } = require('../middleware/auth');
const { asyncHandler, HttpError, ok } = require('../utils/helpers');

const router = express.Router();
router.use(wajib);

const HARI = 24 * 60 * 60 * 1000;
const hitungMalam = (masuk, keluar) =>
  Math.round((new Date(keluar) - new Date(masuk)) / HARI);

// POST /api/pemesanan
// Body: { penginapan_id, tanggal_masuk, tanggal_keluar, jumlah_tamu,
//         metode_pembayaran, waktu_pembayaran }   (tanggal format YYYY-MM-DD)
// Total dihitung di server dari harga di database, bukan dari kiriman aplikasi.
router.post(
  '/',
  asyncHandler(async (req, res) => {
    const {
      penginapan_id,
      tanggal_masuk,
      tanggal_keluar,
      jumlah_tamu = 1,
      metode_pembayaran,
      waktu_pembayaran = 'sekarang',
    } = req.body;

    if (!penginapan_id || !tanggal_masuk || !tanggal_keluar || !metode_pembayaran) {
      throw new HttpError(400, 'Data pemesanan belum lengkap.');
    }

    const malam = hitungMalam(tanggal_masuk, tanggal_keluar);
    if (!Number.isFinite(malam) || malam < 1) {
      throw new HttpError(422, 'Tanggal keluar harus setelah tanggal masuk.');
    }

    const [rows] = await db.query(
      'SELECT id, harga_per_malam, kapasitas_tamu FROM penginapan WHERE id = ?',
      [penginapan_id]
    );
    if (rows.length === 0) throw new HttpError(404, 'Penginapan tidak ditemukan.');
    const kamar = rows[0];

    if (Number(jumlah_tamu) < 1 || Number(jumlah_tamu) > kamar.kapasitas_tamu) {
      throw new HttpError(422, `Maksimum ${kamar.kapasitas_tamu} tamu bisa menginap di sini.`);
    }

    const total = malam * kamar.harga_per_malam;
    const kode = `AIR-${crypto.randomBytes(3).toString('hex').toUpperCase()}`;

    await db.query(
      `INSERT INTO pemesanan
        (kode_pemesanan, pengguna_id, penginapan_id, tanggal_masuk, tanggal_keluar,
         jumlah_malam, jumlah_tamu, total, metode_pembayaran, waktu_pembayaran)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [kode, req.pengguna.id, kamar.id, tanggal_masuk, tanggal_keluar,
       malam, jumlah_tamu, total, metode_pembayaran, waktu_pembayaran]
    );

    ok(res, { kode_pemesanan: kode, jumlah_malam: malam, total, status: 'dikonfirmasi' }, 201);
  })
);

// GET /api/pemesanan -> riwayat pemesanan pengguna (halaman Perjalanan)
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const [rows] = await db.query(
      `SELECT b.id, b.kode_pemesanan, b.tanggal_masuk, b.tanggal_keluar, b.jumlah_malam,
              b.jumlah_tamu, b.total, b.metode_pembayaran, b.waktu_pembayaran, b.status,
              p.id AS penginapan_id, p.judul, p.lokasi, p.gambar
         FROM pemesanan b
         JOIN penginapan p ON p.id = b.penginapan_id
        WHERE b.pengguna_id = ?
        ORDER BY b.created_at DESC`,
      [req.pengguna.id]
    );
    ok(res, rows);
  })
);

module.exports = router;
