import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../audit_logs_page.dart';

class AuditLogsTab extends StatefulWidget {
  const AuditLogsTab({super.key});

  @override
  State<AuditLogsTab> createState() => _AuditLogsTabState();
}

class _AuditLogsTabState extends State<AuditLogsTab> {
  bool _isLoading = true;
  List<dynamic> _auditLogs = [];
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMore) return;
      _page++;
    } else {
      _page = 1;
      setState(() => _isLoading = true);
    }

    try {
      final res = await ApiClient().dio.get('/audit', queryParameters: {
        'page': _page,
        'limit': 20,
      });

      final data = res.data['data'] as List;
      final meta = res.data['meta'];

      setState(() {
        if (loadMore) {
          _auditLogs.addAll(data);
        } else {
          _auditLogs = data;
        }
        _hasMore = _page < meta['totalPages'];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading audit logs: $e')));
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
            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ))
            else
              _buildAuditLogs(isDark, cardColor, borderColor, fgColor),
            
            if (_hasMore && !_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: TextButton(
                    onPressed: () => _fetchLogs(loadMore: true),
                    child: const Text("Load More", style: TextStyle(color: AppTheme.primaryOrange)),
                  ),
                ),
              ),
            
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
    if (_auditLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text("No audit logs found", style: TextStyle(color: fgColor.withValues(alpha: 0.5))),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _auditLogs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = _auditLogs[index];
        final bool isSuccess = log["status"] == "SUCCESS";
        final statusColor = isSuccess ? Colors.green : Colors.red;
        final statusIcon = isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded;

        final actionFormatted = log["action"].toString().replaceAll("_", " ");
        final userName = log["user"] != null ? "${log["user"]["firstName"]} ${log["user"]["lastName"]}" : "System";
        final userRole = log["user"] != null ? log["user"]["role"] : "System";
        
        final date = DateTime.parse(log["createdAt"]).toLocal();
        final timestamp = "${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

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
                actionFormatted,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: fgColor),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "$userName • $userRole • $timestamp",
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
                          _buildDetailRow("Device", log["device"] ?? "N/A", fgColor),
                          const SizedBox(height: 12),
                          _buildDetailRow("Location", log["location"] ?? "N/A", fgColor),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow("IP Address", log["ipAddress"] ?? "N/A", fgColor),
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
