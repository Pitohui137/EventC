import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/index.dart';
import '../../models/index.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailScreen({
    Key? key,
    required this.ticketId,
  }) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().getTicketById(widget.ticketId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
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

          final ticket = eventProvider.selectedTicket;
          if (ticket == null) {
            return const Center(
              child: Text('Tiket tidak ditemukan'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticket Banner with Status
                Container(
                  width: double.infinity,
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.confirmation_number,
                            size: 48,
                            color: Colors.white,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: ticket.sudahDigunakan
                                  ? Colors.red
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              ticket.sudahDigunakan
                                  ? 'Sudah Digunakan'
                                  : 'Aktif',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nomor Tiket',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.nomorTiket,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // QR Code Section
                Text(
                  'QR Code',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: QrImage(
                      data: ticket.qrCode,
                      version: QrVersions.auto,
                      size: 250,
                      gapless: true,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Tunjukkan QR Code ini saat check-in',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Ticket Details Section
                Text(
                  'Informasi Tiket',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Dibuat',
                        value:
                            '${ticket.tanggalBuat.day}/${ticket.tanggalBuat.month}/${ticket.tanggalBuat.year}',
                        icon: Icons.calendar_today,
                      ),
                      Divider(color: Colors.grey[300]),
                      _DetailRow(
                        label: 'Status',
                        value: ticket.sudahDigunakan
                            ? 'Sudah Digunakan'
                            : 'Aktif',
                        icon: Icons.info,
                        isStatus: true,
                        statusColor: ticket.sudahDigunakan
                            ? Colors.red
                            : Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: !ticket.sudahDigunakan
                        ? () => _shareTicket(context, ticket)
                        : null,
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan Tiket'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadTicket(context, ticket),
                    icon: const Icon(Icons.download),
                    label: const Text('Download Tiket'),
                  ),
                ),
                const SizedBox(height: 12),
                if (!ticket.sudahDigunakan)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showTicketInfo(context, ticket),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Info Tiket'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _shareTicket(BuildContext context, Tiket ticket) async {
    try {
      await Share.share(
        'Tiket Event Saya\n\n'
        'Nomor Tiket: ${ticket.nomorTiket}\n'
        'Dibuat: ${ticket.tanggalBuat.day}/${ticket.tanggalBuat.month}/${ticket.tanggalBuat.year}\n'
        'Status: ${ticket.sudahDigunakan ? "Sudah Digunakan" : "Aktif"}\n\n'
        'Tunjukkan tiket ini saat check-in event.',
        subject: 'Tiket Event',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membagikan tiket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _downloadTicket(BuildContext context, Tiket ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download tiket berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showTicketInfo(BuildContext context, Tiket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informasi Tiket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoItem('Nomor Tiket', ticket.nomorTiket),
            const SizedBox(height: 12),
            _InfoItem(
              'Dibuat',
              '${ticket.tanggalBuat.day}/${ticket.tanggalBuat.month}/${ticket.tanggalBuat.year}',
            ),
            const SizedBox(height: 12),
            _InfoItem(
              'Status',
              ticket.sudahDigunakan ? 'Sudah Digunakan' : 'Aktif',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isStatus;
  final Color? statusColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isStatus = false,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor?.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
