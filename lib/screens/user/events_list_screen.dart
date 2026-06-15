import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';
import '../../models/index.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  String? selectedTypeFilter;

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
        title: const Text('Cari Event'),
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

          final allEvents = eventProvider.events;
          final filteredEvents = selectedTypeFilter == null
              ? allEvents
              : allEvents
                  .where((e) => e.tipe == selectedTypeFilter)
                  .toList();

          return Column(
            children: [
              // Filter Chips
              Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Semua'),
                        selected: selectedTypeFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            selectedTypeFilter = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Seminar'),
                        selected: selectedTypeFilter == 'seminar',
                        onSelected: (selected) {
                          setState(() {
                            selectedTypeFilter = selected ? 'seminar' : null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Workshop'),
                        selected: selectedTypeFilter == 'workshop',
                        onSelected: (selected) {
                          setState(() {
                            selectedTypeFilter = selected ? 'workshop' : null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Lomba'),
                        selected: selectedTypeFilter == 'lomba',
                        onSelected: (selected) {
                          setState(() {
                            selectedTypeFilter = selected ? 'lomba' : null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Event List
              Expanded(
                child: filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada event',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            eventProvider.fetchAllEvents(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            final isFull =
                                event.terdaftar >= event.kapasitas;
                            final registrationOpen =
                                !event.pendaftaranDitutup &&
                                    event.batasPendaftaran
                                        .isAfter(DateTime.now());

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/user/event-detail/${event.id}',
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: _getEventColor(
                                                      event.tipe)
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                _getEventIcon(event.tipe),
                                                color: _getEventColor(
                                                    event.tipe),
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.nama,
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Chip(
                                                      label: Text(
                                                        _getEventTypeLabel(
                                                            event.tipe),
                                                      ),
                                                      backgroundColor:
                                                          _getEventColor(
                                                                  event.tipe)
                                                              .withOpacity(
                                                                  0.2),
                                                      labelStyle: TextStyle(
                                                        color:
                                                            _getEventColor(
                                                                event.tipe),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    if (isFull)
                                                      const Chip(
                                                        label: Text('Penuh'),
                                                        backgroundColor:
                                                            Color(0xFFFFEBEE),
                                                        labelStyle: TextStyle(
                                                          color:
                                                              Color(0xFFC62828),
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    else if (!registrationOpen)
                                                      const Chip(
                                                        label: Text('Tertutup'),
                                                        backgroundColor:
                                                            Color(0xFFFFF3E0),
                                                        labelStyle: TextStyle(
                                                          color:
                                                              Color(0xFFE65100),
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              size: 14,
                                              color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              event.lokasi,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              size: 14,
                                              color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${event.tanggalMulai.day}/${event.tanggalMulai.month}/${event.tanggalMulai.year}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: event.terdaftar /
                                              event.kapasitas,
                                          minHeight: 6,
                                          backgroundColor:
                                              Colors.grey[300],
                                          valueColor:
                                              AlwaysStoppedAnimation(
                                            _getEventColor(event.tipe),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Peserta: ${event.terdaftar}/${event.kapasitas}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
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
