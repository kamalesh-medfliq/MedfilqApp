import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';
import '../providers/auth_provider.dart';

class ClinicSignupScreen extends StatefulWidget {
  const ClinicSignupScreen({super.key});

  @override
  State<ClinicSignupScreen> createState() => _ClinicSignupScreenState();
}

class _ClinicSignupScreenState extends State<ClinicSignupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _nextStep() async {
    // If we are on Step 4 (Password Setup), trigger registration API before going to Welcome screen
    if (_currentStep == 3) {
      final auth = context.read<AuthProvider>();
      final success = await auth.registerClinic(
        firstName: _firstNameController.text.isNotEmpty ? _firstNameController.text : 'Admin',
        lastName: _lastNameController.text.isNotEmpty ? _lastNameController.text : 'User',
        email: _emailController.text.isNotEmpty ? _emailController.text : 'admin@clinic.com',
        password: _passwordController.text.isNotEmpty ? _passwordController.text : 'Password123!',
        clinicName: _clinicNameController.text.isNotEmpty ? _clinicNameController.text : 'My Clinic',
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop and don't go to the next step
      }
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _clinicNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? Colors.white : Colors.black;

    // Background Gradient
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark 
          ? [AppTheme.primaryOrange.withValues(alpha: 0.15), AppTheme.darkBackground]
          : [AppTheme.primaryOrange.withValues(alpha: 0.1), AppTheme.lightBackground],
      stops: const [0.0, 0.4],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Main PageView Container
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable swipe
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildStep1(isDark, fgColor),
                    _buildStep2(isDark, fgColor),
                    _buildStep3(isDark, fgColor),
                    _buildStep4(isDark, fgColor),
                    _buildStep5(isDark, fgColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Wrapper providing the glass effect and scrolling
  Widget _buildStepWrapper({
    required Widget content, 
    required bool isDark, 
    required String title, 
    required String subtitle, 
    required Color fgColor,
    bool centerTitle = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.black.withValues(alpha: 0.3) 
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.05) 
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Attached Scrolling Progress Bar (Task 1)
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      backgroundColor: fgColor.withValues(alpha: 0.05),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                      minHeight: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
                        children: [
                          // Step Number Labels (Task 2)
                          if (title.isNotEmpty) ...[
                            Text(
                              "STEP ${_currentStep + 1} OF $_totalSteps",
                              textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryOrange, letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: fgColor),
                            ),
                          ],
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                              style: TextStyle(fontSize: 15, color: fgColor.withValues(alpha: 0.6)),
                            ),
                          ],
                          SizedBox(height: title.isNotEmpty ? 40 : 0),
                          content,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Task 4: Compact & Unique Bottom Action Area
  Widget _buildBottomActions({required String nextText, required VoidCallback onNext, bool showBack = true, required Color fgColor}) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack && _currentStep > 0)
            TextButton.icon(
              onPressed: _previousStep,
              icon: Icon(Icons.arrow_back, size: 16, color: fgColor.withValues(alpha: 0.5)),
              label: Text(
                "Back", 
                style: TextStyle(color: fgColor.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )
          else
            const SizedBox.shrink(),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onNext,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nextText,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                if (nextText.contains("Next") || nextText.contains("Continue")) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Personal Info ──────────────────────────────────
  Widget _buildStep1(bool isDark, Color fgColor) {
    return _buildStepWrapper(
      isDark: isDark,
      fgColor: fgColor,
      title: "Personal Info",
      subtitle: "Let's get to know you",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Your Name", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fgColor.withValues(alpha: 0.9))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _Field(hint: 'First name', isDark: isDark, prefixIcon: Icons.person_outline, controller: _firstNameController)),
              const SizedBox(width: 16),
              Expanded(child: _Field(hint: 'Last name', isDark: isDark, prefixIcon: Icons.person_outline, controller: _lastNameController)),
            ],
          ),
          const SizedBox(height: 24),
          _Field(label: 'Username', hint: 'Enter username', isDark: isDark, prefixIcon: Icons.alternate_email),
          const SizedBox(height: 24),
          _Field(label: 'Email Address', hint: 'Enter email address', isDark: isDark, prefixIcon: Icons.email_outlined, controller: _emailController),
          const SizedBox(height: 24),
          _Field(label: 'Phone Number', hint: 'Enter phone number', isDark: isDark, prefixIcon: Icons.phone_outlined),
          
          _buildBottomActions(nextText: "Next", onNext: _nextStep, showBack: false, fgColor: fgColor),
        ],
      ),
    );
  }

  // ── Step 2: Clinic/Hospital Details ────────────────────────
  Widget _buildStep2(bool isDark, Color fgColor) {
    return _buildStepWrapper(
      isDark: isDark,
      fgColor: fgColor,
      title: "Clinic Details",
      subtitle: "Tell us about your practice",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(label: 'Clinic or Hospital Name', hint: 'Enter clinic or hospital name', isDark: isDark, prefixIcon: Icons.local_hospital_outlined, controller: _clinicNameController),
          const SizedBox(height: 24),
          _Field(label: 'Registration Number', hint: 'Enter registration/license number', isDark: isDark, prefixIcon: Icons.badge_outlined),
          const SizedBox(height: 24),
          _Field(label: 'GST Number', hint: 'Enter GST number', isDark: isDark, prefixIcon: Icons.receipt_long_outlined),
          const SizedBox(height: 24),
          _Field(label: 'Clinic Type', hint: 'Enter clinic type', isDark: isDark, isDropdown: false, prefixIcon: Icons.category_outlined),
          const SizedBox(height: 24),
          _Field(label: 'Contact Number', hint: 'Enter contact number', isDark: isDark, prefixIcon: Icons.phone_outlined),
          const SizedBox(height: 24),
          _Field(label: 'Email', hint: 'Enter clinic email', isDark: isDark, prefixIcon: Icons.email_outlined),
          const SizedBox(height: 24),
          Text('Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fgColor.withValues(alpha: 0.6))),
          const SizedBox(height: 8),
          CSCPicker(
            showStates: true,
            showCities: true,
            flagState: CountryFlag.DISABLE,
            dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.6),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
            ),
            disabledDropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
            ),
            countrySearchPlaceholder: "Country",
            stateSearchPlaceholder: "State",
            citySearchPlaceholder: "City",
            countryDropdownLabel: "Country",
            stateDropdownLabel: "State",
            cityDropdownLabel: "District/City",
            defaultCountry: CscCountry.India,
            disableCountry: true, // we only want India
            selectedItemStyle: TextStyle(
              color: fgColor,
              fontSize: 14,
            ),
            dropdownHeadingStyle: TextStyle(
              color: fgColor,
              fontSize: 17,
              fontWeight: FontWeight.bold
            ),
            dropdownItemStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
            dropdownDialogRadius: 10.0,
            searchBarRadius: 10.0,
            onCountryChanged: (value) {},
            onStateChanged: (value) {},
            onCityChanged: (value) {},
          ),
          const SizedBox(height: 24),
          _Field(label: 'Full Address', hint: 'Enter full address...', isDark: isDark, maxLines: 3, prefixIcon: Icons.location_on_outlined),
          const SizedBox(height: 24),
          _Field(label: 'Pincode', hint: 'Enter pincode', isDark: isDark, prefixIcon: Icons.pin_drop_outlined),
          
          _buildBottomActions(nextText: "Next", onNext: _nextStep, fgColor: fgColor),
        ],
      ),
    );
  }

  // ── Step 3: Verification ──────────────────────────────────
  Widget _buildStep3(bool isDark, Color fgColor) {
    return _buildStepWrapper(
      isDark: isDark,
      fgColor: fgColor,
      title: "Verify Your Account",
      subtitle: "",
      centerTitle: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline, color: fgColor.withValues(alpha: 0.8), size: 20),
              const SizedBox(width: 8),
              Text(
                "EMAIL OTP",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fgColor.withValues(alpha: 0.8), letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _OtpInputRow(isDark: isDark),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: _HoverLink(
              text: 'Resend OTP',
              onTap: () {},
            ),
          ),
          
          _buildBottomActions(nextText: "Verify & Continue", onNext: _nextStep, fgColor: fgColor),
        ],
      ),
    );
  }

  // ── Step 4: Password Setup ──────────────────────────────────
  Widget _buildStep4(bool isDark, Color fgColor) {
    return _buildStepWrapper(
      isDark: isDark,
      fgColor: fgColor,
      title: "Secure Account",
      subtitle: "",
      content: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return _Step4Content(
            isDark: isDark, 
            fgColor: fgColor, 
            passwordController: _passwordController,
            bottomActions: _buildBottomActions(
              nextText: auth.isLoading ? "Registering..." : "Continue", 
              onNext: auth.isLoading ? () {} : _nextStep, 
              fgColor: fgColor
            ),
          );
        },
      ),
    );
  }

  // ── Step 5: Welcome / Account Ready ──────────────────────────
  Widget _buildStep5(bool isDark, Color fgColor) {
    return _buildStepWrapper(
      isDark: isDark,
      fgColor: fgColor,
      title: "",
      subtitle: "",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/medfliq_icon.png',
            height: 100,
          ),
          const SizedBox(height: 40),
          Text(
            "Welcome to MedFliq!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: fgColor),
          ),
          const SizedBox(height: 20),
          Text(
            "Your enterprise administrator environment has been successfully deployed. MedFliq is an AI-native hospital intelligence platform engineered to streamline clinical workflows, automate medical documentation architectures, and securely manage patient healthcare tracking seamlessly. You are now ready to customize your clinical space.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: fgColor.withValues(alpha: 0.7), height: 1.6),
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
                child: const Text(
                  'Go to Admin Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared UI Components ─────────────────────────────────────

class _Field extends StatefulWidget {
  final String? label;
  final String hint;
  final bool isDark;
  final bool obscure;
  final bool isDropdown;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final TextEditingController? controller;

  const _Field({
    this.label,
    required this.hint,
    required this.isDark,
    this.obscure = false,
    this.isDropdown = false,
    this.maxLines = 1,
    this.onChanged,
    this.prefixIcon,
    this.controller,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
    final labelColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.6);
    final iconColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.4);

    final fillColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: labelColor)),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: widget.controller,
          obscureText: _isObscured,
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: labelColor.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: widget.prefixIcon != null 
                ? Icon(widget.prefixIcon, color: iconColor, size: 20)
                : widget.obscure 
                    ? Icon(Icons.lock_outline, color: iconColor, size: 20)
                    : null,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: iconColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : widget.isDropdown
                    ? Icon(Icons.keyboard_arrow_down, color: iconColor)
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpInputRow extends StatelessWidget {
  final bool isDark;
  
  const _OtpInputRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final fillColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.6);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 60,
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: fillColor,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
              ),
            ),
            onChanged: (value) {
              if (value.length == 1 && index < 5) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  final bool isMet;
  final bool isDark;
  final Color fgColor;

  const _ChecklistItem({
    required this.text, 
    required this.isMet, 
    required this.isDark, 
    required this.fgColor
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? AppTheme.primaryOrange : fgColor.withValues(alpha: 0.3),
          size: 18,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isMet ? AppTheme.primaryOrange : fgColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _Step4Content extends StatefulWidget {
  final bool isDark;
  final Color fgColor;
  final Widget bottomActions;
  final TextEditingController passwordController;

  const _Step4Content({required this.isDark, required this.fgColor, required this.bottomActions, required this.passwordController});

  @override
  State<_Step4Content> createState() => _Step4ContentState();
}

class _Step4ContentState extends State<_Step4Content> {
  String _password = "";

  @override
  Widget build(BuildContext context) {
    bool hasMinLength = _password.length >= 8;
    bool hasUppercase = _password.contains(RegExp(r'[A-Z]'));
    bool hasNumberOrSpecial = _password.contains(RegExp(r'[0-9!@#\$&*~]'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          label: 'Password',
          hint: 'Enter password',
          isDark: widget.isDark,
          obscure: true,
          prefixIcon: Icons.lock_outline,
          controller: widget.passwordController,
          onChanged: (val) => setState(() => _password = val),
        ),
        const SizedBox(height: 24),
        _Field(
          label: 'Confirm Password',
          hint: 'Re-enter password',
          isDark: widget.isDark,
          obscure: true,
          prefixIcon: Icons.lock_outline,
        ),
        const SizedBox(height: 32),
        // Security Checklist Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
            border: Border.all(color: widget.fgColor.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChecklistItem(text: "Minimum 8 characters", isMet: hasMinLength, isDark: widget.isDark, fgColor: widget.fgColor),
              const SizedBox(height: 12),
              _ChecklistItem(text: "One uppercase letter", isMet: hasUppercase, isDark: widget.isDark, fgColor: widget.fgColor),
              const SizedBox(height: 12),
              _ChecklistItem(text: "One number or special character", isMet: hasNumberOrSpecial, isDark: widget.isDark, fgColor: widget.fgColor),
            ],
          ),
        ),
        widget.bottomActions,
      ],
    );
  }
}

class _HoverLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _HoverLink({
    required this.text,
    required this.onTap,
  });

  @override
  State<_HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<_HoverLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 14,
            color: _isHovered 
                ? const Color(0xFFE65C00) // Richer color
                : AppTheme.primaryOrange,
            fontWeight: FontWeight.w600,
            decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
            decorationColor: const Color(0xFFE65C00),
          ),
        ),
      ),
    );
  }
}
