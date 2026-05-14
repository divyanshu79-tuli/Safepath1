class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String userType;
  final String? guardianEmail;
  final String? guardianName;
  final double? safeRadiusMeters;
  final double? safeZoneLat;
  final double? safeZoneLng;
  final bool isTracking;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.guardianEmail,
    this.guardianName,
    this.safeRadiusMeters,
    this.safeZoneLat,
    this.safeZoneLng,
    this.isTracking = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      userType: map['userType'] ?? 'user',
      guardianEmail: map['guardianEmail'],
      guardianName: map['guardianName'],
      safeRadiusMeters: (map['safeRadiusMeters'] as num?)?.toDouble() ?? 500.0,
      safeZoneLat: (map['safeZoneLat'] as num?)?.toDouble(),
      safeZoneLng: (map['safeZoneLng'] as num?)?.toDouble(),
      isTracking: map['isTracking'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType,
      'guardianEmail': guardianEmail,
      'guardianName': guardianName,
      'safeRadiusMeters': safeRadiusMeters ?? 500.0,
      'safeZoneLat': safeZoneLat,
      'safeZoneLng': safeZoneLng,
      'isTracking': isTracking,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? userType,
    String? guardianEmail,
    String? guardianName,
    double? safeRadiusMeters,
    double? safeZoneLat,
    double? safeZoneLng,
    bool? isTracking,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      guardianEmail: guardianEmail ?? this.guardianEmail,
      guardianName: guardianName ?? this.guardianName,
      safeRadiusMeters: safeRadiusMeters ?? this.safeRadiusMeters,
      safeZoneLat: safeZoneLat ?? this.safeZoneLat,
      safeZoneLng: safeZoneLng ?? this.safeZoneLng,
      isTracking: isTracking ?? this.isTracking,
      createdAt: createdAt,
    );
  }
}
