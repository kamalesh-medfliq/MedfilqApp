import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuditLogsPage extends StatelessWidget {
  final String alertType;

  const AuditLogsPage({super.key, required this.alertType});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1A18) : const Color(0xFFF9F6F0);
    final fgColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF2C2A29) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    // Filtered mock data based on alertType
    final List<Map<String, dynamic>> filteredLogs = _generateMockLogs(alertType);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: fgColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          alertType,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: fgColor,
          ),
        ),
      ),
      body: filteredLogs.isEmpty
          ? Center(
              child: Text(
                "No events found for this alert type.",
                style: TextStyle(color: fgColor.withValues(alpha: 0.5)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredLogs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = filteredLogs[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                        child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log["name"]!,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fgColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              log["description"]!,
                              style: TextStyle(fontSize: 14, color: fgColor.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        log["timestamp"]!,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fgColor.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  List<Map<String, String>> _generateMockLogs(String type) {
    // Generate dummy data based on the specific alert type clicked
    if (type == "Failed Login Attempts") {
      return [
        {"name": "Nurse Supervisor", "timestamp": "10:45 AM", "description": "Failed login from IP: 192.168.1.1"},
        {"name": "Dr. Sarah Jenkins", "timestamp": "09:12 AM", "description": "Failed login from IP: 10.0.0.4"},
        {"name": "Administrator", "timestamp": "08:30 AM", "description": "Failed login from IP: 112.134.55.22"},
      ];
    } else if (type == "Multiple Failed Passwords") {
      return [
        {"name": "Dr. Alan Grant", "timestamp": "11:20 AM", "description": "5 consecutive failed passwords"},
        {"name": "Receptionist", "timestamp": "Yesterday", "description": "3 consecutive failed passwords"},
      ];
    } else if (type == "Suspicious Login") {
      return [
        {"name": "System Administrator", "timestamp": "02:15 AM", "description": "Login from unusual location (Russia)"},
      ];
    }
    
    // Fallback for other alert types
    return [
      {"name": "Unknown Staff", "timestamp": "Just now", "description": "Event logged for $type"},
    ];
  }
}
