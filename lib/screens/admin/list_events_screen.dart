import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';

class ListEventsScreen extends StatefulWidget {
  const ListEventsScreen({Key? key}) : super(key: key);

  @override
  State<ListEventsScreen> createState() => _ListEventsScreenState();
}

class _ListEventsScreenState extends State<ListEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Event'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (eventProvider.events.isEmpty) {
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
                    'Belum ada event',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat event baru untuk memulai',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => eventProvider.fetchAllEvents(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: eventProvider.events.length,
              itemBuilder: (context, index) {
                final event = eventProvider.events[index];
                final isRegistrationOpen = eventProvider.isRegistrationOpen(event);
                final availableSlots = eventProvider.getAvailableSlots(event.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      event.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                event.tipe.toUpperCase(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _getTypeColor(event.tipe),
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                '${event.terdaftar}/${event.kapasitas}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: isRegistrationOpen
                                  ? Colors.green[100]
                                  : Colors.red[100],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.lokasi,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event.tanggalMulai.day}/${event.tanggalMulai.month}/${event.tanggalMulai.year}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (isRegistrationOpen)
                              Chip(
                                label: const Text('Terbuka'),
                                backgroundColor: Colors.green[100],
                                labelStyle: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              Chip(
                                label: const Text('Ditutup'),
                                backgroundColor: Colors.red[100],
                                labelStyle: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/admin/edit-event/${event.id}',
                            );
                          },
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.people, size: 20),
                              SizedBox(width: 8),
                              Text('Lihat Peserta'),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/admin/participants/${event.id}',
                            );
                          },
                        ),
                        if (isRegistrationOpen)
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.lock, size: 20),
                                SizedBox(width: 8),
                                Text('Tutup Pendaftaran'),
                              ],
                            ),
                            onTap: () {
                              _showCloseRegistrationDialog(
                                context,
                                event.id,
                                event.nama,
                                eventProvider,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/admin/create-event');
        },
        tooltip: 'Buat Event',
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getTypeColor(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'seminar':
        return Colors.blue;
      case 'workshop':
        return Colors.orange;
      case 'lomba':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showCloseRegistrationDialog(
    BuildContext context,
    String eventId,
    String eventName,
    EventProvider eventProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutup Pendaftaran'),
        content: Text(
          'Apakah Anda yakin ingin menutup pendaftaran untuk "$eventName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              final success =
                  await eventProvider.closeEventRegistration(eventId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Pendaftaran berhasil ditutup'
                          : 'Gagal menutup pendaftaran',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Tutup Pendaftaran'),
          ),
        ],
      ),
    );
  }
}
