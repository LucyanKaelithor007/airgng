**Airgng**
Aplikasi hasil kloning Airbnb, dibuat dengan Flutter, REST API Node.js, dan database MySQL. Merupakan Proyek UTS dari mata kuliah Pemrograman Aplikasi Bergerak, Program Studi Sistem Informasi, Tahun 2026

**Aplikasi yang ditiru**
Aplikasi asli : Airbnb
Nama Plesetan : Airgng

**Anggota Kelompok**
NO |          Nama             |     NIM     |                    Bagian yang Dikerjakan
1.   FAIRUS SYA'BANI           | 24051214151 | Screen (Pemesanan Kamar)
2.   MUHAMMAD DAFFA RIZQI      | 24051214152 | Screen (Favorit & Profil)
3.   DWIKA WIJAYA ARDANA       | 24051214161 | Screen (Jelajahi & Pesan), REST API Node.js dan Database MySQL
4.   MAHARDINI AUDYA SEPTIANI  | 24051214166 | Screen (Onboarding, Login & Daftar)
5.   HERDINA AGNES PITALOKA    | 24051214174 | Screen (Detail Kamar & Perjalanan)

**Panduan Singkat Menjalankan Proyek**
1. Siapkan Database
   1. Buka XAMPP Control Panel, klik Start pada Apache dan MySQL.
   2. Buka http://localhost/phpmyadmin.
   3. Klik New, buat database bernama airgng dengan collation utf8mb4_unicode_ci.
   4. Klik database airgng di sidebar kiri sampai terbuka, lalu buka tab Import.
   5. Pilih airgng-backend/database/schema.sql, lalu klik Go.
  Akan menghasilkan 9 tabel (pengguna, penginapan, penginapan_gambar, ulasan, layanan, destinasi, favorit, pemesanan, percakapan) dan 8 data penginapan contoh.

2. Jalankan Backend
   cd backend
   npm install
   npm run dev
   1. Jika MySQL memakai password, isi DB_PASSWORD di file .env. XAMPP bawaan memakai user root tanpa password.
   2. Terminal harus menampilkan Server berjalan di http://localhost:3000 dan Terhubung ke database MySQL.
   3. Cek di browser: http://localhost:3000/api/jelajahi harus menampilkan JSON.
  
3. Jalankan Frontend
   cd frontend
   flutter pub get
   flutter run -d chrome

4. Coba Aplikasi
   1. Setelah onboarding, popup "Masuk atau daftar" muncul di Jelajahi.
   2. Masukkan email atau nomor telepon, lalu isi form "Buat akun Anda". Format tanggal lahir YYYY-MM-DD, contoh 2004-05-01.
   3. Tekan tombol love di sebuah kamar, lalu buka tab Favorit.
   4. Buka salah satu kamar, tekan Pesan, selesaikan pembayaran simulasi, lalu cek tab Perjalanan.
   5. Untuk keluar, buka tab Profil lalu Keluar.
