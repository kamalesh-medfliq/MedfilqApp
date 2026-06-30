import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import 'queue_view_screen.dart';
import '../widgets/book_appointment_modal.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().fetchAppointments();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'SCHEDULED': return Colors.blue;
      case 'CHECKED_IN': return Colors.orange;
      case 'IN_PROGRESS': return AppTheme.primaryOrange;
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      case 'NO_SHOW': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1A18) : const Color(0xFFF9F6F0),
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.queue),
            tooltip: 'Queue View',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const QueueViewScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchAppointments(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : provider.error.isNotEmpty
              ? Center(child: Text('Error: \${provider.error}', style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  color: AppTheme.primaryOrange,
                  onRefresh: () => provider.fetchAppointments(),
                  child: provider.appointments.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text("No appointments found.", style: TextStyle(fontSize: 16))),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.appointments.length,
                          itemBuilder: (context, index) {
                            final apt = provider.appointments[index];
                            final patientName = apt.patient != null 
                              ? "\${apt.patient!['firstName']} \${apt.patient!['lastName']}" 
                              : "Unknown Patient";
                            final doctorName = apt.doctor != null 
                              ? "Dr. \${apt.doctor!['firstName']} \${apt.doctor!['lastName']}" 
                              : "Unknown Doctor";

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isDark ? Colors.white10 : Colors.black12,
                                ),
                              ),
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(apt.status).withValues(alpha: 0.2),
                                  child: Text(
                                    apt.queueNumber.toString().padLeft(3, '0'),
                                    style: TextStyle(
                                      color: _getStatusColor(apt.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  patientName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text("\$doctorName • \${apt.visitType}"),
                                    const SizedBox(height: 2),
                                    Text(
                                      "\${DateFormat('MMM d, y').format(apt.appointmentDate)} | \${DateFormat('h:mm a').format(apt.startTime)} - \${DateFormat('h:mm a').format(apt.endTime)}",
                                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(apt.status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    apt.status.replaceAll('_', ' '),
                                    style: TextStyle(
                                      color: _getStatusColor(apt.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Book Appointment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: isDark ? const Color(0xFF262220) : Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => BookAppointmentModal(
              onBooked: () => provider.fetchAppointments(),
            ),
          );
        },
      ),
    );
  }
}
