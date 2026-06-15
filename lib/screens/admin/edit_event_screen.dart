import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late final namaController = TextEditingController();
  late final deskripsiController = TextEditingController();
  late final lokasiController = TextEditingController();
  late final kapasitasController = TextEditingController();

  String selectedTipe = 'seminar';
  DateTime? tanggalMulai;
  DateTime? tanggalSelesai;
  DateTime? batasPendaftaran;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventData();
    });
  }

  void _loadEventData() {
    final eventProvider = context.read<EventProvider>();
    final event = eventProvider.selectedEvent;

    if (event != null) {
      namaController.text = event.nama;
      deskripsiController.text = event.deskripsi;
      lokasiController.text = event.lokasi;
      kapasitasController.text = event.kapasitas.toString();
      selectedTipe = event.tipe;
      tanggalMulai = event.tanggalMulai;
      tanggalSelesai = event.tanggalSelesai;
      batasPendaftaran = event.batasPendaftaran;
      setState(() {});
    } else {
      eventProvider.getEventById(widget.eventId);
    }
  }

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
        title: const Text('Edit Event'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading && tanggalMulai == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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
                // Update Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: eventProvider.isLoading
                        ? null
                        : () => _handleUpdateEvent(context, eventProvider),
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
                        : const Text('Update Event'),
                  ),
                ),
                const SizedBox(height: 16),
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

  void _handleUpdateEvent(
      BuildContext context, EventProvider eventProvider) async {
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

    final success = await eventProvider.updateEvent(
      eventId: widget.eventId,
      nama: namaController.text,
      deskripsi: deskripsiController.text,
      tipe: selectedTipe,
      lokasi: lokasiController.text,
      tanggalMulai: tanggalMulai!,
      tanggalSelesai: tanggalSelesai!,
      batasPendaftaran: batasPendaftaran!,
      kapasitas: int.parse(kapasitasController.text),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
