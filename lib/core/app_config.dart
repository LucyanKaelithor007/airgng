/// Satu-satunya tempat untuk mengatur koneksi ke Backend.
/// Saat backend Node.js sudah siap, cukup ubah [useMock] menjadi false.
class AppConfig {
  /// true  = pakai data dummy lokal (lib/data/mock_data.dart)
  /// false = ambil data dari Backend API Node.js
  static const bool useMock = false;

  /// Alamat backend Node.js.
  /// - Emulator Android : http://10.0.2.2:3000/api
  /// - Emulator iOS     : http://localhost:3000/api
  /// - HP asli          : http://IP_LAPTOP:3000/api (satu WiFi)
  static const String baseUrl = 'http://localhost:3000/api';

  /// Folder gambar yang disajikan backend, misal app.use('/uploads', express.static('uploads'))
  /// Jika database hanya menyimpan nama file (mis. "rumah1.jpg"), gambar
  /// akan diambil dari imageBaseUrl + nama file.
  static const String imageBaseUrl = 'http://localhost:3000/uploads/';

  static const Duration timeout = Duration(seconds: 10);
}
