import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_provider.dart';
import '../../models/alert_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<AppProvider>().loadAlerts());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final alerts = provider.alerts;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: provider.isDarkMode
              ? [const Color(0xFF0A0E1A), const Color(0xFF111827)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDDE9FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text('Alerts',
                      style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: provider.isDarkMode
                              ? Colors.white
                              : const Color(0xFF1E293B))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.dangerGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${alerts.length}',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            // Alert list
            Expanded(
              child: alerts.isEmpty
                  ? _EmptyAlerts(isDark: provider.isDarkMode)
                  : RefreshIndicator(
                      onRefresh: provider.loadAlerts,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: alerts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _AlertCard(alert: alerts[i], isDark: provider.isDarkMode),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  final bool isDark;

  const _AlertCard({required this.alert, required this.isDark});

  Color get _color => alert.alertType == AppConstants.alertTypeEmergency
      ? AppTheme.dangerRed
      : alert.alertType == AppConstants.alertTypeRadius
          ? AppTheme.warningOrange
          : AppTheme.primaryBlue;

  IconData get _icon => alert.alertType == AppConstants.alertTypeEmergency
      ? Icons.sos_rounded
      : alert.alertType == AppConstants.alertTypeRadius
          ? Icons.warning_rounded
          : Icons.notifications_rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: _color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: _color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.title,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B))),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a')
                          .format(alert.timestamp),
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(alert.message,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54)),
          if (alert.distanceOutside != null) ...[
            const SizedBox(height: 6),
            Text(
              '📍 ${alert.distanceOutside!.toStringAsFixed(0)}m outside radius',
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: _color,
                  fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(alert.googleMapsLink);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            child: Text(
              '📍 View on Google Maps',
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppTheme.primaryBlue,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  final bool isDark;
  const _EmptyAlerts({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 80,
              color: isDark ? Colors.white24 : Colors.black12),
          const SizedBox(height: 16),
          Text('No Alerts',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.black38)),
          Text('All clear! You are safe.',
              style: GoogleFonts.outfit(color: Colors.grey)),
        ],
      ),
    );
  }
}
