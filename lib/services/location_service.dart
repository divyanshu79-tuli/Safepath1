import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/firestore_service.dart';

/// Handles GPS location tracking and safe-radius monitoring
class LocationService {
  final FirestoreService _firestore = FirestoreService();

  StreamSubscription<Position>? _positionSub;
  Position? _lastPosition;

  Position? get lastPosition => _lastPosition;

  // ─── Permissions ─────────────────────────────────────────────
  Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // ─── Single fetch ─────────────────────────────────────────────
  Future<Position?> getCurrentPosition() async {
    try {
      final enabled = await isLocationServiceEnabled();
      if (!enabled) return null;
      final granted = await requestPermissions();
      if (!granted) return null;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _lastPosition = pos;
      return pos;
    } catch (e) {
      debugPrint('LocationService.getCurrentPosition error: $e');
      return null;
    }
  }

  // ─── Continuous stream ────────────────────────────────────────
  void startTracking({
    required String userId,
    required Function(Position, bool) onUpdate,
    required double safeZoneLat,
    required double safeZoneLng,
    required double safeRadiusMeters,
  }) {
    _positionSub?.cancel();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // update every 10 metres
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) async {
      _lastPosition = pos;

      final dist = calculateDistance(
        pos.latitude, pos.longitude, safeZoneLat, safeZoneLng);
      final inside = dist <= safeRadiusMeters;

      final model = LocationModel(
        userId: userId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        speed: pos.speed,
        altitude: pos.altitude,
        timestamp: DateTime.now(),
        isInsideSafeZone: inside,
      );

      await _firestore.saveLocation(model);
      onUpdate(pos, inside);
    });
  }

  void stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  // ─── Haversine distance (metres) ─────────────────────────────
  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // Earth radius in metres
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;
}
