import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

/// Sends emergency email alerts via EmailJS REST API
class EmailService {
  /// Send emergency alert email to guardian
  static Future<bool> sendEmergencyAlert({
    required String userName,
    required String guardianEmail,
    required double latitude,
    required double longitude,
    required double? distanceOutside,
  }) async {
    try {
      final now = DateTime.now();
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} '
          '${now.hour >= 12 ? 'PM' : 'AM'}';

      final mapsLink =
          'https://www.google.com/maps?q=${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';

      final body = {
        'service_id': AppConstants.emailJsServiceId,
        'template_id': AppConstants.emailJsTemplateId,
        'user_id': AppConstants.emailJsPublicKey,
        'template_params': {
          'to_email': guardianEmail,
          'user_name': userName,
          'current_time': timeStr,
          'distance_outside': distanceOutside != null
              ? '${distanceOutside.toStringAsFixed(0)} meters'
              : 'Unknown',
          'maps_link': mapsLink,
          'latitude': latitude.toStringAsFixed(6),
          'longitude': longitude.toStringAsFixed(6),
          'message':
              'Alert! $userName has moved outside the safe zone.\n\n'
              'Current Time: $timeStr\n'
              'Distance Outside Radius: ${distanceOutside?.toStringAsFixed(0) ?? '?'} meters\n'
              'Live Location: $mapsLink',
        },
      };

      final response = await http.post(
        Uri.parse(AppConstants.emailJsApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode(body),
      );

      debugPrint('EmailJS response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('EmailService.sendEmergencyAlert error: $e');
      return false;
    }
  }
}
