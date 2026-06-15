import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';
import '../../models/index.dart';

class UserRegistrationsScreen extends StatefulWidget {
  const UserRegistrationsScreen({Key? key}) : super(key: key);

  @override
  State<UserRegistrationsScreen> createState() =>
      _UserRegistrationsScreenState();
}

class _UserRegistrationsScreenState extends State<UserRegistrationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<EventProvider>().getUserRegistrations(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        if (eventProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final registrations = eventProvider.userRegistrations;

        if (registrations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pendaftaran',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Daftarkan diri Anda untuk event yang tersedia',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () {
            final userId = context.read<AuthProvider>().currentUser?.id;
            return userId != null
                ? context.read<EventProvider>().getUserRegistrations(userId)
                : Future.value();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final registration = registrations[index];
              final statusColor = _getStatusColor(registration.status);
              final statusLabel = _getStatusLabel(registration.status);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                child: InkWell(
                  onTap: () {
                    // Could navigate to registration detail if needed
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pendaftaran',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${registration.id.substring(0, 8)}...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(statusLabel),
                              backgroundColor: statusColor.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Terdaftar: ${registration.tanggalDaftar.day}/${registration.tanggalDaftar.month}/${registration.tanggalDaftar.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Lihat tiket di tab Tiket'),
                                ),
                              );
                            },
                            child: const Text('Lihat Tiket'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return Colors.green;
      case 'batal':
        return Colors.red;
      case 'selesai':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return 'Aktif';
      case 'batal':
        return 'Batal';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }
}
