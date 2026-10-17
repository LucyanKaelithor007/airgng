class UserAuth {
  final int id;
  final String email;
  final String namaDepan;
  final String namaBelakang;
  final String? token;

  UserAuth({
    required this.id,
    required this.email,
    required this.namaDepan,
    required this.namaBelakang,
    this.token,
  });

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      id: toInt(json['id']),
      email: json['email'] ?? '',
      namaDepan: json['nama_depan'] ?? '',
      namaBelakang: json['nama_belakang'] ?? '',
      token: json['token'],
    );
  }

  static int toInt(dynamic val) {
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }
}