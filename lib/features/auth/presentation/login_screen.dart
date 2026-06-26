import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'clinic_signup_screen.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final GlobalKey? buttonKey;
  final bool hideButton;
  final bool animateFormEntrance;

  const LoginScreen({
    super.key,
    this.buttonKey,
    this.hideButton = false,
    this.animateFormEntrance = false,
  });

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _showFormFields = false;
  late final AnimationController _cardFadeCtrl;
  late final Animation<double> _cardFadeAnim;

  @override
  void initState() {
    super.initState();
    _showFormFields = !widget.animateFormEntrance;
    _cardFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardFadeAnim = CurvedAnimation(
      parent: _cardFadeCtrl,
      curve: Curves.easeOut,
    );
    if (_showFormFields) {
      _cardFadeCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _cardFadeCtrl.dispose();
    super.dispose();
  }

  void revealFormFields() {
    if (!_showFormFields && mounted) {
      setState(() => _showFormFields = true);
      _cardFadeCtrl.forward(from: 0.0);
    }
  }

  Widget _fadeFormSection(Widget child) {
    return Visibility(
      visible: true,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: IgnorePointer(
        ignoring: !_showFormFields,
        child: AnimatedOpacity(
          opacity: _showFormFields ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: child,
        ),
      ),
    );
  }

  Widget _buildCardContent(
    bool isDark,
    Color fgColor, {
    GlobalKey? buttonKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome to MedFliq',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: fgColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Login with your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: fgColor.withValues(alpha: 0.6),
          ),
        ),
        _Field(
          label: 'Email id',
          hint: 'Your Email Id',
          isDark: isDark,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        _Field(
          label: 'Password',
          hint: '••••••••',
          isDark: isDark,
          obscure: true,
          prefixIcon: Icons.lock_outline,
        ),
        const SizedBox(height: 40),
        SizedBox(
          key: buttonKey,
          height: 52,
          child: widget.hideButton
              ? const SizedBox.shrink()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'New clinic? ',
              style: TextStyle(
                fontSize: 13,
                color: fgColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            _HoverLink(
              text: 'Create a clinic account',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClinicSignupScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'MedFliq · Agentic AI Platform for Hospitals and Healthcare',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: fgColor.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  /// During splash: a decoration-free layout slot preserves morph coordinates.
  /// The glass card (blur, fill, border) mounts only once reveal starts.
  Widget _buildLoginCard(bool isDark, Color fgColor) {
    const cardPadding = EdgeInsets.all(32);
    final needsMorphAnchor = widget.animateFormEntrance && widget.hideButton;

    return Visibility(
      visible: true,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (needsMorphAnchor)
            Opacity(
              opacity: 0,
              child: Padding(
                padding: cardPadding,
                child: _buildCardContent(
                  isDark,
                  fgColor,
                  buttonKey: widget.buttonKey,
                ),
              ),
            ),
          if (_showFormFields)
            IgnorePointer(
              ignoring: _cardFadeAnim.value == 0,
              child: FadeTransition(
                opacity: _cardFadeAnim,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      padding: cardPadding,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: _buildCardContent(
                        isDark,
                        fgColor,
                        buttonKey: needsMorphAnchor ? null : widget.buttonKey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final fgColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _fadeFormSection(
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/medfliq_icon.png',
                          width: 80,
                          height: 80,
                          filterQuality: FilterQuality.high,
                          isAntiAlias: true,
                        ),
                        const SizedBox(height: 16),
                        if (isDark)
                          ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              -0.2035, 0.2035, 0, 0, 255,
                              -1.2040, 1.2040, 0, 0, 255,
                              -1.9560, 1.9560, 0, 0, 255,
                              0, 0, 0, 1, 0,
                            ]),
                            child: Image.asset(
                              'assets/images/medfliq_horizontal.png',
                              height: 48,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              isAntiAlias: true,
                            ),
                          )
                        else
                          Image.asset(
                            'assets/images/medfliq_horizontal.png',
                            height: 48,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            isAntiAlias: true,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'AI-NATIVE HOSPITAL INTELLIGENCE',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                            color: fgColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  AnimatedBuilder(
                    animation: _cardFadeAnim,
                    builder: (context, _) => _buildLoginCard(isDark, fgColor),
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

class _Field extends StatefulWidget {
  final String label;
  final String hint;
  final bool isDark;
  final bool obscure;
  final IconData prefixIcon;

  const _Field({
    required this.label,
    required this.hint,
    required this.isDark,
    this.obscure = false,
    required this.prefixIcon,
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
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: _isObscured,
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: labelColor.withValues(alpha: 0.5)),
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: Icon(widget.prefixIcon, color: iconColor, size: 20),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: iconColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
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
              borderSide:
                  const BorderSide(color: AppTheme.primaryOrange, width: 1.8),
            ),
          ),
        ),
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
            fontSize: 13,
            color: _isHovered 
                ? const Color(0xFFE65C00) // Slightly richer/darker orange than primary
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
