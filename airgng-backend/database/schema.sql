-- Airgng database (MySQL / XAMPP). Import lewat phpMyAdmin tab "Import".
CREATE DATABASE IF NOT EXISTS airgng CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE airgng;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS percakapan, pemesanan, favorit, ulasan, penginapan_gambar,
  destinasi, layanan, penginapan, pengguna;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE pengguna (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kontak VARCHAR(120) NOT NULL UNIQUE,      -- email atau nomor telepon saat masuk
  email VARCHAR(120) NULL,
  nama_depan VARCHAR(60) NOT NULL,
  nama_belakang VARCHAR(60) NOT NULL DEFAULT '',
  tanggal_lahir DATE NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE penginapan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  judul VARCHAR(150) NOT NULL,
  lokasi VARCHAR(150) NOT NULL,
  kota VARCHAR(80) NOT NULL,                -- dipakai untuk mengelompokkan di Jelajahi
  tipe VARCHAR(60) NOT NULL DEFAULT 'Rumah',
  deskripsi TEXT NULL,
  harga_per_malam INT NOT NULL,
  rating DECIMAL(3,2) NOT NULL DEFAULT 0,
  jumlah_ulasan INT NOT NULL DEFAULT 0,
  pilihan_tamu TINYINT(1) NOT NULL DEFAULT 0,
  kapasitas_tamu INT NOT NULL DEFAULT 4,
  tuan_rumah VARCHAR(80) NOT NULL DEFAULT 'Tuan rumah',
  gambar VARCHAR(255) NOT NULL              -- nama file di folder uploads/
);

CREATE TABLE penginapan_gambar (
  id INT AUTO_INCREMENT PRIMARY KEY,
  penginapan_id INT NOT NULL,
  gambar VARCHAR(255) NOT NULL,
  urutan INT NOT NULL DEFAULT 1,
  FOREIGN KEY (penginapan_id) REFERENCES penginapan(id) ON DELETE CASCADE
);

CREATE TABLE ulasan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  penginapan_id INT NOT NULL,
  nama_pengulas VARCHAR(80) NOT NULL,
  rating TINYINT NOT NULL DEFAULT 5,
  komentar TEXT NOT NULL,
  tanggal DATE NOT NULL,
  FOREIGN KEY (penginapan_id) REFERENCES penginapan(id) ON DELETE CASCADE
);

CREATE TABLE layanan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(80) NOT NULL,
  gambar VARCHAR(255) NOT NULL
);

CREATE TABLE destinasi (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(80) NOT NULL,
  deskripsi VARCHAR(150) NOT NULL,
  gambar VARCHAR(255) NOT NULL
);

CREATE TABLE favorit (
  pengguna_id INT NOT NULL,
  penginapan_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (pengguna_id, penginapan_id),
  FOREIGN KEY (pengguna_id) REFERENCES pengguna(id) ON DELETE CASCADE,
  FOREIGN KEY (penginapan_id) REFERENCES penginapan(id) ON DELETE CASCADE
);

CREATE TABLE pemesanan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kode_pemesanan VARCHAR(30) NOT NULL UNIQUE,
  pengguna_id INT NOT NULL,
  penginapan_id INT NOT NULL,
  tanggal_masuk DATE NOT NULL,
  tanggal_keluar DATE NOT NULL,
  jumlah_malam INT NOT NULL,
  jumlah_tamu INT NOT NULL DEFAULT 1,
  total INT NOT NULL,
  metode_pembayaran VARCHAR(60) NOT NULL,
  waktu_pembayaran VARCHAR(20) NOT NULL DEFAULT 'sekarang',   -- sekarang / nanti
  status VARCHAR(20) NOT NULL DEFAULT 'dikonfirmasi',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pengguna_id) REFERENCES pengguna(id) ON DELETE CASCADE,
  FOREIGN KEY (penginapan_id) REFERENCES penginapan(id) ON DELETE CASCADE
);

CREATE TABLE percakapan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pengguna_id INT NOT NULL,
  nama_tuan_rumah VARCHAR(80) NOT NULL,
  pesan_terakhir VARCHAR(255) NOT NULL,
  waktu VARCHAR(30) NOT NULL,
  foto VARCHAR(255) NOT NULL DEFAULT '',
  belum_dibaca TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (pengguna_id) REFERENCES pengguna(id) ON DELETE CASCADE
);

-- ===================== DATA AWAL =====================
INSERT INTO penginapan
 (id, judul, lokasi, kota, tipe, deskripsi, harga_per_malam, rating, jumlah_ulasan, pilihan_tamu, kapasitas_tamu, tuan_rumah, gambar) VALUES
(1,'Guesthouse di Malang City','Malang City, Malang','Malang','Guesthouse','Guesthouse nyaman di pusat kota, dekat kuliner dan stasiun.',1284341,4.95,120,1,4,'Sutatt','penginapan_1.jpg'),
(2,'Rumah di Lowokwaru','Lowokwaru, Malang','Malang','Rumah','Rumah tenang dekat kampus dengan dapur lengkap dan parkir luas.',1185624,5.00,86,1,6,'Dewi','penginapan_2.jpg'),
(3,'Rumah di Batu','Kota Batu','Batu','Rumah','Rumah dengan teras luas dan pemandangan pegunungan.',1800000,4.96,64,1,8,'Hendra','penginapan_3.jpg'),
(4,'Vila di Batu','Kota Batu','Batu','Vila','Vila dengan kamar berkaca besar menghadap lembah.',720000,4.97,41,1,4,'Rina','penginapan_4.jpg'),
(5,'Rumah di Kecamatan Depok','Depok, Yogyakarta','Yogyakarta','Rumah','Rumah modern dengan kolam kecil, dekat kampus dan pusat kota.',1751374,4.82,134,1,10,'Bagas','penginapan_5.jpg'),
(6,'Rumah di Wirobrajan','Wirobrajan, Yogyakarta','Yogyakarta','Rumah','Rumah bernuansa Jawa dengan taman, dekat Keraton.',922099,4.94,77,1,5,'Sari','penginapan_6.jpg'),
(7,'Rumah di Banjarsari','Banjarsari, Surakarta','Surakarta','Rumah','Rumah luas bergaya klasik dengan ruang tamu lega.',1389600,5.00,58,1,8,'Joko','penginapan_7.jpg'),
(8,'Vila di Banjarsari','Banjarsari, Surakarta','Surakarta','Vila','Vila asri dengan halaman dan area berkumpul keluarga.',1220000,4.97,33,1,6,'Maya','penginapan_8.jpg');

INSERT INTO penginapan_gambar (penginapan_id, gambar, urutan)
  SELECT id, gambar, 1 FROM penginapan;

INSERT INTO ulasan (penginapan_id, nama_pengulas, rating, komentar, tanggal) VALUES
(1,'Youta',5,'Tuan rumahnya sangat ramah! Lokasinya juga bagus, akses ke pusat perbelanjaan yang indah.','2026-09-12'),
(1,'Rani',5,'Kamar bersih dan nyaman, sangat direkomendasikan.','2026-08-02'),
(2,'Budi',5,'Rumahnya luas, cocok untuk keluarga. Pasti kembali lagi.','2026-09-20'),
(3,'Citra',5,'Pemandangannya luar biasa, udaranya sejuk.','2026-07-15'),
(5,'Andi',4,'Kolamnya bagus, lokasi strategis.','2026-09-01');

INSERT INTO layanan (nama, gambar) VALUES
('Chef','layanan_chef.jpg'),('Pijat','layanan_pijat.jpg'),('Perawatan spa','layanan_spa.jpg');

INSERT INTO destinasi (nama, deskripsi, gambar) VALUES
('Bangkok','Hiburan malam semarak','destinasi_bangkok.jpg'),
('Tokyo','Arsitektur memukau','destinasi_tokyo.jpg'),
('Kuala Lumpur','Untuk Menara Petronas','destinasi_kualalumpur.jpg');
