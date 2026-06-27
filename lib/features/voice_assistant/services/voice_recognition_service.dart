import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speechToText.isListening;
  bool get isInitialized => _isInitialized;

  Future<bool> initialize({
    required Function(String status) onStatus,
    required Function(String errorMsg) onError,
  }) async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speechToText.initialize(
        onStatus: onStatus,
        onError: (errorNotification) {
          onError(errorNotification.errorMsg);
        },
      );
      return _isInitialized;
    } catch (e) {
      onError(e.toString());
      return false;
    }
  }

  Future<void> startListening({
    required Function(String words, bool isFinal) onResult,
    required Function(double level) onSoundLevel,
  }) async {
    if (!_isInitialized) {
      throw Exception("VoiceRecognitionService is not initialized. Call initialize first.");
    }
    
    final options = SpeechListenOptions(
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      onSoundLevelChange: onSoundLevel,
      listenOptions: options,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<void> cancelListening() async {
    await _speechToText.cancel();
  }
}
