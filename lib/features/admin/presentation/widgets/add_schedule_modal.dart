import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';

class AddScheduleModal extends StatefulWidget {
  final VoidCallback onScheduleAdded;

  const AddScheduleModal({super.key, required this.onScheduleAdded});

  @override
  State<AddScheduleModal> createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<AddScheduleModal> {
  bool _isLoadingDoctors = true;
  List<dynamic> _doctors = [];
  
  String? _selectedDoctorId;
  String? _selectedRoom;
  
  DateTime? _startDate;
  TimeOfDay? _startTime;
  
  DateTime? _endDate;
  TimeOfDay? _endTime;

  final List<String> _rooms = [
    'Room 101', 'Room 102', 'Room 103', 'Room 104',
    'Room 201', 'Room 202', 'OT 1', 'OT 2'
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final res = await ApiClient().dio.get('/users');
      final allUsers = res.data as List;
      
      // Also fetch schedules to get existing rooms
      List<String> existingRooms = [];
      try {
        final schedRes = await ApiClient().dio.get('/schedules');
        final allScheds = schedRes.data as List;
        existingRooms = allScheds.map((s) => s['roomNumber'].toString()).toSet().toList();
      } catch (e) {
        // Ignore schedule fetch error for rooms
      }
      
      final Set<String> roomSet = {..._rooms, ...existingRooms};

      setState(() {
        _doctors = allUsers.where((u) => u['role'] == 'DOCTOR').toList();
        _rooms.clear();
        _rooms.addAll(roomSet);
        _isLoadingDoctors = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDoctors = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load doctors: $e')));
      }
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      if (isStart) {
        _startDate = date;
        _startTime = time;
      } else {
        _endDate = date;
        _endTime = time;
      }
    });
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return "Not selected";
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dt);
  }

  Future<void> _submit() async {
    if (_selectedDoctorId == null || _selectedRoom == null || _startDate == null || _startTime == null || _endDate == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final startDateTime = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, _startTime!.hour, _startTime!.minute).toUtc().toIso8601String();
    final endDateTime = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, _endTime!.hour, _endTime!.minute).toUtc().toIso8601String();

    try {
      await ApiClient().dio.post('/schedules', data: {
        "doctorId": _selectedDoctorId,
        "roomNumber": _selectedRoom,
        "startTime": startDateTime,
        "endTime": endDateTime,
        "status": "AVAILABLE"
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Schedule created successfully")));
        widget.onScheduleAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      title: const Text("Add Schedule"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Doctor", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingDoctors 
              ? const CircularProgressIndicator() 
              : DropdownButtonFormField<String>(
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  hint: const Text("Select Doctor"),
                  value: _selectedDoctorId,
                  items: _doctors.map((d) {
                    return DropdownMenuItem<String>(
                      value: d['id'],
                      child: Text('${d['firstName']} ${d['lastName']}'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedDoctorId = val),
                ),
            const SizedBox(height: 16),

            const Text("Room Number", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _rooms;
                }
                return _rooms.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                setState(() => _selectedRoom = selection);
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                // Keep selectedRoom in sync with typed text
                textEditingController.addListener(() {
                  _selectedRoom = textEditingController.text;
                });
                
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Select or type a room (e.g. Room 101)",
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            const Text("Start Time", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickDateTime(true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDateTime(_startDate, _startTime)),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text("End Time", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickDateTime(false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDateTime(_endDate, _endTime)),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Create"),
        ),
      ],
    );
  }
}
