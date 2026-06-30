import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

class BookAppointmentModal extends StatefulWidget {
  final VoidCallback onBooked;

  const BookAppointmentModal({super.key, required this.onBooked});

  @override
  State<BookAppointmentModal> createState() => _BookAppointmentModalState();
}

class _BookAppointmentModalState extends State<BookAppointmentModal> {
  bool _isLoading = false;
  String? _error;

  List<dynamic> _patients = [];
  List<dynamic> _doctors = [];
  List<dynamic> _schedules = [];

  String? _selectedPatientId;
  String? _selectedDoctorId;
  String? _selectedScheduleId;
  
  DateTime? _selectedDate;
  TimeOfDay? _startTime;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final pRes = await ApiClient().dio.get('/patients');
      final uRes = await ApiClient().dio.get('/users');
      final sRes = await ApiClient().dio.get('/schedules');
      
      setState(() {
        _patients = pRes.data;
        _doctors = (uRes.data as List).where((u) => u['role'] == 'DOCTOR').toList();
        _schedules = sRes.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data';
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedPatientId == null || _selectedDoctorId == null || _selectedScheduleId == null || _selectedDate == null || _startTime == null) {
      setState(() => _error = 'Please fill all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      await ApiClient().dio.post('/appointments', data: {
        'patientId': _selectedPatientId,
        'doctorId': _selectedDoctorId,
        'scheduleId': _selectedScheduleId,
        'appointmentDate': _selectedDate!.toIso8601String(),
        'startTime': startDateTime.toIso8601String(),
        'visitType': 'CONSULTATION',
        'priority': 'NORMAL',
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onBooked();
      }
    } catch (e) {
      setState(() {
        if (e is DioException) {
          _error = e.response?.data['message'] ?? e.message;
        } else {
          _error = e.toString();
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _patients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Book Appointment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.withValues(alpha: 0.1),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Patient', border: OutlineInputBorder()),
              value: _selectedPatientId,
              items: _patients.map((p) => DropdownMenuItem<String>(
                value: p['id'],
                child: Text("\${p['firstName']} \${p['lastName']} (\${p['patientNumber']})"),
              )).toList(),
              onChanged: (v) => setState(() => _selectedPatientId = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Doctor', border: OutlineInputBorder()),
              value: _selectedDoctorId,
              items: _doctors.map((d) => DropdownMenuItem<String>(
                value: d['id'],
                child: Text("Dr. \${d['firstName']} \${d['lastName']}"),
              )).toList(),
              onChanged: (v) => setState(() => _selectedDoctorId = v),
            ),
            const SizedBox(height: 16),
            if (_selectedDoctorId != null)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Schedule/Shift', border: OutlineInputBorder()),
                value: _selectedScheduleId,
                items: _schedules.where((s) => s['doctorId'] == _selectedDoctorId).map((s) {
                  final start = DateTime.parse(s['startTime']);
                  final end = DateTime.parse(s['endTime']);
                  return DropdownMenuItem<String>(
                    value: s['id'],
                    child: Text("\${DateFormat('MMM d').format(start)} | \${DateFormat('h:mm a').format(start)} - \${DateFormat('h:mm a').format(end)}"),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedScheduleId = v;
                    final s = _schedules.firstWhere((e) => e['id'] == v);
                    _selectedDate = DateTime.parse(s['startTime']);
                  });
                },
              ),
            if (_selectedScheduleId != null) ...[
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start Time'),
                subtitle: Text(_startTime?.format(context) ?? 'Select Time'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) setState(() => _startTime = time);
                },
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Book Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
