class LocationModel {
  final String userId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final double? altitude;
  final DateTime timestamp;
  final bool isInsideSafeZone;

  LocationModel({
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.altitude,
    required this.timestamp,
    required this.isInsideSafeZone,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      userId: map['userId'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble(),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isInsideSafeZone: map['isInsideSafeZone'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
      'isInsideSafeZone': isInsideSafeZone,
    };
  }
}
