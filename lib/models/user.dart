class User {
  final String id;
  final String email;
  final String nama;
  final String role; // 'admin' or 'user'
  final String? nomorHP;
  final String? asal;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.nama,
    required this.role,
    this.nomorHP,
    this.asal,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nama: json['nama'] ?? '',
      role: json['role'] ?? 'user',
      nomorHP: json['nomor_hp'],
      asal: json['asal'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'role': role,
      'nomor_hp': nomorHP,
      'asal': asal,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
