import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final Set<int> _selectedUserIds = {};

  final List<Map<String, dynamic>> _dummyUsers = [
    {
      "id": 101,
      "name": "Dr. Emily Chen",
      "role": "Doctor",
      "department": "Pediatrics",
      "status": "Active",
      "email": "emily.chen@example.com",
      "phone": "+1 555-0102",
      "gender": "Female",
      "qualification": "MD, Pediatrics",
      "license": "MED-784920",
      "joiningDate": "12 Jan 2024",
      "lastLogin": "Today, 08:30 AM",
      "emailVerified": true,
      "phoneVerified": true,
      "permissions": {
        "View Patients": true,
        "Edit Patients": true,
        "Create Prescription": true,
        "Create SOAP Notes": true,
        "Manage Appointments": false,
        "View Reports": false,
      }
    },
    {
      "id": 102,
      "name": "Nurse Mark Davis",
      "role": "Nurse",
      "department": "Emergency",
      "status": "Active",
      "email": "mark.davis@example.com",
      "phone": "+1 555-0103",
      "gender": "Male",
      "qualification": "BSc Nursing",
      "license": null,
      "joiningDate": "05 Mar 2025",
      "lastLogin": "Yesterday, 04:15 PM",
      "emailVerified": true,
      "phoneVerified": true,
      "permissions": {
        "View Patients": true,
        "Edit Patients": false,
        "Create Prescription": false,
        "Create SOAP Notes": true,
        "Manage Appointments": false,
        "View Reports": false,
      }
    },
    {
      "id": 103,
      "name": "Administrator",
      "role": "Administrator",
      "department": "Management",
      "status": "Active",
      "email": "admin@example.com",
      "phone": "+1 555-0101",
      "gender": "Not Specified",
      "qualification": "MHA",
      "license": null,
      "joiningDate": "01 Jan 2024",
      "lastLogin": "Today, 10:00 AM",
      "emailVerified": true,
      "phoneVerified": false,
      "permissions": {
        "View Patients": true,
        "Edit Patients": true,
        "Create Prescription": false,
        "Create SOAP Notes": false,
        "Manage Appointments": true,
        "View Reports": true,
      }
    },
    {
      "id": 104,
      "name": "Alex Johnson",
      "role": "Receptionist",
      "department": "Front Desk",
      "status": "Pending",
      "email": "alex.j@example.com",
      "phone": "+1 555-0104",
      "gender": "Non-binary",
      "qualification": "High School",
      "license": null,
      "joiningDate": "20 Jun 2026",
      "lastLogin": "Never",
      "emailVerified": false,
      "phoneVerified": false,
      "permissions": {
        "View Patients": true,
        "Edit Patients": false,
        "Create Prescription": false,
        "Create SOAP Notes": false,
        "Manage Appointments": true,
        "View Reports": false,
      }
    },
    {
      "id": 105,
      "name": "Dr. Sarah Jenkins",
      "role": "Doctor",
      "department": "Cardiology",
      "status": "Inactive",
      "email": "sarah.j@example.com",
      "phone": "+1 555-0105",
      "gender": "Female",
      "qualification": "MD, Cardiology",
      "license": "MED-112233",
      "joiningDate": "15 Feb 2024",
      "lastLogin": "10 May 2026",
      "emailVerified": true,
      "phoneVerified": true,
      "permissions": {
        "View Patients": true,
        "Edit Patients": true,
        "Create Prescription": true,
        "Create SOAP Notes": true,
        "Manage Appointments": false,
        "View Reports": false,
      }
    },
  ];

  void _toggleUserSelection(int id) {
    setState(() {
      if (_selectedUserIds.contains(id)) {
        _selectedUserIds.remove(id);
      } else {
        _selectedUserIds.add(id);
      }
    });
  }

  void _toggleAllSelection(bool? value) {
    setState(() {
      if (value == true) {
        _selectedUserIds.addAll(_dummyUsers.map((e) => e["id"] as int));
      } else {
        _selectedUserIds.clear();
      }
    });
  }

  void _showUserProfileModal(Map<String, dynamic> user, bool isDark, Color bgColor, Color fgColor, Color cardColor, Color borderColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserProfileModal(
        user: user, 
        isDark: isDark, 
        bgColor: bgColor, 
        fgColor: fgColor, 
        cardColor: cardColor, 
        borderColor: borderColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF1E1A18) : const Color(0xFFF9F6F0);
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
            // Section 1: Top Bar
            _buildTopBar(isDark, cardColor, borderColor, fgColor),
            const SizedBox(height: 24),
            
            // Section 2: User Cards
            _buildUserCards(isDark, bgColor, fgColor, cardColor, borderColor),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark, Color cardColor, Color borderColor, Color fgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Action Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Team Directory", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fgColor)),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add Team Member", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Search & Filters Row
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  _buildSearchBar(cardColor, borderColor, fgColor),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip("Department", fgColor, cardColor, borderColor),
                        const SizedBox(width: 8),
                        _buildFilterChip("Role", fgColor, cardColor, borderColor),
                        const SizedBox(width: 8),
                        _buildFilterChip("Status", fgColor, cardColor, borderColor),
                        const SizedBox(width: 8),
                        _buildBulkActions(fgColor, cardColor, borderColor, isDark),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(flex: 2, child: _buildSearchBar(cardColor, borderColor, fgColor)),
                const SizedBox(width: 16),
                _buildFilterChip("Department", fgColor, cardColor, borderColor),
                const SizedBox(width: 12),
                _buildFilterChip("Role", fgColor, cardColor, borderColor),
                const SizedBox(width: 12),
                _buildFilterChip("Status", fgColor, cardColor, borderColor),
                const SizedBox(width: 16),
                _buildBulkActions(fgColor, cardColor, borderColor, isDark),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(Color cardColor, Color borderColor, Color fgColor) {
    return TextField(
      style: TextStyle(color: fgColor),
      decoration: InputDecoration(
        hintText: "Search by name, role, or email...",
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

  Widget _buildBulkActions(Color fgColor, Color cardColor, Color borderColor, bool isDark) {
    return PopupMenuButton<String>(
      color: isDark ? const Color(0xFF2C2A29) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tooltip: "Bulk Actions",
      itemBuilder: (context) => [
        _buildMenuItem("Delete Multiple Users", Icons.delete_sweep_outlined, Colors.red),
        _buildMenuItem("Disable Users", Icons.person_off_outlined, Colors.orange),
        _buildMenuItem("Enable Users", Icons.person_add_alt_1_outlined, Colors.green),
        _buildMenuItem("Export CSV", Icons.file_download_outlined, fgColor),
        _buildMenuItem("Import CSV", Icons.file_upload_outlined, fgColor),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Bulk Actions", style: TextStyle(color: AppTheme.primaryOrange, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Icon(Icons.checklist_rounded, size: 18, color: AppTheme.primaryOrange),
          ],
        ),
      ),
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

  Widget _buildUserCards(bool isDark, Color bgColor, Color fgColor, Color cardColor, Color borderColor) {
    final bool allSelected = _selectedUserIds.length == _dummyUsers.length && _dummyUsers.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: allSelected,
              onChanged: _toggleAllSelection,
              activeColor: AppTheme.primaryOrange,
              side: BorderSide(color: fgColor.withValues(alpha: 0.5)),
            ),
            Text(
              "Select All",
              style: TextStyle(color: fgColor.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              "${_dummyUsers.length} Members Total",
              style: TextStyle(color: fgColor.withValues(alpha: 0.5), fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final int crossAxisCount = width > 1000 ? 4 : (width > 700 ? 3 : (width > 450 ? 2 : 1));
            const double spacing = 16.0;
            final double safeWidth = width > 0 ? width : 300;
            final double itemWidth = (safeWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _dummyUsers.map((user) {
                return SizedBox(
                  width: itemWidth,
                  child: _buildUserCard(user, isDark, bgColor, fgColor, cardColor, borderColor),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isDark, Color bgColor, Color fgColor, Color cardColor, Color borderColor) {
    final bool isSelected = _selectedUserIds.contains(user["id"]);
    
    Color statusColor;
    switch (user["status"]) {
      case "Active": statusColor = Colors.green; break;
      case "Pending": statusColor = Colors.orange; break;
      case "Inactive": statusColor = Colors.grey; break;
      default: statusColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.05) : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.5) : borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleUserSelection(user["id"]),
                  activeColor: AppTheme.primaryOrange,
                  side: BorderSide(color: fgColor.withValues(alpha: 0.4)),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: fgColor.withValues(alpha: 0.5)),
                  color: isDark ? const Color(0xFF2C2A29) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) {
                    if (value == "View Profile" || value == "Edit") {
                      _showUserProfileModal(user, isDark, bgColor, fgColor, cardColor, borderColor);
                    }
                  },
                  itemBuilder: (context) => [
                    _buildMenuItem("Edit", Icons.edit_outlined, fgColor),
                    _buildMenuItem("Delete", Icons.delete_outline, Colors.red),
                    _buildMenuItem("Suspend", Icons.pause_circle_outline, Colors.orange),
                    _buildMenuItem("Activate", Icons.check_circle_outline, Colors.green),
                    _buildMenuItem("Reset Password", Icons.lock_reset_outlined, fgColor),
                    _buildMenuItem("View Profile", Icons.person_outline, fgColor),
                    _buildMenuItem("Change Role", Icons.manage_accounts_outlined, fgColor),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.1),
                  child: Text(
                    user["name"].toString().substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user["name"],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fgColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user["role"],
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryOrange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.domain_rounded, size: 16, color: fgColor.withValues(alpha: 0.4)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user["department"],
                          style: TextStyle(fontSize: 13, color: fgColor.withValues(alpha: 0.7)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(user["status"], style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserProfileModal extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isDark;
  final Color bgColor;
  final Color fgColor;
  final Color cardColor;
  final Color borderColor;

  const _UserProfileModal({
    required this.user,
    required this.isDark,
    required this.bgColor,
    required this.fgColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  State<_UserProfileModal> createState() => _UserProfileModalState();
}

class _UserProfileModalState extends State<_UserProfileModal> {
  late Map<String, bool> _permissions;

  @override
  void initState() {
    super.initState();
    _permissions = Map<String, bool>.from(widget.user["permissions"] as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: widget.fgColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.1),
                        child: Text(
                          user["name"].toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user["name"],
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.fgColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${user["role"]} • ${user["department"]}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryOrange),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildBadge("ID: ${user["id"]}", widget.fgColor.withValues(alpha: 0.7), widget.cardColor),
                                const SizedBox(width: 8),
                                _buildBadge(user["status"], user["status"] == "Active" ? Colors.green : (user["status"] == "Pending" ? Colors.orange : Colors.grey), widget.cardColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: widget.fgColor.withValues(alpha: 0.5)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Contact Details
                  Text("Contact Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.fgColor)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.email_outlined, "Email", user["email"], widget.fgColor, verified: user["emailVerified"]),
                        Divider(color: widget.borderColor, height: 24),
                        _buildDetailRow(Icons.phone_outlined, "Phone Number", user["phone"], widget.fgColor, verified: user["phoneVerified"]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Employee Details
                  Text("Employee Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.fgColor)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.person_outline, "Gender", user["gender"], widget.fgColor),
                        Divider(color: widget.borderColor, height: 24),
                        _buildDetailRow(Icons.school_outlined, "Qualification", user["qualification"], widget.fgColor),
                        if (user["license"] != null) ...[
                          Divider(color: widget.borderColor, height: 24),
                          _buildDetailRow(Icons.badge_outlined, "License Number", user["license"], widget.fgColor),
                        ],
                        Divider(color: widget.borderColor, height: 24),
                        _buildDetailRow(Icons.calendar_month_outlined, "Joining Date", user["joiningDate"], widget.fgColor),
                        Divider(color: widget.borderColor, height: 24),
                        _buildDetailRow(Icons.login_outlined, "Last Login", user["lastLogin"], widget.fgColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Permissions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Permissions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.fgColor)),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.save_outlined, size: 16),
                        label: const Text("Save Changes"),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.primaryOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: widget.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.borderColor),
                    ),
                    child: Column(
                      children: _permissions.keys.map((key) {
                        return SwitchListTile(
                          title: Text(key, style: TextStyle(color: widget.fgColor, fontSize: 15, fontWeight: FontWeight.w500)),
                          value: _permissions[key]!,
                          activeColor: AppTheme.primaryOrange,
                          onChanged: (val) {
                            setState(() {
                              _permissions[key] = val;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color fgColor, {bool? verified}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: fgColor.withValues(alpha: 0.5)),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Text(label, style: TextStyle(color: fgColor.withValues(alpha: 0.6), fontSize: 14)),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(color: fgColor, fontSize: 14, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                ),
              ),
              if (verified != null) ...[
                const SizedBox(width: 6),
                Icon(
                  verified ? Icons.verified : Icons.warning_amber_rounded,
                  color: verified ? Colors.blue : Colors.orange,
                  size: 16,
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
