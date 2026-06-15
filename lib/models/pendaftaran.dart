class Pendaftaran {
  final String id;
  final String userId;
  final String eventId;
  final DateTime tanggalDaftar;
  final String status; // 'aktif', 'batal', 'selesai'

  Pendaftaran({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.tanggalDaftar,
    required this.status,
  });

  factory Pendaftaran.fromJson(Map<String, dynamic> json) {
    return Pendaftaran(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      eventId: json['event_id'] ?? '',
      tanggalDaftar: json['tanggal_daftar'] != null
          ? DateTime.parse(json['tanggal_daftar'])
          : DateTime.now(),
      status: json['status'] ?? 'aktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'tanggal_daftar': tanggalDaftar.toIso8601String(),
      'status': status,
    };
  }
}
