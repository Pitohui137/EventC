import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';
import '../../models/index.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().getEventById(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Event'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer2<AuthProvider, EventProvider>(
        builder: (context, authProvider, eventProvider, _) {
          if (eventProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final event = eventProvider.selectedEvent;
          if (event == null) {
            return const Center(
              child: Text('Event tidak ditemukan'),
            );
          }

          final isRegistered = event.userIds?.contains(authProvider.currentUser?.id) ?? false;
          final isFull = event.terdaftar >= event.kapasitas;
          final isRegistrationOpen = !event.pendaftaranDitutup && 
              event.batasPendaftaran.isAfter(DateTime.now());
          final canRegister = isRegistrationOpen && !isFull && !isRegistered;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image / Banner
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getEventIcon(event.tipe),
                      size: 64,
                      color: _getEventColor(event.tipe),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Event Title
                Text(
                  event.nama,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                // Event Type Badge
                Chip(
                  label: Text(_getEventTypeLabel(event.tipe)),
                  backgroundColor: _getEventColor(event.tipe).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getEventColor(event.tipe),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Event Details
                _DetailRow(
                  label: 'Lokasi',
                  value: event.lokasi,
                  icon: Icons.location_on,
                ),
                _DetailRow(
                  label: 'Tanggal Mulai',
                  value:
                      '${event.tanggalMulai.day}/${event.tanggalMulai.month}/${event.tanggalMulai.year}',
                  icon: Icons.calendar_today,
                ),
                _DetailRow(
                  label: 'Tanggal Selesai',
                  value:
                      '${event.tanggalSelesai.day}/${event.tanggalSelesai.month}/${event.tanggalSelesai.year}',
                  icon: Icons.calendar_today,
                ),
                _DetailRow(
                  label: 'Batas Pendaftaran',
                  value:
                      '${event.batasPendaftaran.day}/${event.batasPendaftaran.month}/${event.batasPendaftaran.year}',
                  icon: Icons.deadline,
                ),
                _DetailRow(
                  label: 'Peserta',
                  value: '${event.terdaftar} / ${event.kapasitas}',
                  icon: Icons.people,
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  'Deskripsi',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.deskripsi,
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                // Status & Action Messages
                if (isRegistered)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[400]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Anda sudah terdaftar untuk event ini',
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isFull)
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
                            'Event ini sudah penuh',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (!isRegistrationOpen)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[400]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pendaftaran sudah ditutup',
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // Register Button
                if (canRegister)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: eventProvider.isLoading
                          ? null
                          : () => _handleRegister(context, eventProvider, authProvider),
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
                          : const Text('Daftar Event'),
                    ),
                  )
                else if (isRegistered)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: const Text('Sudah Terdaftar'),
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

  void _handleRegister(BuildContext context, EventProvider eventProvider,
      AuthProvider authProvider) async {
    final event = eventProvider.selectedEvent;
    if (event == null) return;

    final success = await eventProvider.registerForEvent(
      eventId: event.id,
      userId: authProvider.currentUser?.id ?? '',
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil terdaftar! Periksa tiket Anda di tab Tiket'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventProvider.errorMessage ?? 'Gagal mendaftar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getEventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'seminar':
        return Icons.school;
      case 'workshop':
        return Icons.build;
      case 'lomba':
        return Icons.emoji_events;
      default:
        return Icons.event;
    }
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'seminar':
        return Colors.blue;
      case 'workshop':
        return Colors.orange;
      case 'lomba':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getEventTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'seminar':
        return 'Seminar';
      case 'workshop':
        return 'Workshop';
      case 'lomba':
        return 'Lomba';
      default:
        return type;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
