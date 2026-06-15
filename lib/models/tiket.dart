class Tiket {
  final String id;
  final String pendaftaranId;
  final String nomorTiket;
  final String qrCode;
  final DateTime tanggalBuat;
  final bool sudahDigunakan;

  Tiket({
    required this.id,
    required this.pendaftaranId,
    required this.nomorTiket,
    required this.qrCode,
    required this.tanggalBuat,
    required this.sudahDigunakan,
  });

  factory Tiket.fromJson(Map<String, dynamic> json) {
    return Tiket(
      id: json['id'] ?? '',
      pendaftaranId: json['pendaftaran_id'] ?? '',
      nomorTiket: json['nomor_tiket'] ?? '',
      qrCode: json['qr_code'] ?? '',
      tanggalBuat: json['tanggal_buat'] != null
          ? DateTime.parse(json['tanggal_buat'])
          : DateTime.now(),
      sudahDigunakan: json['sudah_digunakan'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pendaftaran_id': pendaftaranId,
      'nomor_tiket': nomorTiket,
      'qr_code': qrCode,
      'tanggal_buat': tanggalBuat.toIso8601String(),
      'sudah_digunakan': sudahDigunakan,
    };
  }
}
