// App-wide constants for Safepath

class AppConstants {
  // App Info
  static const String appName = 'Safepath';
  static const String appTagline = 'Your Smart Accessibility Companion';
  static const String appVersion = '1.0.0';

  // EmailJS Configuration (Replace with your EmailJS credentials)
  static const String emailJsServiceId = 'service_safepath';
  static const String emailJsTemplateId = 'template_emergency';
  static const String emailJsPublicKey = 'YOUR_EMAILJS_PUBLIC_KEY';
  static const String emailJsApiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String guardiansCollection = 'guardians';
  static const String alertsCollection = 'alerts';
  static const String locationsCollection = 'locations';

  // Defaults
  static const double defaultSafeRadius = 500.0; // meters
  static const int locationUpdateIntervalSeconds = 10;
  static const int splashDurationSeconds = 3;

  // Safe Radius Options (meters)
  static const List<double> safeRadiusOptions = [100, 250, 500, 1000];
  static const List<String> safeRadiusLabels = ['100m', '250m', '500m', '1km'];

  // User Types
  static const List<Map<String, dynamic>> userTypes = [
    {
      'id': 'visually_impaired',
      'label': 'Visually Impaired',
      'icon': '👁️',
      'description': 'For users with visual impairments',
    },
    {
      'id': 'hearing_impaired',
      'label': 'Hearing Impaired',
      'icon': '👂',
      'description': 'For users with hearing impairments',
    },
    {
      'id': 'wheelchair_user',
      'label': 'Wheelchair User',
      'icon': '♿',
      'description': 'For wheelchair-dependent users',
    },
    {
      'id': 'elderly',
      'label': 'Elderly Person',
      'icon': '👴',
      'description': 'For senior citizens',
    },
    {
      'id': 'guardian',
      'label': 'Guardian / Caregiver',
      'icon': '🛡️',
      'description': 'Monitor and protect loved ones',
    },
  ];

  // Alert Types
  static const String alertTypeRadius = 'radius_breach';
  static const String alertTypeEmergency = 'emergency_sos';
  static const String alertTypeTracking = 'tracking_disabled';

  // Shared Prefs Keys
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefDarkMode = 'dark_mode';
  static const String prefVoiceEnabled = 'voice_enabled';
  static const String prefLargeText = 'large_text';
  static const String prefHighContrast = 'high_contrast';
}
