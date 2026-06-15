import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';
import '../../models/index.dart';

class UserTicketsScreen extends StatefulWidget {
  const UserTicketsScreen({Key? key}) : super(key: key);

  @override
  State<UserTicketsScreen> createState() => _UserTicketsScreenState();
}

class _UserTicketsScreenState extends State<UserTicketsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<EventProvider>().getUserTickets(userId);
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

        final tickets = eventProvider.userTickets;

        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada tiket',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tiket akan muncul setelah Anda mendaftar untuk event',
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
                ? context.read<EventProvider>().getUserTickets(userId)
                : Future.value();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _TicketCard(
                ticket: ticket,
                onViewDetail: () {
                  Navigator.of(context)
                      .pushNamed('/user/ticket-detail/${ticket.id}');
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Tiket ticket;
  final VoidCallback onViewDetail;

  const _TicketCard({
    required this.ticket,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onViewDetail,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiket Event',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket.nomorTiket,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.sudahDigunakan
                          ? Colors.grey[300]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.sudahDigunakan ? 'Digunakan' : 'Aktif',
                      style: TextStyle(
                        color: ticket.sudahDigunakan
                            ? Colors.grey[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Dibuat: ${ticket.tanggalBuat.day}/${ticket.tanggalBuat.month}/${ticket.tanggalBuat.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.qr_code_2,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Taps di sini untuk melihat QR Code',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Lihat Detail'),
                  onPressed: onViewDetail,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
