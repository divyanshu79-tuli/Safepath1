import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/alert_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../services/email_service.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';

enum AppState { idle, loading, error }

/// Central state management provider for all app features
class AppProvider extends ChangeNotifier {
  // ─── Services ────────────────────────────────────────────────
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();
  final NotificationService _notifService = NotificationService();
  final TtsService _ttsService = TtsService();

  // ─── State ───────────────────────────────────────────────────
  AppState _state = AppState.idle;
  UserModel? _currentUser;
  Position? _currentPosition;
  bool _isInsideSafeZone = true;
  bool _isTracking = false;
  bool _isDarkMode = true;
  bool _isVoiceEnabled = true;
  bool _isLargeText = false;
  bool _isHighContrast = false;
  List<AlertModel> _alerts = [];
  String? _errorMessage;
  double _distanceFromSafeZone = 0;

  // ─── Getters ─────────────────────────────────────────────────
  AppState get state => _state;
  UserModel? get currentUser => _currentUser;
  Position? get currentPosition => _currentPosition;
  bool get isInsideSafeZone => _isInsideSafeZone;
  bool get isTracking => _isTracking;
  bool get isDarkMode => _isDarkMode;
  bool get isVoiceEnabled => _isVoiceEnabled;
  bool get isLargeText => _isLargeText;
  bool get isHighContrast => _isHighContrast;
  List<AlertModel> get alerts => _alerts;
  String? get errorMessage => _errorMessage;
  double get distanceFromSafeZone => _distanceFromSafeZone;

  // ─── Init ─────────────────────────────────────────────────────
  Future<void> init() async {
    await _ttsService.init();
    await _notifService.init();
    await _loadPrefs();

    final user = _authService.currentUser;
    if (user != null) {
      await loadUserData(user.uid);
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(AppConstants.prefDarkMode) ?? true;
    _isVoiceEnabled = prefs.getBool(AppConstants.prefVoiceEnabled) ?? true;
    _isLargeText = prefs.getBool(AppConstants.prefLargeText) ?? false;
    _isHighContrast = prefs.getBool(AppConstants.prefHighContrast) ?? false;
    _ttsService.setEnabled(_isVoiceEnabled);
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefDarkMode, _isDarkMode);
    await prefs.setBool(AppConstants.prefVoiceEnabled, _isVoiceEnabled);
    await prefs.setBool(AppConstants.prefLargeText, _isLargeText);
    await prefs.setBool(AppConstants.prefHighContrast, _isHighContrast);
  }

  // ─── Auth ────────────────────────────────────────────────────
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
    String? guardianEmail,
    String? guardianName,
  }) async {
    _setState(AppState.loading);
    try {
      _currentUser = await _authService.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
        userType: userType,
        guardianEmail: guardianEmail,
        guardianName: guardianName,
      );
      _setState(AppState.idle);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setState(AppState.loading);
    try {
      _currentUser = await _authService.signIn(email: email, password: password);
      if (_currentUser != null) {
        await loadAlerts();
      }
      _setState(AppState.idle);
      return _currentUser != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    stopTracking();
    await _authService.signOut();
    _currentUser = null;
    _alerts = [];
    _currentPosition = null;
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordReset(email);
  }

  // ─── User Data ───────────────────────────────────────────────
  Future<void> loadUserData(String uid) async {
    _currentUser = await _firestoreService.getUser(uid);
    if (_currentUser != null) await loadAlerts();
    notifyListeners();
  }

  Future<void> updateUserField(Map<String, dynamic> data) async {
    if (_currentUser == null) return;
    await _firestoreService.updateUser(_currentUser!.uid, data);
    _currentUser = await _firestoreService.getUser(_currentUser!.uid);
    notifyListeners();
  }

  // ─── Location Tracking ───────────────────────────────────────
  Future<void> startTracking() async {
    if (_currentUser == null) return;
    final granted = await _locationService.requestPermissions();
    if (!granted) {
      _setError('Location permission denied');
      return;
    }

    // Fetch current position first
    final pos = await _locationService.getCurrentPosition();
    if (pos != null) {
      _currentPosition = pos;
      // If no safe zone set, use current location as center
      if (_currentUser!.safeZoneLat == null) {
        await updateUserField({
          'safeZoneLat': pos.latitude,
          'safeZoneLng': pos.longitude,
          'isTracking': true,
        });
      } else {
        await updateUserField({'isTracking': true});
      }
    }

    _isTracking = true;
    notifyListeners();

    _locationService.startTracking(
      userId: _currentUser!.uid,
      safeZoneLat:
          _currentUser!.safeZoneLat ?? _currentPosition?.latitude ?? 0.0,
      safeZoneLng:
          _currentUser!.safeZoneLng ?? _currentPosition?.longitude ?? 0.0,
      safeRadiusMeters: _currentUser!.safeRadiusMeters ?? 500.0,
      onUpdate: _onLocationUpdate,
    );

    await _ttsService.announceTrackingStarted();
  }

  void stopTracking() {
    _locationService.stopTracking();
    _isTracking = false;
    if (_currentUser != null) {
      _firestoreService.updateUser(_currentUser!.uid, {'isTracking': false});
    }
    notifyListeners();
    _ttsService.announceTrackingStopped();
  }

  void _onLocationUpdate(Position pos, bool inside) async {
    final wasInside = _isInsideSafeZone;
    _currentPosition = pos;
    _isInsideSafeZone = inside;

    if (_currentUser != null) {
      // Calculate distance from safe zone center
      _distanceFromSafeZone = _locationService.calculateDistance(
        pos.latitude,
        pos.longitude,
        _currentUser!.safeZoneLat ?? pos.latitude,
        _currentUser!.safeZoneLng ?? pos.longitude,
      );
    }

    notifyListeners();

    // Trigger alerts only when transitioning from inside → outside
    if (wasInside && !inside) {
      await _triggerEmergency();
    }
  }

  Future<void> _triggerEmergency() async {
    if (_currentUser == null || _currentPosition == null) return;

    final distOut = _distanceFromSafeZone -
        (_currentUser!.safeRadiusMeters ?? 500.0);

    // Voice alert
    await _ttsService.announceOutsideSafeZone();

    // Local notification
    await _notifService.showEmergencyAlert(
      userName: _currentUser!.name,
      distance: distOut > 0 ? distOut : 0,
    );

    // Save to Firestore
    final alert = AlertModel(
      id: '',
      userId: _currentUser!.uid,
      alertType: AppConstants.alertTypeRadius,
      title: '🚨 Outside Safe Zone',
      message:
          '${_currentUser!.name} has moved outside the safe zone.',
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      distanceOutside: distOut > 0 ? distOut : 0,
      timestamp: DateTime.now(),
    );
    await _firestoreService.saveAlert(alert);

    // Email alert to guardian
    if (_currentUser!.guardianEmail != null &&
        _currentUser!.guardianEmail!.isNotEmpty) {
      await EmailService.sendEmergencyAlert(
        userName: _currentUser!.name,
        guardianEmail: _currentUser!.guardianEmail!,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        distanceOutside: distOut > 0 ? distOut : 0,
      );
    }

    await loadAlerts();
  }

  // ─── SOS ─────────────────────────────────────────────────────
  Future<void> triggerSOS() async {
    if (_currentUser == null) return;

    await _ttsService.announceSosActivated();

    await _notifService.showLocalNotification(
      title: '🆘 SOS Activated',
      body: 'Emergency SOS triggered by ${_currentUser!.name}.',
      payload: 'sos',
    );

    if (_currentPosition != null) {
      final alert = AlertModel(
        id: '',
        userId: _currentUser!.uid,
        alertType: AppConstants.alertTypeEmergency,
        title: '🆘 SOS Emergency',
        message: '${_currentUser!.name} activated emergency SOS.',
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        timestamp: DateTime.now(),
      );
      await _firestoreService.saveAlert(alert);

      if (_currentUser!.guardianEmail != null &&
          _currentUser!.guardianEmail!.isNotEmpty) {
        await EmailService.sendEmergencyAlert(
          userName: _currentUser!.name,
          guardianEmail: _currentUser!.guardianEmail!,
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          distanceOutside: null,
        );
      }
    }

    await loadAlerts();
  }

  // ─── Alerts ──────────────────────────────────────────────────
  Future<void> loadAlerts() async {
    if (_currentUser == null) return;
    _alerts = await _firestoreService.getAlerts(_currentUser!.uid);
    notifyListeners();
  }

  // ─── Settings ────────────────────────────────────────────────
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _savePrefs();
    notifyListeners();
  }

  void toggleVoice() {
    _isVoiceEnabled = !_isVoiceEnabled;
    _ttsService.setEnabled(_isVoiceEnabled);
    _savePrefs();
    notifyListeners();
  }

  void toggleLargeText() {
    _isLargeText = !_isLargeText;
    _savePrefs();
    notifyListeners();
  }

  void toggleHighContrast() {
    _isHighContrast = !_isHighContrast;
    _savePrefs();
    notifyListeners();
  }

  // ─── Helpers ─────────────────────────────────────────────────
  void _setState(AppState s) {
    _state = s;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _state = AppState.error;
    _errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _state = AppState.idle;
    notifyListeners();
  }
}
