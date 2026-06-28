import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DoctorScheduleTab extends StatefulWidget {
  const DoctorScheduleTab({super.key});

  @override
  State<DoctorScheduleTab> createState() => _DoctorScheduleTabState();
}

class _DoctorScheduleTabState extends State<DoctorScheduleTab> {
  String _selectedTimeFilter = "Today";
  bool _isGridView = true;

  List<Map<String, dynamic>> _dummyDoctors = [
    {
      "name": "Dr. Sarah Jenkins",
      "department": "Cardiology",
      "time": "09:00 AM - 01:00 PM",
      "room": "Room 302 - Wing B",
      "patients": "14 Patients Scheduled",
      "status": "Available",
    },
    {
      "name": "Dr. Alan Grant",
      "department": "Neurology",
      "time": "10:30 AM - 04:00 PM",
      "room": "Room 105 - Wing A",
      "patients": "8 Patients Scheduled",
      "status": "Busy",
    },
    {
      "name": "Dr. Emily Chen",
      "department": "Pediatrics",
      "time": "08:00 AM - 12:00 PM",
      "room": "Room 410 - Wing C",
      "patients": "22 Patients Scheduled",
      "status": "On Leave",
    },
    {
      "name": "Dr. Marcus Brody",
      "department": "Orthopedics",
      "time": "01:00 PM - 06:00 PM",
      "room": "Room 201 - Wing B",
      "patients": "10 Patients Scheduled",
      "status": "Available",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showSnackBar("Opening Add Schedule form...");
        },
        backgroundColor: AppTheme.primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Schedule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Search & Filters
            _buildSearchAndFilters(isDark, cardColor, borderColor, fgColor),
            const SizedBox(height: 24),
            
            // Section 2 & 3: Doctor Cards Core Content
            _buildDoctorCardsGrid(isDark, cardColor, borderColor, fgColor),
            
            const SizedBox(height: 80), // Padding for the floating action button
          ],
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

  void _handleMenuAction(String action, Map<String, dynamic> doc) {
    setState(() {
      if (action == "Delete Schedule" || action == "Cancel Schedule") {
        _dummyDoctors.remove(doc);
        _showSnackBar("Action completed successfully");
      } else if (action == "Mark Leave") {
        doc["status"] = "On Leave";
        _showSnackBar("Status updated to On Leave");
      } else if (action == "Emergency Assignment") {
        doc["status"] = "Busy";
        _showSnackBar("Status updated to Busy");
      } else if (action == "Add Extra Slot") {
        _showAddSlotModal(doc);
      } else {
        _showSnackBar("$action action triggered");
      }
    });
  }

  void _showAddSlotModal(Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Extra Slot"),
          content: Text("Add an extra slot for ${doc["name"]}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _dummyDoctors.add({
                    "name": doc["name"],
                    "department": doc["department"],
                    "time": "06:00 PM - 08:00 PM", // Default extra time
                    "room": doc["room"],
                    "patients": "0 Patients Scheduled",
                    "status": "Available",
                  });
                  _showSnackBar("Extra slot added successfully");
                });
              },
              child: const Text("Add"),
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
                          if (selected) setState(() => _selectedTimeFilter = time);
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
    if (_dummyDoctors.isEmpty) {
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
          children: _dummyDoctors.map((doc) {
            return SizedBox(
              width: itemWidth,
              child: _buildDoctorCard(doc, isDark, cardColor, borderColor, fgColor),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> data, bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    Color statusColor;
    switch (data["status"]) {
      case "Available": statusColor = Colors.green; break;
      case "Busy": statusColor = Colors.orange; break;
      case "On Leave": statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

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
                            data["name"],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fgColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data["department"],
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
                    _buildCardRow(Icons.access_time_rounded, data["time"], fgColor),
                    const SizedBox(height: 10),
                    _buildCardRow(Icons.meeting_room_rounded, data["room"], fgColor),
                    const SizedBox(height: 10),
                    _buildCardRow(Icons.people_outline_rounded, data["patients"], fgColor),
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
                        data["status"],
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Trailing PopupMenuButton (10 local actions)
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: fgColor.withValues(alpha: 0.6)),
              color: isDark ? const Color(0xFF2C2A29) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (action) => _handleMenuAction(action, data),
              itemBuilder: (context) => [
                _buildMenuItem("Edit Schedule", Icons.edit_outlined, fgColor),
                _buildMenuItem("Delete Schedule", Icons.delete_outline, Colors.red),
                _buildMenuItem("Change Doctor", Icons.swap_horiz_outlined, fgColor),
                _buildMenuItem("Block Time Slot", Icons.block_outlined, fgColor),
                _buildMenuItem("Mark Leave", Icons.directions_run_outlined, fgColor),
                _buildMenuItem("Emergency Assignment", Icons.warning_amber_outlined, Colors.orange),
                _buildMenuItem("Change Room", Icons.room_preferences_outlined, fgColor),
                _buildMenuItem("Add Extra Slot", Icons.add_circle_outline, fgColor),
                _buildMenuItem("Cancel Schedule", Icons.cancel_outlined, Colors.red),
                _buildMenuItem("View Today's Patients", Icons.visibility_outlined, fgColor),
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
