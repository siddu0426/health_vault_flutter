import 'dart:async';
import 'voice_recognition_service.dart';
import 'speech_service.dart';
import 'voice_chat_service.dart';

class ConversationManager {
  final VoiceRecognitionService recognitionService;
  final SpeechService speechService;
  final VoiceChatService chatService;

  ConversationManager({
    required this.recognitionService,
    required this.speechService,
    required this.chatService,
  });

  /// Stops all active audio tasks (STT and TTS)
  Future<void> stopAll() async {
    await recognitionService.stopListening();
    await speechService.stop();
  }

  /// Cancels any active speech recognition and stops TTS
  Future<void> cancelAll() async {
    await recognitionService.cancelListening();
    await speechService.stop();
  }
}
