import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';

class DoctorScheduleTab extends StatefulWidget {
  const DoctorScheduleTab({super.key});

  @override
  State<DoctorScheduleTab> createState() => _DoctorScheduleTabState();
}

class _DoctorScheduleTabState extends State<DoctorScheduleTab> {
  String _selectedTimeFilter = "Today";
  bool _isGridView = true;

  bool _isLoading = true;
  List<dynamic> _schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      String? startDate;
      String? endDate;

      if (_selectedTimeFilter == "Today") {
        startDate = DateTime(now.year, now.month, now.day).toIso8601String();
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
      } else if (_selectedTimeFilter == "Tomorrow") {
        final tmrw = now.add(const Duration(days: 1));
        startDate = DateTime(tmrw.year, tmrw.month, tmrw.day).toIso8601String();
        endDate = DateTime(tmrw.year, tmrw.month, tmrw.day, 23, 59, 59).toIso8601String();
      } else if (_selectedTimeFilter == "Week") {
        startDate = DateTime(now.year, now.month, now.day).toIso8601String();
        endDate = now.add(const Duration(days: 7)).toIso8601String();
      }

      final res = await ApiClient().dio.get('/schedules', queryParameters: {
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      });
      setState(() {
        _schedules = res.data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddScheduleModal,
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Schedule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSchedules,
        color: AppTheme.primaryOrange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Search & Filters
              _buildSearchAndFilters(isDark, cardColor, borderColor, fgColor),
              const SizedBox(height: 24),
              
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                ))
              else
                _buildDoctorCardsGrid(isDark, cardColor, borderColor, fgColor),
              
              const SizedBox(height: 80), // Padding for the floating action button
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleMenuAction(String action, Map<String, dynamic> schedule) async {
    final id = schedule["id"];
    try {
      if (action == "Delete Schedule") {
        await ApiClient().dio.delete('/schedules/$id');
        _showSnackBar("Schedule deleted successfully");
        _fetchSchedules();
      } else if (action == "Cancel Schedule") {
        await ApiClient().dio.put('/schedules/$id', data: {"status": "CANCELLED"});
        _showSnackBar("Schedule cancelled");
        _fetchSchedules();
      } else if (action == "Mark Leave") {
        await ApiClient().dio.put('/schedules/$id', data: {"status": "ON_LEAVE"});
        _showSnackBar("Status updated to On Leave");
        _fetchSchedules();
      } else if (action == "Emergency Assignment") {
        await ApiClient().dio.put('/schedules/$id', data: {"status": "BUSY"});
        _showSnackBar("Status updated to Busy");
        _fetchSchedules();
      } else {
        _showSnackBar("$action action triggered");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAddScheduleModal() {
    final doctorIdController = TextEditingController();
    final roomController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Schedule"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: doctorIdController,
                  decoration: const InputDecoration(labelText: "Doctor ID (UUID)"),
                ),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(labelText: "Room Number"),
                ),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(labelText: "Start Time (YYYY-MM-DDTHH:mm:00Z)"),
                ),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(labelText: "End Time (YYYY-MM-DDTHH:mm:00Z)"),
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
              onPressed: () async {
                try {
                  await ApiClient().dio.post('/schedules', data: {
                    "doctorId": doctorIdController.text,
                    "roomNumber": roomController.text,
                    "startTime": startTimeController.text,
                    "endTime": endTimeController.text,
                    "status": "AVAILABLE"
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    _showSnackBar("Schedule created successfully");
                    _fetchSchedules();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters(bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        TextField(
          style: TextStyle(color: fgColor),
          decoration: InputDecoration(
            hintText: "Search doctors, departments, or rooms...",
            hintStyle: TextStyle(color: fgColor.withValues(alpha: 0.4)),
            filled: true,
            fillColor: cardColor,
            prefixIcon: Icon(Icons.search, color: fgColor.withValues(alpha: 0.4)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryOrange),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Time Filters and View Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ["Today", "Tomorrow", "Week"].map((time) {
                    final isSelected = _selectedTimeFilter == time;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(time),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedTimeFilter = time);
                            _fetchSchedules();
                          }
                        },
                        selectedColor: AppTheme.primaryOrange.withValues(alpha: 0.15),
                        backgroundColor: cardColor,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryOrange : fgColor.withValues(alpha: 0.7),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.5) : borderColor,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // View Toggle
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.grid_view_rounded, size: 20, color: _isGridView ? AppTheme.primaryOrange : fgColor.withValues(alpha: 0.4)),
                    onPressed: () => setState(() => _isGridView = true),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_month_rounded, size: 20, color: !_isGridView ? AppTheme.primaryOrange : fgColor.withValues(alpha: 0.4)),
                    onPressed: () => setState(() => _isGridView = false),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Dropdown Filters
        Row(
          children: [
            Expanded(
              child: _buildDropdown("Department", cardColor, borderColor, fgColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown("Doctor", cardColor, borderColor, fgColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String hint, Color cardColor, Color borderColor, Color fgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              hint, 
              style: TextStyle(color: fgColor.withValues(alpha: 0.7), fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: fgColor.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }

  Widget _buildDoctorCardsGrid(bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    if (_schedules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 64, color: fgColor.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text(
                "No records found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: fgColor.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 800 ? 3 : (width > 500 ? 2 : 1);
        const double spacing = 16.0;
        
        // Prevent layout issues if crossAxisCount is somehow 0 or spacing logic breaks
        final double safeWidth = width > 0 ? width : 300;
        final double itemWidth = (safeWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _schedules.map((schedule) {
            return SizedBox(
              width: itemWidth,
              child: _buildDoctorCard(schedule, isDark, cardColor, borderColor, fgColor),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> schedule, bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    Color statusColor;
    String statusDisplay;
    switch (schedule["status"]) {
      case "AVAILABLE": statusColor = Colors.green; statusDisplay = "Available"; break;
      case "BUSY": statusColor = Colors.orange; statusDisplay = "Busy"; break;
      case "ON_LEAVE": statusColor = Colors.red; statusDisplay = "On Leave"; break;
      case "CANCELLED": statusColor = Colors.grey; statusDisplay = "Cancelled"; break;
      default: statusColor = Colors.grey; statusDisplay = schedule["status"] ?? "Unknown";
    }

    final doctor = schedule["doctor"] ?? {};
    final name = "Dr. ${doctor["firstName"] ?? ''} ${doctor["lastName"] ?? ''}";
    final department = doctor["department"] ?? 'General';
    
    final startTime = DateTime.parse(schedule["startTime"]).toLocal();
    final endTime = DateTime.parse(schedule["endTime"]).toLocal();
    final timeStr = "${DateFormat('hh:mm a').format(startTime)} - ${DateFormat('hh:mm a').format(endTime)}";

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Let Wrap handle the height naturally
              children: [
                // Top section: Name & Department
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppTheme.primaryOrange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fgColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            department,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryOrange),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24), // Leave space for PopupMenuButton
                  ],
                ),
                const SizedBox(height: 20),
                
                // Middle section: Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardRow(Icons.access_time_rounded, timeStr, fgColor),
                    const SizedBox(height: 10),
                    _buildCardRow(Icons.meeting_room_rounded, "Room ${schedule["roomNumber"] ?? 'TBD'}", fgColor),
                    const SizedBox(height: 10),
                    _buildCardRow(Icons.people_outline_rounded, "${schedule["patientCount"] ?? 0} Patients", fgColor),
                  ],
                ),
                const SizedBox(height: 20),

                // Bottom section: Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusDisplay,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Trailing PopupMenuButton (actions)
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: fgColor.withValues(alpha: 0.6)),
              color: isDark ? const Color(0xFF2C2A29) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (action) => _handleMenuAction(action, schedule),
              itemBuilder: (context) => [
                _buildMenuItem("Edit Schedule", Icons.edit_outlined, fgColor),
                _buildMenuItem("Delete Schedule", Icons.delete_outline, Colors.red),
                _buildMenuItem("Mark Leave", Icons.directions_run_outlined, fgColor),
                _buildMenuItem("Emergency Assignment", Icons.warning_amber_outlined, Colors.orange),
                _buildMenuItem("Cancel Schedule", Icons.cancel_outlined, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRow(IconData icon, String text, Color fgColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: fgColor.withValues(alpha: 0.4)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: fgColor.withValues(alpha: 0.8)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String title, IconData icon, Color color) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
