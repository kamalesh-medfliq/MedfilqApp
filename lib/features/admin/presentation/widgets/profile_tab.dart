import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart'; // To access themeNotifier

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _is2FAEnabled = false;
  bool _notificationsEnabled = true;

  Future<void> _setTheme(ThemeMode mode, int index) async {
    themeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', index);
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
            Text("Settings & Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: fgColor)),
            const SizedBox(height: 24),

            // Card 1: Personal Information
            _buildSectionCard(
              title: "Personal Information",
              isDark: isDark, cardColor: cardColor, borderColor: borderColor, fgColor: fgColor,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildProfilePhoto(cardColor, borderColor, fgColor),
                    const SizedBox(height: 32),
                    _buildTextField("Full Name", "Administrator", cardColor, borderColor, fgColor),
                    const SizedBox(height: 16),
                    _buildTextField("Designation", "Chief Administrator", cardColor, borderColor, fgColor),
                    const SizedBox(height: 16),
                    _buildTextField("Clinic/Hospital Name", "ABC Multispeciality Hospital", cardColor, borderColor, fgColor),
                    const SizedBox(height: 16),
                    _buildTextField("Email", "admin@hospital.com", cardColor, borderColor, fgColor),
                    const SizedBox(height: 16),
                    _buildTextField("Phone Number", "+1 555-0199", cardColor, borderColor, fgColor),
                    const SizedBox(height: 16),
                    _buildTextField("Address", "123 Healthcare Ave\nMedical District\nNew York, NY 10001", cardColor, borderColor, fgColor, maxLines: 3),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Card 2: Verification
            _buildSectionCard(
              title: "Verification",
              isDark: isDark, cardColor: cardColor, borderColor: borderColor, fgColor: fgColor,
              child: Column(
                children: [
                  _buildVerificationTile("Phone Number", "Unverified", Icons.phone_android_outlined, fgColor,
                    action: TextButton(
                      onPressed: () {},
                      child: const Text("Verify via OTP", style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Divider(color: borderColor, height: 1),
                  _buildVerificationTile("Email Address", "Verified", Icons.email_outlined, fgColor,
                    isVerified: true,
                    action: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Verified ", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                          Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: borderColor, height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text("Two-Factor Authentication (2FA)", style: TextStyle(color: fgColor, fontSize: 15, fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("Add an extra layer of security", style: TextStyle(color: fgColor.withValues(alpha: 0.5), fontSize: 13)),
                    ),
                    value: _is2FAEnabled,
                    activeColor: AppTheme.primaryOrange,
                    onChanged: (val) => setState(() => _is2FAEnabled = val),
                    secondary: Icon(Icons.security_outlined, color: fgColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card 3: Security
            _buildSectionCard(
              title: "Security",
              isDark: isDark, cardColor: cardColor, borderColor: borderColor, fgColor: fgColor,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(Icons.lock_outline, color: fgColor.withValues(alpha: 0.6)),
                    title: Text("Change Password", style: TextStyle(color: fgColor, fontSize: 15, fontWeight: FontWeight.w600)),
                    trailing: Icon(Icons.chevron_right, color: fgColor.withValues(alpha: 0.4)),
                    onTap: () {},
                  ),
                  Divider(color: borderColor, height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(Icons.devices_outlined, color: fgColor.withValues(alpha: 0.6)),
                    title: Text("View Active Devices", style: TextStyle(color: fgColor, fontSize: 15, fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("2 sessions currently active", style: TextStyle(color: fgColor.withValues(alpha: 0.5), fontSize: 13)),
                    ),
                    trailing: Icon(Icons.chevron_right, color: fgColor.withValues(alpha: 0.4)),
                    onTap: () {},
                  ),
                  Divider(color: borderColor, height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const Icon(Icons.logout_rounded, color: Colors.red),
                    title: const Text("Logout All Devices", style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w600)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card 4: Preferences
            _buildSectionCard(
              title: "Preferences",
              isDark: isDark, cardColor: cardColor, borderColor: borderColor, fgColor: fgColor,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(Icons.palette_outlined, color: fgColor.withValues(alpha: 0.6)),
                    title: Text("Theme Preferences", style: TextStyle(color: fgColor, fontSize: 15, fontWeight: FontWeight.w600)),
                    trailing: ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, currentMode, _) {
                        String currentLabel = "System Default";
                        if (currentMode == ThemeMode.light) currentLabel = "Light";
                        if (currentMode == ThemeMode.dark) currentLabel = "Dark";
                        
                        return PopupMenuButton<int>(
                          initialValue: currentMode == ThemeMode.light ? 1 : (currentMode == ThemeMode.dark ? 2 : 0),
                          onSelected: (val) {
                            if (val == 0) _setTheme(ThemeMode.system, 0);
                            else if (val == 1) _setTheme(ThemeMode.light, 1);
                            else if (val == 2) _setTheme(ThemeMode.dark, 2);
                          },
                          color: isDark ? const Color(0xFF2C2A29) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(currentLabel, style: TextStyle(color: fgColor.withValues(alpha: 0.6), fontSize: 14)),
                              const SizedBox(width: 8),
                              Icon(Icons.keyboard_arrow_down, color: fgColor.withValues(alpha: 0.4)),
                            ],
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 0, child: Text("System Default", style: TextStyle(color: fgColor))),
                            PopupMenuItem(value: 1, child: Text("Light", style: TextStyle(color: fgColor))),
                            PopupMenuItem(value: 2, child: Text("Dark", style: TextStyle(color: fgColor))),
                          ],
                        );
                      }
                    ),
                  ),
                  Divider(color: borderColor, height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(Icons.language_outlined, color: fgColor.withValues(alpha: 0.6)),
                    title: Text("Language", style: TextStyle(color: fgColor, fontSize: 15, fontWeight: FontWeight.w600)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("English (US)", style: TextStyle(color: fgColor.withValues(alpha: 0.6), fontSize: 14)),
                        const SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down, color: fgColor.withValues(alpha: 0.4)),
                      ],
                    ),
                    onTap: () {},
                  ),
                  Divider(color: borderColor, height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text("Notification Settings", style: TextStyle(color: fgColor, fontSize: 15, fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("Global alerts & sounds", style: TextStyle(color: fgColor.withValues(alpha: 0.5), fontSize: 13)),
                    ),
                    value: _notificationsEnabled,
                    activeColor: AppTheme.primaryOrange,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                    secondary: Icon(Icons.notifications_none_rounded, color: fgColor.withValues(alpha: 0.6)),
                  ),
                  Divider(color: borderColor, height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(Icons.access_time_outlined, color: fgColor.withValues(alpha: 0.6)),
                    title: Text("Time Zone", style: TextStyle(color: fgColor, fontSize: 15, fontWeight: FontWeight.w600)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("UTC+05:30", style: TextStyle(color: fgColor.withValues(alpha: 0.6), fontSize: 14)),
                        const SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down, color: fgColor.withValues(alpha: 0.4)),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // Bottom nav padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child, required bool isDark, required Color cardColor, required Color borderColor, required Color fgColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: fgColor)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto(Color cardColor, Color borderColor, Color fgColor) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardColor,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.1),
              child: const Text(
                "A",
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryOrange,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Color cardColor, Color borderColor, Color fgColor, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fgColor.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          style: TextStyle(color: fgColor, fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryOrange)),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationTile(String title, String status, IconData icon, Color fgColor, {Widget? action, bool isVerified = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: fgColor.withValues(alpha: 0.6)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: fgColor, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(color: fgColor.withValues(alpha: 0.5), fontSize: 13)),
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}
