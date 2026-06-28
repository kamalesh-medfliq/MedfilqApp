import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../audit_logs_page.dart';

class AuditLogsTab extends StatefulWidget {
  const AuditLogsTab({super.key});

  @override
  State<AuditLogsTab> createState() => _AuditLogsTabState();
}

class _AuditLogsTabState extends State<AuditLogsTab> {
  final List<Map<String, dynamic>> _dummyLogs = [
    {
      "action": "Doctor Schedule Updated",
      "user": "System Administrator",
      "role": "Administrator",
      "timestamp": "Oct 24, 10:45 AM",
      "status": "Success",
      "device": "MacBook Pro - Chrome",
      "ip": "192.168.1.45",
      "location": "Chennai, India",
    },
    {
      "action": "Failed Login Attempt",
      "user": "Nurse Supervisor",
      "role": "Nurse",
      "timestamp": "Oct 24, 09:12 AM",
      "status": "Failed - Invalid Password",
      "device": "iPhone 14 Pro - Safari",
      "ip": "112.134.55.22",
      "location": "Mumbai, India",
    },
    {
      "action": "Patient Record Edited",
      "user": "Dr. Resident",
      "role": "Doctor",
      "timestamp": "Oct 23, 04:30 PM",
      "status": "Success",
      "device": "Dell XPS 15 - Edge",
      "ip": "192.168.1.50",
      "location": "Chennai, India",
    },
    {
      "action": "User Deleted",
      "user": "System Administrator",
      "role": "Administrator",
      "timestamp": "Oct 23, 02:15 PM",
      "status": "Success",
      "device": "MacBook Pro - Chrome",
      "ip": "192.168.1.45",
      "location": "Chennai, India",
    },
    {
      "action": "Settings Changed (Security)",
      "user": "System Administrator",
      "role": "Administrator",
      "timestamp": "Oct 22, 11:00 AM",
      "status": "Success",
      "device": "Windows Desktop - Chrome",
      "ip": "192.168.1.12",
      "location": "Chennai, India",
    },
    {
      "action": "Account Locked",
      "user": "Unknown User",
      "role": "Guest",
      "timestamp": "Oct 21, 08:20 PM",
      "status": "Failed - Max Attempts",
      "device": "Unknown Device",
      "ip": "104.22.45.99",
      "location": "Unknown",
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Top Bar (Search & Export)
            _buildTopBar(isDark, cardColor, borderColor, fgColor),
            const SizedBox(height: 16),
            
            // Section 2: Filters Row
            _buildFiltersRow(isDark, cardColor, borderColor, fgColor),
            const SizedBox(height: 32),

            // Section 3: Security Monitoring
            Text(
              "Security Alerts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.orange.shade700),
            ),
            const SizedBox(height: 16),
            _buildSecurityAlerts(isDark, cardColor, borderColor, fgColor),
            const SizedBox(height: 32),

            // Section 4: The Audit Log List
            Text(
              "System Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fgColor),
            ),
            const SizedBox(height: 16),
            _buildAuditLogs(isDark, cardColor, borderColor, fgColor),
            
            const SizedBox(height: 80), // Bottom Nav padding
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchBar(cardColor, borderColor, fgColor),
              const SizedBox(height: 12),
              _buildExportMenu(isDark, cardColor, borderColor, fgColor),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildSearchBar(cardColor, borderColor, fgColor),
            ),
            const SizedBox(width: 16),
            _buildExportMenu(isDark, cardColor, borderColor, fgColor),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(Color cardColor, Color borderColor, Color fgColor) {
    return TextField(
      style: TextStyle(color: fgColor),
      decoration: InputDecoration(
        hintText: "Search audit logs...",
        hintStyle: TextStyle(color: fgColor.withValues(alpha: 0.4)),
        filled: true,
        fillColor: cardColor,
        prefixIcon: Icon(Icons.search, color: fgColor.withValues(alpha: 0.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryOrange)),
      ),
    );
  }

  Widget _buildExportMenu(bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.5)),
      ),
      child: PopupMenuButton<String>(
        color: isDark ? const Color(0xFF2C2A29) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tooltip: "Export",
        itemBuilder: (context) => [
          _buildMenuItem("Export as PDF", Icons.picture_as_pdf_outlined, Colors.red),
          _buildMenuItem("Export to Excel", Icons.table_chart_outlined, Colors.green),
          _buildMenuItem("Print", Icons.print_outlined, fgColor),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Export", style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryOrange, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow(bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip("Last 7 Days", fgColor, cardColor, borderColor),
          const SizedBox(width: 8),
          _buildFilterChip("User", fgColor, cardColor, borderColor),
          const SizedBox(width: 8),
          _buildFilterChip("Role", fgColor, cardColor, borderColor),
          const SizedBox(width: 8),
          _buildFilterChip("Action Type", fgColor, cardColor, borderColor),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color fgColor, Color cardColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: fgColor.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: fgColor.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildSecurityAlerts(bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    final alerts = [
      "Failed Login Attempts",
      "Multiple Failed Passwords",
      "Suspicious Login",
      "Permission Changes",
      "Account Locked",
      "Password Reset History"
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: alerts.map((title) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AuditLogsPage(alertType: title),
                ),
              );
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: fgColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title == "Failed Login Attempts" ? "3 Events" : 
                    title == "Multiple Failed Passwords" ? "2 Events" :
                    title == "Suspicious Login" ? "1 Event" : "0 Events",
                    style: TextStyle(fontSize: 12, color: fgColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
     ),
    );
  }

  Widget _buildAuditLogs(bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dummyLogs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = _dummyLogs[index];
        final bool isSuccess = log["status"] == "Success";
        final statusColor = isSuccess ? Colors.green : Colors.red;
        final statusIcon = isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded;

        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: Icon(statusIcon, color: statusColor, size: 28),
              title: Text(
                log["action"],
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: fgColor),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "${log["user"]} • ${log["role"]} • ${log["timestamp"]}",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fgColor.withValues(alpha: 0.6)),
                ),
              ),
              children: [
                Divider(color: borderColor, height: 16),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow("Device", log["device"], fgColor),
                          const SizedBox(height: 12),
                          _buildDetailRow("Location", log["location"], fgColor),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow("IP Address", log["ip"], fgColor),
                          const SizedBox(height: 12),
                          _buildDetailRow("Result", log["status"], fgColor, valueColor: statusColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color fgColor, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fgColor.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? fgColor.withValues(alpha: 0.9)),
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
