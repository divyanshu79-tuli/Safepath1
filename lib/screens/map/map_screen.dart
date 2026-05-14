import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _centreOnUser = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final pos = provider.currentPosition;
    final user = provider.currentUser;

    final userLatLng = pos != null
        ? LatLng(pos.latitude, pos.longitude)
        : const LatLng(20.5937, 78.9629); // Default: India centre

    final safeCenter = (user?.safeZoneLat != null && user?.safeZoneLng != null)
        ? LatLng(user!.safeZoneLat!, user.safeZoneLng!)
        : userLatLng;

    final radius = user?.safeRadiusMeters ?? 500.0;

    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLatLng,
              initialZoom: 15.5,
              onPositionChanged: (_, __) {
                if (_centreOnUser) setState(() => _centreOnUser = false);
              },
            ),
            children: [
              // Tile layer – OpenStreetMap
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.safepath.app',
              ),

              // Safe zone circle
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: safeCenter,
                    radius: radius,
                    useRadiusInMeter: true,
                    color: (provider.isInsideSafeZone
                            ? AppTheme.safeGreen
                            : AppTheme.dangerRed)
                        .withOpacity(0.15),
                    borderColor: provider.isInsideSafeZone
                        ? AppTheme.safeGreen
                        : AppTheme.dangerRed,
                    borderStrokeWidth: 2.5,
                  ),
                ],
              ),

              // Markers
              MarkerLayer(
                markers: [
                  // Safe zone centre pin
                  Marker(
                    point: safeCenter,
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.primaryBlue, width: 2),
                      ),
                      child: const Icon(Icons.home_rounded,
                          color: AppTheme.primaryBlue, size: 18),
                    ),
                  ),

                  // Current user location
                  Marker(
                    point: userLatLng,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: provider.isInsideSafeZone
                            ? AppTheme.safeGradient
                            : AppTheme.dangerGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: (provider.isInsideSafeZone
                                      ? AppTheme.safeGreen
                                      : AppTheme.dangerRed)
                                  .withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 3),
                        ],
                      ),
                      child: const Icon(Icons.person_pin_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top info card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _MapInfoCard(provider: provider),
              ),
            ),
          ),

          // Re-centre button
          Positioned(
            right: 16,
            bottom: 100,
            child: GestureDetector(
              onTap: () {
                setState(() => _centreOnUser = true);
                _mapController.move(userLatLng, 15.5);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapInfoCard extends StatelessWidget {
  final AppProvider provider;
  const _MapInfoCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final pos = provider.currentPosition;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xE5111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: (provider.isInsideSafeZone
                    ? AppTheme.safeGreen
                    : AppTheme.dangerRed)
                .withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            provider.isInsideSafeZone
                ? Icons.check_circle_rounded
                : Icons.warning_rounded,
            color: provider.isInsideSafeZone
                ? AppTheme.safeGreen
                : AppTheme.dangerRed,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.isInsideSafeZone
                      ? 'Inside Safe Zone'
                      : 'Outside Safe Zone',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
                if (pos != null)
                  Text(
                    '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
                    style: GoogleFonts.outfit(
                        color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: provider.isInsideSafeZone
                  ? AppTheme.safeGreen.withOpacity(0.2)
                  : AppTheme.dangerRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${(provider.currentUser?.safeRadiusMeters ?? 500).toStringAsFixed(0)}m',
              style: GoogleFonts.outfit(
                  color: provider.isInsideSafeZone
                      ? AppTheme.safeGreen
                      : AppTheme.dangerRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
