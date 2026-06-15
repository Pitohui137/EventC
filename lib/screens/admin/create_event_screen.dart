import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final lokasiController = TextEditingController();
  final kapasitasController = TextEditingController();

  String selectedTipe = 'seminar';
  DateTime? tanggalMulai;
  DateTime? tanggalSelesai;
  DateTime? batasPendaftaran;

  @override
  void dispose() {
    namaController.dispose();
    deskripsiController.dispose();
    lokasiController.dispose();
    kapasitasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Event'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer2<AuthProvider, EventProvider>(
        builder: (context, authProvider, eventProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error Message
                if (eventProvider.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[400]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            eventProvider.errorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            eventProvider.clearError();
                          },
                          child: Icon(Icons.close, color: Colors.red[700]),
                        ),
                      ],
                    ),
                  ),
                if (eventProvider.errorMessage != null)
                  const SizedBox(height: 16),
                // Nama Event
                TextField(
                  controller: namaController,
                  enabled: !eventProvider.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Nama Event',
                    hintText: 'Contoh: Seminar Flutter 2026',
                    prefixIcon: const Icon(Icons.event),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tipe Event
                DropdownButtonFormField<String>(
                  value: selectedTipe,
                  enabled: !eventProvider.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Tipe Event',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'seminar', child: Text('Seminar')),
                    DropdownMenuItem(value: 'workshop', child: Text('Workshop')),
                    DropdownMenuItem(value: 'lomba', child: Text('Lomba')),
                  ],
                  onChanged: !eventProvider.isLoading
                      ? (value) {
                          setState(() {
                            selectedTipe = value ?? 'seminar';
                          });
                        }
                      : null,
                ),
                const SizedBox(height: 16),
                // Deskripsi
                TextField(
                  controller: deskripsiController,
                  enabled: !eventProvider.isLoading,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Jelaskan detail tentang event ini',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Lokasi
                TextField(
                  controller: lokasiController,
                  enabled: !eventProvider.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Lokasi',
                    hintText: 'Contoh: Ruang Aula Gedung A',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Kapasitas
                TextField(
                  controller: kapasitasController,
                  enabled: !eventProvider.isLoading,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Kapasitas',
                    hintText: 'Jumlah peserta maksimal',
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tanggal Mulai
                Text(
                  'Tanggal Mulai: ${tanggalMulai?.toString().split(' ')[0] ?? 'Pilih tanggal'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !eventProvider.isLoading
                        ? () => _selectDate(context, 'mulai')
                        : null,
                    child: const Text('Pilih Tanggal Mulai'),
                  ),
                ),
                const SizedBox(height: 16),
                // Tanggal Selesai
                Text(
                  'Tanggal Selesai: ${tanggalSelesai?.toString().split(' ')[0] ?? 'Pilih tanggal'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !eventProvider.isLoading
                        ? () => _selectDate(context, 'selesai')
                        : null,
                    child: const Text('Pilih Tanggal Selesai'),
                  ),
                ),
                const SizedBox(height: 16),
                // Batas Pendaftaran
                Text(
                  'Batas Pendaftaran: ${batasPendaftaran?.toString().split(' ')[0] ?? 'Pilih tanggal'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !eventProvider.isLoading
                        ? () => _selectDate(context, 'batas')
                        : null,
                    child: const Text('Pilih Batas Pendaftaran'),
                  ),
                ),
                const SizedBox(height: 24),
                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: eventProvider.isLoading
                        ? null
                        : () =>
                            _handleCreateEvent(context, authProvider, eventProvider),
                    child: eventProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Buat Event'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _selectDate(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (type == 'mulai') {
          tanggalMulai = picked;
        } else if (type == 'selesai') {
          tanggalSelesai = picked;
        } else if (type == 'batas') {
          batasPendaftaran = picked;
        }
      });
    }
  }

  void _handleCreateEvent(BuildContext context, AuthProvider authProvider,
      EventProvider eventProvider) async {
    if (namaController.text.isEmpty ||
        deskripsiController.text.isEmpty ||
        lokasiController.text.isEmpty ||
        kapasitasController.text.isEmpty ||
        tanggalMulai == null ||
        tanggalSelesai == null ||
        batasPendaftaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await eventProvider.createEvent(
      nama: namaController.text,
      deskripsi: deskripsiController.text,
      tipe: selectedTipe,
      lokasi: lokasiController.text,
      tanggalMulai: tanggalMulai!,
      tanggalSelesai: tanggalSelesai!,
      batasPendaftaran: batasPendaftaran!,
      kapasitas: int.parse(kapasitasController.text),
      adminId: authProvider.currentUser?.id ?? '',
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
