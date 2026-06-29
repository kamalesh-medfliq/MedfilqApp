import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final Set<String> _selectedUserIds = {};
  bool _isBulkMode = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await ApiClient().dio.get('/users');
      final List<dynamic> data = response.data;
      
      setState(() {
        _users = data.map((user) {
          return {
            "id": user['id'],
            "name": "${user['firstName']} ${user['lastName']}",
            "role": user['role'] ?? "N/A",
            "department": user['department'] ?? "N/A",
            "status": user['status'] != null 
                ? "${user['status'].toString()[0].toUpperCase()}${user['status'].toString().substring(1).toLowerCase()}" 
                : "Pending",
            "email": user['email'],
            "phone": user['phone'] ?? "N/A",
            "gender": "Not Specified",
            "qualification": "N/A",
            "license": null,
            "joiningDate": user['createdAt'] != null ? user['createdAt'].toString().substring(0, 10) : "N/A",
            "lastLogin": "N/A",
            "emailVerified": true,
            "phoneVerified": false,
            "permissions": user['permissions'] ?? {}
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }



  void _toggleUserSelection(String id) {
    setState(() {
      if (_selectedUserIds.contains(id)) {
        _selectedUserIds.remove(id);
        if (_selectedUserIds.isEmpty) _isBulkMode = false;
      } else {
        _selectedUserIds.add(id);
      }
    });
  }

  void _enableBulkMode(String id) {
    setState(() {
      _isBulkMode = true;
      _selectedUserIds.add(id);
    });
  }

  void _toggleAllSelection(bool? value) {
    setState(() {
      if (value == true) {
        _selectedUserIds.addAll(_users.map((e) => e["id"] as String));
      } else {
        _selectedUserIds.clear();
        _isBulkMode = false;
      }
    });
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

  void _showAddStaffModal(bool isDark, Color bgColor, Color fgColor, Color cardColor, Color borderColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddStaffModal(
        isDark: isDark, 
        bgColor: bgColor, 
        fgColor: fgColor, 
        cardColor: cardColor, 
        borderColor: borderColor,
        onSuccess: () {
          _showSnackBar("New staff member added successfully");
          setState(() { _isLoading = true; });
          _fetchUsers();
        },
      ),
    );
  }

  void _showEditStaffModal(Map<String, dynamic> user, bool isDark, Color bgColor, Color fgColor, Color cardColor, Color borderColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditStaffModal(
        user: user,
        isDark: isDark, 
        bgColor: bgColor, 
        fgColor: fgColor, 
        cardColor: cardColor, 
        borderColor: borderColor,
        onSuccess: () {
          _showSnackBar("Staff member updated successfully");
          setState(() { _isLoading = true; });
          _fetchUsers();
        },
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
      body: RefreshIndicator(
        onRefresh: _fetchUsers,
        color: AppTheme.primaryOrange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Top Bar
              _buildTopBar(isDark, cardColor, borderColor, fgColor),
              const SizedBox(height: 24),
              
              // Section 2: User Cards
              _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _buildUserCards(isDark, bgColor, fgColor, cardColor, borderColor),
              
              const SizedBox(height: 80),
            ],
          ),
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
            Text("Staff Directory", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fgColor)),
            ElevatedButton.icon(
              onPressed: () => _showAddStaffModal(isDark, const Color(0xFFF9F6F0), fgColor, cardColor, borderColor),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add Staff", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final bool allSelected = _selectedUserIds.length == _users.length && _users.isNotEmpty;

    return Column(
      children: [
        if (_isBulkMode)
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
                "${_selectedUserIds.length} Selected",
                style: const TextStyle(color: AppTheme.primaryOrange, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Text(
                "${_users.length} Staff Total",
                style: TextStyle(color: fgColor.withValues(alpha: 0.5), fontSize: 13),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "${_users.length} Staff Total",
                style: TextStyle(color: fgColor.withValues(alpha: 0.5), fontSize: 13),
              ),
            ],
          ),
        const SizedBox(height: 12),
        if (_users.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 64, color: fgColor.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    "No records found",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: fgColor.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          )
        else
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
              children: _users.map((user) {
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

    return GestureDetector(
      onLongPress: () {
        if (!_isBulkMode) {
          _enableBulkMode(user["id"]);
        }
      },
      onTap: () {
        if (_isBulkMode) {
          _toggleUserSelection(user["id"]);
        }
      },
      child: Container(
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
                  if (_isBulkMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleUserSelection(user["id"]),
                      activeColor: AppTheme.primaryOrange,
                      side: BorderSide(color: fgColor.withValues(alpha: 0.4)),
                    )
                  else
                    const SizedBox(width: 48, height: 48),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: fgColor.withValues(alpha: 0.5)),
                  color: isDark ? const Color(0xFF2C2A29) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) async {
                    if (value == "View Profile") {
                      _showUserProfileModal(user, isDark, bgColor, fgColor, cardColor, borderColor);
                    } else if (value == "Edit") {
                      _showEditStaffModal(user, isDark, bgColor, fgColor, cardColor, borderColor);
                    } else if (value == "Delete") {
                      try {
                        setState(() => _isLoading = true);
                        await ApiClient().dio.delete('/users/${user["id"]}');
                        _showSnackBar("User deleted successfully");
                        _fetchUsers();
                      } catch (e) {
                        _showSnackBar("Failed to delete user: $e");
                        setState(() => _isLoading = false);
                      }
                    } else if (value == "Suspend") {
                      try {
                        setState(() => _isLoading = true);
                        await ApiClient().dio.patch('/users/${user["id"]}/status', data: {"status": "SUSPENDED"});
                        _showSnackBar("User suspended successfully");
                        _fetchUsers();
                      } catch (e) {
                        _showSnackBar("Failed to suspend user: $e");
                        setState(() => _isLoading = false);
                      }
                    } else if (value == "Activate") {
                      try {
                        setState(() => _isLoading = true);
                        await ApiClient().dio.patch('/users/${user["id"]}/status', data: {"status": "ACTIVE"});
                        _showSnackBar("User activated successfully");
                        _fetchUsers();
                      } catch (e) {
                        _showSnackBar("Failed to activate user: $e");
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    _buildMenuItem("Edit", Icons.edit_outlined, fgColor),
                    _buildMenuItem("Delete", Icons.delete_outline, Colors.red),
                    _buildMenuItem("Suspend", Icons.pause_circle_outline, Colors.orange),
                    _buildMenuItem("Activate", Icons.check_circle_outline, Colors.green),
                    _buildMenuItem("Reset Password", Icons.lock_reset_outlined, fgColor),
                    _buildMenuItem("View Profile", Icons.person_outline, fgColor),
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
    ));
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

class _AddStaffModal extends StatefulWidget {
  final bool isDark;
  final Color bgColor;
  final Color fgColor;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback? onSuccess;

  const _AddStaffModal({
    required this.isDark,
    required this.bgColor,
    required this.fgColor,
    required this.cardColor,
    required this.borderColor,
    this.onSuccess,
  });

  @override
  State<_AddStaffModal> createState() => _AddStaffModalState();
}

class _AddStaffModalState extends State<_AddStaffModal> {
  String _selectedRole = 'DOCTOR';
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiClient().dio.post('/users', data: {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
      });
      
      if (mounted) {
        Navigator.pop(context);
        if (widget.onSuccess != null) widget.onSuccess!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add user: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Add Staff", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.fgColor)),
                  IconButton(
                    icon: Icon(Icons.close, color: widget.fgColor.withValues(alpha: 0.5)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildField("First Name", "First name", Icons.person_outline, controller: _firstNameController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField("Last Name", "Last name", Icons.person_outline, controller: _lastNameController)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField("Phone Number", "Enter phone (optional)", Icons.phone_outlined, controller: _phoneController),
              const SizedBox(height: 16),
              _buildField("Email Address", "Enter email", Icons.email_outlined, controller: _emailController),
              const SizedBox(height: 16),
              Text("Role", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: widget.fgColor.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: _inputDecoration("Select role"),
                dropdownColor: widget.cardColor,
                items: [
                  const DropdownMenuItem(value: "DOCTOR", child: Text("Doctor")),
                  const DropdownMenuItem(value: "NURSE", child: Text("Nurse")),
                  const DropdownMenuItem(value: "CLINIC_ADMIN", child: Text("Administrator")),
                  const DropdownMenuItem(value: "RECEPTIONIST", child: Text("Receptionist")),
                ].map((item) {
                  return DropdownMenuItem<String>(
                    value: item.value,
                    child: Text((item.child as Text).data!, style: TextStyle(color: widget.fgColor)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 16),
              _buildField("Password", "Create password", Icons.lock_outline, obscure: _obscurePassword, controller: _passwordController, onToggleObscure: () {
                setState(() => _obscurePassword = !_obscurePassword);
              }),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Add Staff", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, {bool obscure = false, TextEditingController? controller, VoidCallback? onToggleObscure}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: widget.fgColor.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: widget.fgColor, fontSize: 15),
          decoration: _inputDecoration(hint).copyWith(
            prefixIcon: Icon(icon, color: widget.fgColor.withValues(alpha: 0.4), size: 20),
            suffixIcon: onToggleObscure != null 
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: widget.fgColor.withValues(alpha: 0.4), size: 20),
                  onPressed: onToggleObscure,
                )
              : null,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: widget.fgColor.withValues(alpha: 0.4)),
      filled: true,
      fillColor: widget.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryOrange)),
    );
  }
}

class _EditStaffModal extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isDark;
  final Color bgColor;
  final Color fgColor;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback? onSuccess;

  const _EditStaffModal({
    required this.user,
    required this.isDark,
    required this.bgColor,
    required this.fgColor,
    required this.cardColor,
    required this.borderColor,
    this.onSuccess,
  });

  @override
  State<_EditStaffModal> createState() => _EditStaffModalState();
}

class _EditStaffModalState extends State<_EditStaffModal> {
  late String _selectedRole;
  bool _isSubmitting = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final nameParts = widget.user['name'].toString().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _phoneController = TextEditingController(text: widget.user['phone'] ?? '');
    
    String roleStr = widget.user['role'].toString().toUpperCase();
    if (roleStr == "ADMINISTRATOR") roleStr = "CLINIC_ADMIN";
    
    if (["DOCTOR", "NURSE", "CLINIC_ADMIN", "RECEPTIONIST"].contains(roleStr)) {
      _selectedRole = roleStr;
    } else {
      _selectedRole = "DOCTOR";
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiClient().dio.put('/users/${widget.user["id"]}', data: {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
      });
      
      if (mounted) {
        Navigator.pop(context);
        if (widget.onSuccess != null) widget.onSuccess!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update user: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Edit Staff", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.fgColor)),
                  IconButton(
                    icon: Icon(Icons.close, color: widget.fgColor.withValues(alpha: 0.5)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildField("First Name", "First name", Icons.person_outline, controller: _firstNameController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField("Last Name", "Last name", Icons.person_outline, controller: _lastNameController)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField("Phone Number", "Enter phone", Icons.phone_outlined, controller: _phoneController),
              const SizedBox(height: 16),
              Text("Role", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: widget.fgColor.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: _inputDecoration("Select role"),
                dropdownColor: widget.cardColor,
                items: [
                  const DropdownMenuItem(value: "DOCTOR", child: Text("Doctor")),
                  const DropdownMenuItem(value: "NURSE", child: Text("Nurse")),
                  const DropdownMenuItem(value: "CLINIC_ADMIN", child: Text("Administrator")),
                  const DropdownMenuItem(value: "RECEPTIONIST", child: Text("Receptionist")),
                ].map((item) {
                  return DropdownMenuItem<String>(
                    value: item.value,
                    child: Text((item.child as Text).data!, style: TextStyle(color: widget.fgColor)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: widget.fgColor.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: widget.fgColor, fontSize: 15),
          decoration: _inputDecoration(hint).copyWith(
            prefixIcon: Icon(icon, color: widget.fgColor.withValues(alpha: 0.4), size: 20),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: widget.fgColor.withValues(alpha: 0.4)),
      filled: true,
      fillColor: widget.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryOrange)),
    );
  }
}

