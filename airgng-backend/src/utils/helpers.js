// Express 4 tidak menangkap error dari fungsi async, jadi dibungkus di sini.
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

// Error yang membawa status HTTP, mis. throw new HttpError(404, 'Tidak ditemukan')
class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

// Format response sukses: { data: ... } (sesuai kontrak dengan Flutter)
const ok = (res, data, status = 200) => res.status(status).json({ data });

// Kolom penginapan yang dikirim ke Flutter (sesuai model Penginapan.fromJson)
// Parameter query: id pengguna (0 bila belum login) untuk menghitung is_favorit
const KOLOM_PENGINAPAN = `
  p.id, p.judul, p.lokasi, p.harga_per_malam, p.rating, p.pilihan_tamu, p.gambar,
  (f.penginapan_id IS NOT NULL) AS is_favorit`;

const JOIN_FAVORIT = `
  LEFT JOIN favorit f ON f.penginapan_id = p.id AND f.pengguna_id = ?`;

module.exports = { asyncHandler, HttpError, ok, KOLOM_PENGINAPAN, JOIN_FAVORIT };
