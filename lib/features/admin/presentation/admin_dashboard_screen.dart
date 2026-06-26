import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/login_screen.dart'; 
import 'widgets/overview_tab.dart'; 
import 'widgets/doctor_schedule_tab.dart'; 
import 'widgets/user_management_tab.dart';
import 'widgets/audit_logs_tab.dart';
import 'widgets/profile_tab.dart'; // Add this import

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  // Custom Drawer Animation Controllers
  late AnimationController _drawerController;
  late Animation<double> _drawerSlideAnim;
  late Animation<double> _overlayFadeAnim;

  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _drawerSlideAnim = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeOutCubic),
    );

    _overlayFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _drawerController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleDrawer() {
    if (_isDrawerOpen) {
      _drawerController.reverse().then((_) {
        setState(() {
          _isDrawerOpen = false;
        });
      });
    } else {
      setState(() {
        _isDrawerOpen = true;
      });
      _drawerController.forward();
    }
  }

  void _onDrawerItemTapped(int index) {
    _toggleDrawer();
    // Indices 0-4 correspond to the main dashboard tabs
    if (index < 5) {
      _onTabTapped(index);
    } else if (index == 8) {
      // Logout logic
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1A18) : const Color(0xFFF9F6F0);
    final fgColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Main Content Layer
          Column(
            children: [
              _buildAppBar(isDark, fgColor),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: const [
                    OverviewTab(), // Replaced Placeholder with OverviewTab
                    DoctorScheduleTab(), // Replaced Placeholder with DoctorScheduleTab
                    UserManagementTab(), // Replaced Placeholder with UserManagementTab
                    AuditLogsTab(), // Replaced Placeholder with AuditLogsTab
                    ProfileTab(), // Replaced Placeholder with ProfileTab
                  ],
                ),
              ),
              // Spacing so content isn't hidden behind the floating bottom nav
              const SizedBox(height: 80), 
            ],
          ),

          // 2. Bottom Navigation Layer (Instagram Style)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(isDark, fgColor, bgColor),
          ),

          // 3. Drawer Dim Overlay Layer
          if (_isDrawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleDrawer,
                child: FadeTransition(
                  opacity: _overlayFadeAnim,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),

          // 4. Drawer Menu Slide Layer
          if (_isDrawerOpen)
            AnimatedBuilder(
              animation: _drawerController,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(_drawerSlideAnim.value, 0.0),
                  child: _buildCustomDrawer(isDark, fgColor),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color fgColor) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.menu_rounded, color: fgColor, size: 28),
              onPressed: _toggleDrawer,
            ),
            const SizedBox(width: 8),
            Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: fgColor,
              ),
            ),
            const Spacer(),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.15),
              child: const Icon(Icons.person, color: AppTheme.primaryOrange, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark, Color fgColor, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? bgColor.withValues(alpha: 0.98) : bgColor.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(
            color: fgColor.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.grid_view_rounded, Icons.grid_view_rounded, fgColor),
              _buildBottomNavItem(1, Icons.calendar_today_outlined, Icons.calendar_month_rounded, fgColor),
              _buildBottomNavItem(2, Icons.people_outline_rounded, Icons.people_rounded, fgColor),
              _buildBottomNavItem(3, Icons.list_alt_rounded, Icons.list_alt_rounded, fgColor),
              _buildBottomNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, fgColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData unselectedIcon, IconData selectedIcon, Color fgColor) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? AppTheme.primaryOrange : fgColor.withValues(alpha: 0.4),
          size: 26,
        ),
      ),
    );
  }

  Widget _buildCustomDrawer(bool isDark, Color fgColor) {
    final drawerWidth = MediaQuery.of(context).size.width * 0.8;

    return Container(
      width: drawerWidth,
      height: double.infinity,
      color: isDark ? const Color(0xFF262220) : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/medfliq_icon.png',
                        height: 40,
                        filterQuality: FilterQuality.high,
                        isAntiAlias: true,
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: fgColor.withValues(alpha: 0.5)),
                        onPressed: _toggleDrawer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "ADMINISTRATOR",
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w800, 
                      color: AppTheme.primaryOrange, 
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Admin Name",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: fgColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ABC Multispeciality Hospital",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fgColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            Divider(color: fgColor.withValues(alpha: 0.08), height: 1),
            // Menu Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                children: [
                  _buildDrawerItem(index: 0, icon: Icons.grid_view_rounded, title: "Overview", fgColor: fgColor),
                  _buildDrawerItem(index: 1, icon: Icons.calendar_month_rounded, title: "Doctor Schedule", fgColor: fgColor),
                  _buildDrawerItem(index: 2, icon: Icons.people_rounded, title: "User Management", fgColor: fgColor),
                  _buildDrawerItem(index: 3, icon: Icons.list_alt_rounded, title: "Audit Logs", fgColor: fgColor),
                  _buildDrawerItem(index: 4, icon: Icons.person_rounded, title: "Profile", fgColor: fgColor),
                  const SizedBox(height: 24),
                  Divider(color: fgColor.withValues(alpha: 0.08)),
                  const SizedBox(height: 24),
                  _buildDrawerItem(index: 5, icon: Icons.settings_rounded, title: "Settings", fgColor: fgColor),
                  _buildDrawerItem(index: 6, icon: Icons.help_outline_rounded, title: "Help & Support", fgColor: fgColor),
                  _buildDrawerItem(index: 7, icon: Icons.privacy_tip_outlined, title: "Privacy Policy", fgColor: fgColor),
                  const SizedBox(height: 40),
                  _buildDrawerItem(index: 8, icon: Icons.logout_rounded, title: "Logout", fgColor: fgColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String title,
    required Color fgColor,
  }) {
    // 0-4 are main dashboard tabs, so they share selected state
    final isSelected = index < 5 && _currentIndex == index;

    // Staggered slide/fade animation for each menu item
    final start = (index * 0.05).clamp(0.0, 1.0);
    final end = (start + 0.3).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _drawerController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-30 * (1 - animation.value), 0),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onDrawerItemTapped(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? AppTheme.primaryOrange : fgColor.withValues(alpha: 0.6),
                    size: 22,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? AppTheme.primaryOrange : fgColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder Screen preserving state when swiped
class _PlaceholderScreen extends StatefulWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  State<_PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<_PlaceholderScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keeps state alive when navigating away

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? Colors.white : Colors.black;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 64, color: fgColor.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: fgColor.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 8),
          Text(
            "Screen under construction",
            style: TextStyle(fontSize: 14, color: fgColor.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }
}
