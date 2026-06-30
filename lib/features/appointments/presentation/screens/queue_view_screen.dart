import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';

class QueueViewScreen extends StatefulWidget {
  const QueueViewScreen({super.key});

  @override
  State<QueueViewScreen> createState() => _QueueViewScreenState();
}

class _QueueViewScreenState extends State<QueueViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch only today's appointments for the queue
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      context.read<AppointmentProvider>().fetchAppointments(date: today);
    });
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await context.read<AppointmentProvider>().updateStatus(id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to \$newStatus')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildQueueColumn(String title, Color color, List<Appointment> items, bool isDark) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Text('\${items.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final apt = items[index];
                final patientName = apt.patient != null ? "\${apt.patient!['firstName']} \${apt.patient!['lastName']}" : "Unknown";
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: color.withValues(alpha: 0.2),
                              child: Text(apt.queueNumber.toString(), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("\${DateFormat('h:mm a').format(apt.startTime)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 12),
                        _buildActionButtons(apt),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(Appointment apt) {
    if (apt.status == 'SCHEDULED') {
      return Row(
        children: [
          Expanded(child: ElevatedButton(onPressed: () => _updateStatus(apt.id, 'CHECKED_IN'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('Check In', style: TextStyle(color: Colors.white)))),
          const SizedBox(width: 8),
          Expanded(child: TextButton(onPressed: () => _updateStatus(apt.id, 'NO_SHOW'), child: const Text('No Show', style: TextStyle(color: Colors.grey)))),
        ],
      );
    } else if (apt.status == 'CHECKED_IN') {
      return Row(
        children: [
          Expanded(child: ElevatedButton(onPressed: () => _updateStatus(apt.id, 'IN_PROGRESS'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange), child: const Text('Start', style: TextStyle(color: Colors.white)))),
        ],
      );
    } else if (apt.status == 'IN_PROGRESS') {
      return Row(
        children: [
          Expanded(child: ElevatedButton(onPressed: () => _updateStatus(apt.id, 'COMPLETED'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Complete', style: TextStyle(color: Colors.white)))),
        ],
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scheduled = provider.appointments.where((a) => a.status == 'SCHEDULED').toList();
    final checkedIn = provider.appointments.where((a) => a.status == 'CHECKED_IN').toList();
    final inProgress = provider.appointments.where((a) => a.status == 'IN_PROGRESS').toList();
    final completed = provider.appointments.where((a) => a.status == 'COMPLETED').toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1A18) : const Color(0xFFF9F6F0),
      appBar: AppBar(
        title: const Text("Today's Queue"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {
            final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
            provider.fetchAppointments(date: today);
          }),
        ],
      ),
      body: provider.isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQueueColumn('Scheduled', Colors.blue, scheduled, isDark),
                _buildQueueColumn('Waiting (Checked In)', Colors.orange, checkedIn, isDark),
                _buildQueueColumn('In Progress', AppTheme.primaryOrange, inProgress, isDark),
                _buildQueueColumn('Completed', Colors.green, completed, isDark),
              ],
            ),
          ),
    );
  }
}
