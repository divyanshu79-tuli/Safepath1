import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      icon: Icons.shield_rounded,
      gradientColors: [Color(0xFF4F8EF7), Color(0xFF7C3AED)],
      title: 'Smart Safety',
      description:
          'Track and protect disabled users in real time with precision GPS monitoring.',
      badge: '🛡️',
    ),
    _OnboardPage(
      icon: Icons.group_rounded,
      gradientColors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
      title: 'Guardian Monitoring',
      description:
          'Family members receive instant alerts when their loved ones need help.',
      badge: '👨‍👩‍👧',
    ),
    _OnboardPage(
      icon: Icons.accessibility_new_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF4F8EF7)],
      title: 'Accessible Navigation',
      description:
          'Designed for visually and mobility impaired users with voice support.',
      badge: '♿',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _animController.reset();
    _animController.forward();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingDone, true);
    if (mounted) Navigator.pushReplacementNamed(context, '/user-type');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.outfit(
                          color: Colors.white54, fontSize: 15),
                    ),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _buildPage(_pages[i]),
                ),
              ),

              // Dots
              _buildDots(),

              const SizedBox(height: 24),

              // Continue button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GestureDetector(
                  onTap: _next,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Continue',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardPage page) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    LinearGradient(colors: page.gradientColors),
                boxShadow: [
                  BoxShadow(
                    color: page.gradientColors.first.withOpacity(0.4),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(page.badge, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 4),
                  Icon(page.icon, color: Colors.white, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 48),

            Text(
              page.title,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Text(
              page.description,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.white60,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _currentPage ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentPage
                ? AppTheme.primaryBlue
                : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String description;
  final String badge;

  _OnboardPage({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.description,
    required this.badge,
  });
}
