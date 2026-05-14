class AlertModel {
  final String id;
  final String userId;
  final String alertType;
  final String title;
  final String message;
  final double latitude;
  final double longitude;
  final double? distanceOutside;
  final DateTime timestamp;
  final bool isRead;

  AlertModel({
    required this.id,
    required this.userId,
    required this.alertType,
    required this.title,
    required this.message,
    required this.latitude,
    required this.longitude,
    this.distanceOutside,
    required this.timestamp,
    this.isRead = false,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map, String id) {
    return AlertModel(
      id: id,
      userId: map['userId'] ?? '',
      alertType: map['alertType'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceOutside: (map['distanceOutside'] as num?)?.toDouble(),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'alertType': alertType,
      'title': title,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'distanceOutside': distanceOutside,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  String get googleMapsLink =>
      'https://www.google.com/maps?q=$latitude,$longitude';
}
