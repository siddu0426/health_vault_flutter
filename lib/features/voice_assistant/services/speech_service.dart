import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize({
    required VoidCallback onStart,
    required VoidCallback onCompletion,
    required Function(String errorMsg) onError,
  }) async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.48);
      
      _flutterTts.setStartHandler(() {
        onStart();
      });

      _flutterTts.setCompletionHandler(() {
        onCompletion();
      });

      _flutterTts.setCancelHandler(() {
        onCompletion();
      });

      _flutterTts.setErrorHandler((msg) {
        onError(msg.toString());
      });

      _isInitialized = true;
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
