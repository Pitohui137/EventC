import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';
import '../../models/index.dart';

class AttendanceCheckInScreen extends StatefulWidget {
  final String eventId;

  const AttendanceCheckInScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<AttendanceCheckInScreen> createState() =>
      _AttendanceCheckInScreenState();
}

class _AttendanceCheckInScreenState extends State<AttendanceCheckInScreen> {
  final ticketNumberController = TextEditingController();
  List<Tiket> checkedInTickets = [];
  int totalParticipants = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventParticipants();
    });
  }

  void _loadEventParticipants() async {
    final eventProvider = context.read<EventProvider>();
    await eventProvider.getEventParticipants(widget.eventId);
    setState(() {
      totalParticipants = eventProvider.eventParticipants.length;
    });
  }

  @override
  void dispose() {
    ticketNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Peserta'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          final attendanceCount = checkedInTickets.length;
          final attendancePercentage = totalParticipants > 0
              ? (attendanceCount / totalParticipants * 100).toStringAsFixed(1)
              : '0.0';

          return Column(
            children: [
              // Statistics Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.withOpacity(0.8),
                      Colors.blue.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Terdaftar',
                          value: totalParticipants.toString(),
                          icon: Icons.people,
                        ),
                        _StatItem(
                          label: 'Hadir',
                          value: attendanceCount.toString(),
                          icon: Icons.check_circle,
                        ),
                        _StatItem(
                          label: 'Persentase',
                          value: '$attendancePercentage%',
                          icon: Icons.pie_chart,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ticket Input Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Tiket',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ticketNumberController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan atau scan nomor tiket',
                              prefixIcon: const Icon(Icons.qr_code_2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSubmitted: (_) => _handleCheckIn(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _handleCheckIn(context),
                            child: const Icon(Icons.check),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Checked In List
              Expanded(
                child: checkedInTickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada peserta yang check-in',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: checkedInTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = checkedInTickets[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
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
                                          ticket.nomorTiket,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Check-in: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green[700],
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleCheckIn(BuildContext context) async {
    final ticketNumber = ticketNumberController.text.trim();

    if (ticketNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nomor tiket'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if already checked in
    final alreadyCheckedIn = checkedInTickets.any(
      (t) => t.nomorTiket == ticketNumber,
    );

    if (alreadyCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiket sudah di-check-in sebelumnya'),
          backgroundColor: Colors.orange,
        ),
      );
      ticketNumberController.clear();
      return;
    }

    // Simulate ticket found and check in successful
    // In real app, this would query the database for the ticket
    final newTicket = Tiket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pendaftaranId: '',
      nomorTiket: ticketNumber,
      qrCode: ticketNumber,
      tanggalBuat: DateTime.now(),
      sudahDigunakan: false,
    );

    setState(() {
      checkedInTickets.add(newTicket);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Check-in berhasil!'),
        backgroundColor: Colors.green,
      ),
    );

    ticketNumberController.clear();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
