import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn));
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _pulse = Tween<double>(begin: 1.0, end: 1.12).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _logoController.forward().then((_) => _textController.forward());

    Future.delayed(Duration(seconds: AppConstants.splashDurationSeconds), () {
      if (mounted) _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone =
        prefs.getBool(AppConstants.prefOnboardingDone) ?? false;
    if (!mounted) return;
    if (onboardingDone) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E1A), Color(0xFF1a1040), Color(0xFF0A0E1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background orbs
            Positioned(
              top: -80,
              right: -80,
              child: _buildOrb(200, AppTheme.primaryPurple.withOpacity(0.18)),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: _buildOrb(180, AppTheme.primaryBlue.withOpacity(0.15)),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_logoController, _pulseController]),
                    builder: (_, __) => Transform.scale(
                      scale: _logoScale.value * _pulse.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: _buildLogo(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // App name
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (_, __) => Opacity(
                      opacity: _textOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: Column(
                          children: [
                            Text(
                              AppConstants.appName,
                              style: GoogleFonts.outfit(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppConstants.appTagline,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: Colors.white54,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Loading dots
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                          3,
                          (i) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Opacity(
                                  opacity: i == 0
                                      ? _pulse.value - 0.5
                                      : i == 1
                                          ? 0.7
                                          : 1.6 - _pulse.value,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.shield_rounded, color: Colors.white, size: 56),
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
