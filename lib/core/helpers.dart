/// Format angka menjadi Rupiah, contoh: 2371248 -> "Rp 2.371.248"
String formatRupiah(num value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final remaining = s.length - i;
    buf.write(s[i]);
    if (remaining > 1 && remaining % 3 == 1) buf.write('.');
  }
  return 'Rp $buf';
}

/// Format rating: 4.95 -> "4,95", 5.0 -> "5,0"
String formatRating(double rating) => rating.toString().replaceAll('.', ',');

// ---- Helper parsing JSON ----
// MySQL/mysql2 sering mengirim DECIMAL sebagai String ("4.95") dan
// BOOLEAN/TINYINT sebagai 0/1. Helper ini membuat parsing aman.

int toInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

double toDouble(dynamic v, [double fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

bool toBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase();
  return s == 'true' || s == '1';
}
