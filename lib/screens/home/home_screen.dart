import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:battery_plus/battery_plus.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_overlay.dart';
import '../map/map_screen.dart';
import '../alerts/alerts_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  int _batteryLevel = 100;
  final Battery _battery = Battery();
  late AnimationController _sosCtrl;
  late Animation<double> _sosPulse;

  final _pages = const [
    _DashboardBody(),
    MapScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _sosCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _sosPulse = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _sosCtrl, curve: Curves.easeInOut));
    _loadBattery();

    // Start tracking on home load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().startTracking();
    });
  }

  Future<void> _loadBattery() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) setState(() => _batteryLevel = level);
    } catch (_) {}
  }

  @override
  void dispose() {
    _sosCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _navIndex == 0 ? _buildSOSButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav() {
    context.watch<AppProvider>(); // listen for theme changes
    return BottomNavigationBar(
      currentIndex: _navIndex,
      onTap: (i) => setState(() => _navIndex = i),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded), label: 'Map'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }

  Widget _buildSOSButton() {
    return AnimatedBuilder(
      animation: _sosCtrl,
      builder: (_, child) => Transform.scale(
        scale: _sosPulse.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: const Color(0xFF1F2937),
              title: const Text('🆘 Activate SOS?',
                  style: TextStyle(color: Colors.white)),
              content: const Text(
                  'This will alert your guardian immediately.',
                  style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('YES, ALERT',
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirm == true && mounted) {
            context.read<AppProvider>().triggerSOS();
          }
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.dangerGradient,
            boxShadow: [
              BoxShadow(
                  color: AppTheme.dangerRed.withOpacity(0.6),
                  blurRadius: 30,
                  spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.sos_rounded, color: Colors.white, size: 28),
              Text('SOS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final isDark = provider.isDarkMode;

    return LoadingOverlay(
      isLoading: provider.state == AppState.loading,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A0E1A), const Color(0xFF111827)]
                : [const Color(0xFFEFF6FF), const Color(0xFFDDE9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _HeaderCard(
                    name: user?.name ?? 'User',
                    userType: user?.userType ?? '',
                    isDark: isDark),
                const SizedBox(height: 20),

                // Status Banner
                _StatusBanner(
                  isInside: provider.isInsideSafeZone,
                  distance: provider.distanceFromSafeZone,
                  isTracking: provider.isTracking,
                ),
                const SizedBox(height: 20),

                // Quick Stats Row
                _QuickStats(provider: provider),
                const SizedBox(height: 24),

                // Feature Cards Grid
                Text('Quick Access',
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E293B))),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.1,
                  children: [
                    _FeatureCard(
                      icon: Icons.location_on_rounded,
                      label: 'Live Location',
                      gradient: const [Color(0xFF4F8EF7), Color(0xFF7C3AED)],
                      onTap: () {},
                    ),
                    _FeatureCard(
                      icon: Icons.radar_rounded,
                      label: 'Safe Radius',
                      gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                      onTap: () => Navigator.pushNamed(context, '/guardian-setup'),
                    ),
                    _FeatureCard(
                      icon: Icons.notifications_active_rounded,
                      label: 'Alerts',
                      gradient: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      onTap: () {},
                    ),
                    _FeatureCard(
                      icon: Icons.person_rounded,
                      label: 'Guardian',
                      gradient: const [Color(0xFFEC4899), Color(0xFF7C3AED)],
                      onTap: () => Navigator.pushNamed(context, '/guardian-setup'),
                    ),
                  ],
                ),
                const SizedBox(height: 90), // FAB space
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final String name;
  final String userType;
  final bool isDark;

  const _HeaderCard(
      {required this.name, required this.userType, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $name 👋',
                    style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text(
                    userType.replaceAll('_', ' ').toUpperCase(),
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white70,
                        letterSpacing: 1)),
              ],
            ),
          ),
          const Icon(Icons.notifications_rounded,
              color: Colors.white70, size: 26),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool isInside;
  final double distance;
  final bool isTracking;

  const _StatusBanner(
      {required this.isInside,
      required this.distance,
      required this.isTracking});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isInside ? AppTheme.safeGradient : AppTheme.dangerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color:
                  (isInside ? AppTheme.safeGreen : AppTheme.dangerRed)
                      .withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isInside
                ? Icons.check_circle_rounded
                : Icons.warning_rounded,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isInside ? '✅ Inside Safe Zone' : '⚠️ Outside Safe Zone',
                  style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                Text(
                  isTracking
                      ? isInside
                          ? 'You are within your safe zone'
                          : '${distance.toStringAsFixed(0)}m from center'
                      : 'Tracking is off',
                  style: GoogleFonts.outfit(
                      fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          _TrackingDot(isTracking: isTracking),
        ],
      ),
    );
  }
}

class _TrackingDot extends StatefulWidget {
  final bool isTracking;
  const _TrackingDot({required this.isTracking});

  @override
  State<_TrackingDot> createState() => _TrackingDotState();
}

class _TrackingDotState extends State<_TrackingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.4, end: 1).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTracking) {
      return Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
              color: Colors.white38, shape: BoxShape.circle));
    }
    return FadeTransition(
      opacity: _a,
      child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle)),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final AppProvider provider;
  const _QuickStats({required this.provider});

  @override
  Widget build(BuildContext context) {
    final pos = provider.currentPosition;
    return Row(
      children: [
        _StatChip(
          icon: Icons.gps_fixed_rounded,
          label: pos != null
              ? pos.latitude.toStringAsFixed(4)
              : '---',
          sublabel: 'Latitude',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.notifications_active_rounded,
          label: provider.alerts.length.toString(),
          sublabel: 'Alerts',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.radar_rounded,
          label:
              '${provider.currentUser?.safeRadiusMeters?.toStringAsFixed(0) ?? 500}m',
          sublabel: 'Radius',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const _StatChip(
      {required this.icon, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark
                  ? const Color(0xFF374151)
                  : const Color(0xFFBFDBFE),
              width: 0.8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B))),
            Text(sublabel,
                style: GoogleFonts.outfit(
                    fontSize: 10, color: Colors.grey),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _s = Tween<double>(begin: 1, end: 0.93)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) =>
            Transform.scale(scale: _s.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: widget.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: widget.gradient.first.withOpacity(0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, color: Colors.white, size: 34),
                const Spacer(),
                Text(widget.label,
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
