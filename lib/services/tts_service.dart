import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Text-to-speech accessibility service
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;
  void setEnabled(bool v) => _isEnabled = v;

  Future<void> init() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('TtsService.init error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isEnabled) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TtsService.speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('TtsService.stop error: $e');
    }
  }

  // Common voice alerts
  Future<void> announceOutsideSafeZone() =>
      speak('Warning! You are moving outside your safe zone.');

  Future<void> announceInsideSafeZone() =>
      speak('You are back inside your safe zone.');

  Future<void> announceSosActivated() =>
      speak('Emergency SOS activated. Alerting your guardian now.');

  Future<void> announceTrackingStarted() =>
      speak('Location tracking has started.');

  Future<void> announceTrackingStopped() =>
      speak('Location tracking has stopped.');
}
