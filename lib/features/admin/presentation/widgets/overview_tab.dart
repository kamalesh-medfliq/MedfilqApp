import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  bool _isLoading = true;
  
  Map<String, dynamic> _overviewData = {
    "patientsToday": 0,
    "visitsToday": 0,
    "soapToday": null,
    "prescriptionsToday": null,
  };
  
  Map<String, dynamic> _systemHealth = {
    "database": "Checking...",
    "api": "Checking...",
    "serverTime": DateTime.now().toIso8601String(),
    "storage": "Checking..."
  };
  
  List<dynamic> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final overviewRes = await ApiClient().dio.get('/dashboard/overview');
      final healthRes = await ApiClient().dio.get('/dashboard/system-health');
      final activityRes = await ApiClient().dio.get('/dashboard/recent-activity');

      setState(() {
        _overviewData = overviewRes.data;
        _systemHealth = healthRes.data;
        _recentActivity = activityRes.data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load dashboard data: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

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

    final now = DateTime.now();
    final dayString = DateFormat('EEEE').format(now);
    final dateString = DateFormat('d MMMM y').format(now);

    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      color: AppTheme.primaryOrange,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                        "MedFliq Clinic",
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
                      style: const TextStyle(
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

            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ))
            else ...[
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
                      _buildMetricCard(
                        "Today's Patients", 
                        _overviewData['patientsToday'] is Map ? _overviewData['patientsToday']['value'].toString() : _overviewData['patientsToday'].toString(), 
                        (_overviewData['patientsToday'] is Map && _overviewData['patientsToday']['implemented'] == false) ? "N/A" : "Live", 
                        Icons.people_outline_rounded, isDark, cardColor, borderColor, fgColor
                      ),
                      _buildMetricCard(
                        "Today's Visits", 
                        _overviewData['visitsToday'] is Map ? _overviewData['visitsToday']['value'].toString() : _overviewData['visitsToday'].toString(), 
                        (_overviewData['visitsToday'] is Map && _overviewData['visitsToday']['implemented'] == false) ? "N/A" : "Live", 
                        Icons.calendar_month_rounded, isDark, cardColor, borderColor, fgColor
                      ),
                      _buildMetricCard(
                        "SOAP Notes", 
                        _overviewData['soapToday'] is Map ? _overviewData['soapToday']['value'].toString() : (_overviewData['soapToday']?.toString() ?? "0"), 
                        (_overviewData['soapToday'] is Map && _overviewData['soapToday']['implemented'] == false) ? "N/A" : "Live", 
                        Icons.assignment_outlined, isDark, cardColor, borderColor, fgColor
                      ),
                      _buildMetricCard(
                        "Prescriptions", 
                        _overviewData['prescriptionsToday'] is Map ? _overviewData['prescriptionsToday']['value'].toString() : (_overviewData['prescriptionsToday']?.toString() ?? "0"), 
                        (_overviewData['prescriptionsToday'] is Map && _overviewData['prescriptionsToday']['implemented'] == false) ? "N/A" : "Live", 
                        Icons.medical_services_outlined, isDark, cardColor, borderColor, fgColor
                      ),
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
                    _buildSystemPill("Database", _systemHealth['database'], _systemHealth['database'] == 'Operational' ? Colors.green : Colors.red, cardColor, borderColor, fgColor),
                    _buildSystemPill("API", _systemHealth['api'], _systemHealth['api'] == 'Operational' ? Colors.green : Colors.orange, cardColor, borderColor, fgColor),
                    _buildSystemPill("Storage", _systemHealth['storage'], Colors.green, cardColor, borderColor, fgColor),
                    _buildSystemPill("Server Time", DateFormat('HH:mm').format(DateTime.parse(_systemHealth['serverTime'] ?? DateTime.now().toIso8601String()).toLocal()), Colors.green, cardColor, borderColor, fgColor),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Section 4: Recent Activity
              Text(
                "Recent Activity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fgColor),
              ),
              const SizedBox(height: 16),
              _buildActivityList(isDark, cardColor, borderColor, fgColor),
            ],
            const SizedBox(height: 40),
          ],
        ),
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
                  color: trend == "N/A" ? Colors.grey.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: TextStyle(color: trend == "N/A" ? Colors.grey : Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
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
    if (_recentActivity.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text("No recent activity", style: TextStyle(color: fgColor.withValues(alpha: 0.5))),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentActivity.length,
        separatorBuilder: (context, index) => Divider(color: borderColor, height: 1),
        itemBuilder: (context, index) {
          final item = _recentActivity[index];
          
          IconData icon = Icons.info_outline;
          if (item['action'] == 'LOGIN') icon = Icons.login;
          if (item['action'] == 'CREATE_USER') icon = Icons.person_add_outlined;
          if (item['action'] == 'UPDATE_USER') icon = Icons.edit_outlined;
          if (item['action'] == 'DELETE_USER') icon = Icons.delete_outline;

          final userName = item['user'] != null 
              ? "${item['user']['firstName']} ${item['user']['lastName']}" 
              : "System";

          final date = DateTime.parse(item['createdAt']).toLocal();
          final timeString = DateFormat('h:mm a').format(date);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryOrange, size: 20),
            ),
            title: Text(
              item['action'].toString().replaceAll('_', ' '),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fgColor),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "$userName • $timeString\n${item['details'] ?? ''}",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fgColor.withValues(alpha: 0.5)),
              ),
            ),
          );
        },
      ),
    );
  }
}
