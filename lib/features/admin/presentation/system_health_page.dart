import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SystemHealthPage extends StatelessWidget {
  const SystemHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1A18) : const Color(0xFFF9F6F0);
    final fgColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF2C2A29) : Colors.white;
    final borderColor = fgColor.withValues(alpha: 0.08);

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
          "System Health",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: fgColor,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          // Calculate card width for grid
          final cardWidth = isSmallScreen 
              ? constraints.maxWidth - 32 // Full width minus padding on small screens
              : (constraints.maxWidth - 48) / 2; // Two columns on wider screens

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatusCard(
                  title: "Firebase",
                  status: "Healthy",
                  color: Colors.green,
                  icon: Icons.cloud_done_rounded,
                  cardWidth: cardWidth,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  fgColor: fgColor,
                ),
                _buildStatusCard(
                  title: "Database",
                  status: "Healthy",
                  color: Colors.green,
                  icon: Icons.storage_rounded,
                  cardWidth: cardWidth,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  fgColor: fgColor,
                ),
                _buildStatusCard(
                  title: "Internet",
                  status: "Warning",
                  color: Colors.orange,
                  icon: Icons.wifi_find_rounded,
                  cardWidth: cardWidth,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  fgColor: fgColor,
                ),
                _buildStatusCard(
                  title: "Storage",
                  status: "45% Used",
                  color: AppTheme.primaryOrange,
                  icon: Icons.sd_storage_rounded,
                  cardWidth: cardWidth,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  fgColor: fgColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String status,
    required Color color,
    required IconData icon,
    required double cardWidth,
    required Color cardColor,
    required Color borderColor,
    required Color fgColor,
  }) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: fgColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
