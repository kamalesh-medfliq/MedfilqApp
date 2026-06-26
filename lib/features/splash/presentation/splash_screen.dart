import 'package:flutter/material.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../core/theme/app_theme.dart';

// ─── Asset paths (clean PNG – works on Web + all native platforms) ───────────
const String _kIconAsset       = 'assets/images/medfliq_icon.png';
const String _kHorizontalAsset = 'assets/images/medfliq_horizontal.png';

// ─── Dot size ─────────────────────────────────────────────────────────────────
const double _kDotRadius = 14.0;

// ─────────────────────────────────────────────────────────────────────────────
// Animation Timeline  (total 5 800 ms)
//
//  Phase 1  Zoom out icon          0 ms  → 1 100 ms   (0.000 → 0.190)
//  Phase 2  Reveal text          700 ms  → 1 800 ms   (0.121 → 0.310)
//  Hold                        1 800 ms  → 2 800 ms   (0.310 → 0.483)
//  Phase 3a Hide text          2 800 ms  → 3 600 ms   (0.483 → 0.621)
//  Phase 3c Morph icon → dot   3 800 ms  → 4 100 ms   (0.655 → 0.707)
//  Phase 4a Drop to button pos 4 100 ms  → 4 800 ms   (0.707 → 0.828)
//  Phase 4b Morph to button    4 800 ms  → 5 200 ms   (0.828 → 0.897)
//  Phase 4c Form fade-in       5 200 ms  → 5 600 ms   (triggered on 4b end)
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Phase 1 – icon scales from 3.2× down to 1.0×
  late final Animation<double> _iconScale;

  // Phase 2 – ClipRect widthFactor opens text slot
  late final Animation<double> _textReveal;

  // Phase 3a – ClipRect widthFactor closes text slot
  late final Animation<double> _textHide;

  // Phase 3c – cross-fade from icon to dot  (0 = icon, 1 = dot)
  late final Animation<double> _morphToDot;

  // Phase 4b – button expansion; onEnd triggers LoginScreen form fade-in
  late final Animation<double> _buttonExpand;

  // To find exactly where the button lives on the LoginScreen
  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey<LoginScreenState> _loginKey = GlobalKey<LoginScreenState>();
  Offset? _targetButtonOffset;
  Size? _targetButtonSize;
  bool _formRevealTriggered = false;
  bool _showMorphButtonLabel = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5800),
    );

    _iconScale = Tween<double>(begin: 3.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.000, 0.190, curve: Curves.easeInOutCubic),
      ),
    );

    _textReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.121, 0.310, curve: Curves.fastOutSlowIn),
      ),
    );

    _textHide = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.483, 0.621, curve: Curves.fastOutSlowIn),
      ),
    );

    _morphToDot = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.655, 0.707, curve: Curves.easeInOut),
      ),
    );

    _buttonExpand = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.828, 0.897, curve: Curves.easeOut),
      ),
    );

    _ctrl.addListener(_onMasterTick);

    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onMasterTick);
    _ctrl.dispose();
    super.dispose();
  }

  void _onMasterTick() {
    if (_formRevealTriggered || _ctrl.value < 0.897) return;
    _formRevealTriggered = true;
    _loginKey.currentState?.revealFormFields();
    if (mounted) {
      setState(() => _showMorphButtonLabel = true);
    }
  }

  // Text widthFactor: grows → holds → shrinks
  double get _textWidthFactor {
    final t = _ctrl.value;
    if (t <= 0.310) return _textReveal.value;
    if (t <= 0.483) return 1.0; // hold
    return _textHide.value;
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        // ── Phase 1-3 Lockup Values ───────────────────────────────────────
        final double iconDrawScale = _iconScale.value * (1.0 - _morphToDot.value);
        final double dotOpacity    = _morphToDot.value;

        // ── Phase 4 Overlay Values ────────────────────────────────────────
        final bool showLockup = _ctrl.value <= 0.707;
        final bool showPhase4 = _ctrl.value > 0.707;

        double morphWidth  = _kDotRadius * 2;
        double morphHeight = _kDotRadius * 2;
        double morphX      = size.width / 2 - _kDotRadius;
        double morphY      = size.height / 2 - _kDotRadius;

        if (showPhase4) {
          // Compute target precisely from the LoginScreen's hidden layout
          if (_targetButtonOffset == null) {
            final rb = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
            if (rb != null) {
              _targetButtonOffset = rb.localToGlobal(Offset.zero);
              _targetButtonSize = rb.size;
            }
          }

          final t = _ctrl.value;
          final targetY = _targetButtonOffset?.dy ?? (size.height / 2 + 175);
          final targetW = _targetButtonSize?.width ?? (size.width - 64);
          final targetH = _targetButtonSize?.height ?? 52.0;

          // Phase 4a: Drop (0.707 -> 0.828)
          if (t <= 0.828) {
            double p = (t - 0.707) / (0.828 - 0.707);
            p = Curves.easeInOutQuart.transform(p);
            
            double startY = size.height / 2 - _kDotRadius;
            double endY   = targetY + (targetH / 2) - _kDotRadius; // Target is the vertical center of the button
            
            morphY = startY + (endY - startY) * p;
            morphX = size.width / 2 - _kDotRadius;
          } 
          // Phase 4b: Expand to button shape (0.828 -> 0.897)
          else {
            final p = _buttonExpand.value;

            double centerY = targetY + (targetH / 2);

            morphWidth  = 28.0 + (targetW - 28.0) * p;
            morphHeight = 28.0 + (targetH - 28.0) * p;
            
            morphX = (size.width - morphWidth) / 2;
            morphY = centerY - (morphHeight / 2);
          }
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Layer 1: LoginScreen ──────────────────────────────────────
            // Always in the tree to provide the correct background color and 
            // allow us to measure the button's exact coordinates. Its internal
            // elements are staggered-faded in during Phase 4c.
            LoginScreen(
              key: _loginKey,
              buttonKey: _buttonKey,
              animateFormEntrance: true,
              hideButton: _ctrl.value < 1.0,
            ),

            // ── Layer 2: Animated Logo Lockup (Phases 1-3) ────────────────
            if (showLockup)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon / dot stack (tight bounding box to reduce gap)
                    SizedBox(
                      width: 68, height: 80,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // ── Icon (fades out as morph completes) ────
                          if (iconDrawScale > 0.002)
                            Transform.scale(
                              scale: iconDrawScale,
                              child: Image.asset(
                                _kIconAsset,
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                isAntiAlias: true,
                              ),
                            ),

                          // ── Orange dot (fades in as morph completes)
                          if (dotOpacity > 0.002)
                            Opacity(
                              opacity: dotOpacity,
                              child: Container(
                                width:  _kDotRadius * 2,
                                height: _kDotRadius * 2,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Text wordmark: ClipRect grows the slot width
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: _textWidthFactor,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: _buildWordmark(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Layer 3: Phase 4 Hero Morph (The Dot -> Button) ───────────
            if (showPhase4)
              Positioned(
                left: morphX,
                top: morphY,
                child: Container(
                  width: morphWidth,
                  height: morphHeight,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _showMorphButtonLabel ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Wordmark image ─────────────────────────────────────────────────────────
  // Light mode → PNG as-is:  black MED + orange FLIQ ✓
  // Dark  mode → Custom ColorFilter.matrix:
  Widget _buildWordmark(bool isDark) {
    final Widget img = Image.asset(
      _kHorizontalAsset,
      height: 56, // Increased height
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );

    if (!isDark) return img;

    // Selective invert: black→white, orange→orange (FLIQ stays orange!)
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.2035, 0.2035,  0,  0,  255,
        -1.2040, 1.2040,  0,  0,  255,
        -1.9560, 1.9560,  0,  0,  255,
         0,      0,       0,  1,    0,
      ]),
      child: img,
    );
  }
}
