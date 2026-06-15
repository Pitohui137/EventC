class Event {
  final String id;
  final String nama;
  final String deskripsi;
  final String tipe; // 'seminar', 'workshop', 'lomba'
  final String lokasi;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final DateTime batasPendaftaran;
  final int kapasitas;
  final int terdaftar;
  final bool pendaftaranDitutup;
  final String adminId;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.tipe,
    required this.lokasi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.batasPendaftaran,
    required this.kapasitas,
    required this.terdaftar,
    required this.pendaftaranDitutup,
    required this.adminId,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tipe: json['tipe'] ?? 'seminar',
      lokasi: json['lokasi'] ?? '',
      tanggalMulai: json['tanggal_mulai'] != null
          ? DateTime.parse(json['tanggal_mulai'])
          : DateTime.now(),
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.parse(json['tanggal_selesai'])
          : DateTime.now(),
      batasPendaftaran: json['batas_pendaftaran'] != null
          ? DateTime.parse(json['batas_pendaftaran'])
          : DateTime.now(),
      kapasitas: json['kapasitas'] ?? 0,
      terdaftar: json['terdaftar'] ?? 0,
      pendaftaranDitutup: json['pendaftaran_ditutup'] ?? false,
      adminId: json['admin_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'tipe': tipe,
      'lokasi': lokasi,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_selesai': tanggalSelesai.toIso8601String(),
      'batas_pendaftaran': batasPendaftaran.toIso8601String(),
      'kapasitas': kapasitas,
      'terdaftar': terdaftar,
      'pendaftaran_ditutup': pendaftaranDitutup,
      'admin_id': adminId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
