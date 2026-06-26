import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF1E1A18) : const Color(0xFFF9F6F0);
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    // Dynamic Date
    final now = DateTime.now();
    final dayString = DateFormat('EEEE').format(now);
    final dateString = DateFormat('d MMMM y').format(now);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: Dynamic Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_getGreeting()} 👋",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: fgColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Administrator",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: fgColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ABC Multispeciality Hospital",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: fgColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dayString,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                  Text(
                    dateString,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: fgColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Section 2: Dashboard Summary Cards
          Text(
            "Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fgColor),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildMetricCard("Today's Patients", "142", "+12%", Icons.people_outline_rounded, isDark, cardColor, borderColor, fgColor),
                  _buildMetricCard("Today's Visits", "89", "+5%", Icons.calendar_month_rounded, isDark, cardColor, borderColor, fgColor),
                  _buildMetricCard("SOAP Notes", "64", "+8%", Icons.assignment_outlined, isDark, cardColor, borderColor, fgColor),
                  _buildMetricCard("Prescriptions", "112", "+15%", Icons.medical_services_outlined, isDark, cardColor, borderColor, fgColor),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Section 3: System Health
          Text(
            "System Health",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fgColor),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildSystemPill("Firebase", "Healthy", Colors.green, cardColor, borderColor, fgColor),
                _buildSystemPill("Database", "Healthy", Colors.green, cardColor, borderColor, fgColor),
                _buildSystemPill("Internet", "Warning", Colors.orange, cardColor, borderColor, fgColor),
                _buildSystemPill("Storage", "45% Used", Colors.green, cardColor, borderColor, fgColor),
                _buildSystemPill("Last Backup", "2h ago", Colors.green, cardColor, borderColor, fgColor),
                _buildSystemPill("Server Time", DateFormat('HH:mm a').format(now), Colors.green, cardColor, borderColor, fgColor),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Section 4: Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Activity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fgColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Today", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fgColor)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: fgColor.withValues(alpha: 0.6)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityList(isDark, cardColor, borderColor, fgColor),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String trend, IconData icon, bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryOrange, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: fgColor),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: fgColor.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPill(String title, String status, Color dotColor, Color cardColor, Color borderColor, Color fgColor) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fgColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fgColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    final activities = [
      {
        "icon": Icons.check_circle_outline,
        "title": "Doctor completed consultation",
        "subtitle": "Dr. Sarah • 10:42 AM"
      },
      {
        "icon": Icons.person_add_outlined,
        "title": "Receptionist registered patient",
        "subtitle": "Front Desk • 10:15 AM"
      },
      {
        "icon": Icons.monitor_heart_outlined,
        "title": "Nurse updated vitals",
        "subtitle": "Nurse Station A • 09:30 AM"
      },
      {
        "icon": Icons.description_outlined,
        "title": "Prescription generated",
        "subtitle": "Dr. Mark • 09:12 AM"
      },
      {
        "icon": Icons.event_available_outlined,
        "title": "Appointment rescheduled",
        "subtitle": "Front Desk • 08:45 AM"
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => Divider(color: borderColor, height: 1),
        itemBuilder: (context, index) {
          final item = activities[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item["icon"] as IconData, color: AppTheme.primaryOrange, size: 20),
            ),
            title: Text(
              item["title"] as String,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fgColor),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item["subtitle"] as String,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fgColor.withValues(alpha: 0.5)),
              ),
            ),
          );
        },
      ),
    );
  }
}
