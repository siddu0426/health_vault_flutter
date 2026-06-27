import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/voice_message.dart';
import '../../services/voice_recognition_service.dart';
import '../../services/speech_service.dart';
import '../../services/voice_chat_service.dart';
import '../../services/conversation_manager.dart';

enum VoiceAssistantStateEnum { idle, listening, thinking, speaking, error }

class VoiceAssistantUIState {
  final VoiceAssistantStateEnum status;
  final List<VoiceMessage> messages;
  final String currentInputText;
  final String? errorMessage;
  final double soundLevel;
  final bool permissionGranted;

  VoiceAssistantUIState({
    required this.status,
    required this.messages,
    required this.currentInputText,
    this.errorMessage,
    required this.soundLevel,
    required this.permissionGranted,
  });

  factory VoiceAssistantUIState.initial() {
    return VoiceAssistantUIState(
      status: VoiceAssistantStateEnum.idle,
      messages: [
        VoiceMessage(
          id: 'welcome',
          text: "Hello Sarah. I can help with your records, medicines, family profiles, uploads, and emergency card. What do you need?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      currentInputText: '',
      errorMessage: null,
      soundLevel: 0.0,
      permissionGranted: false,
    );
  }

  VoiceAssistantUIState copyWith({
    VoiceAssistantStateEnum? status,
    List<VoiceMessage>? messages,
    String? currentInputText,
    String? errorMessage,
    double? soundLevel,
    bool? permissionGranted,
  }) {
    return VoiceAssistantUIState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      currentInputText: currentInputText ?? this.currentInputText,
      errorMessage: errorMessage ?? this.errorMessage,
      soundLevel: soundLevel ?? this.soundLevel,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }
}

// Service Providers
final voiceRecognitionServiceProvider = Provider<VoiceRecognitionService>((ref) => VoiceRecognitionService());
final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());
final voiceChatServiceProvider = Provider<VoiceChatService>((ref) => VoiceChatService());

final conversationManagerProvider = Provider<ConversationManager>((ref) {
  final recognition = ref.watch(voiceRecognitionServiceProvider);
  final speech = ref.watch(speechServiceProvider);
  final chat = ref.watch(voiceChatServiceProvider);
  return ConversationManager(
    recognitionService: recognition,
    speechService: speech,
    chatService: chat,
  );
});

// Notifier Provider
final voiceAssistantStateProvider = NotifierProvider<VoiceAssistantNotifier, VoiceAssistantUIState>(() {
  return VoiceAssistantNotifier();
});

class VoiceAssistantNotifier extends Notifier<VoiceAssistantUIState> {
  late final ConversationManager _manager;
  bool _sttInitialized = false;
  bool _ttsInitialized = false;

  @override
  VoiceAssistantUIState build() {
    _manager = ref.watch(conversationManagerProvider);
    _initServices();
    ref.onDispose(() {
      _manager.speechService.stop();
      _manager.recognitionService.cancelListening();
    });
    return VoiceAssistantUIState.initial();
  }

  Future<void> _initServices() async {
    // Check permission status initially
    final status = await Permission.microphone.status;
    state = state.copyWith(permissionGranted: status.isGranted);
  }

  Future<bool> _ensureSpeechInitialized() async {
    if (_sttInitialized) return true;
    
    final success = await _manager.recognitionService.initialize(
      onStatus: (status) {
        if (status == 'notListening' && state.status == VoiceAssistantStateEnum.listening) {
          // If STT stops listening automatically and we have typed content, send it
          if (state.currentInputText.trim().isNotEmpty) {
            sendMessage(state.currentInputText);
          } else {
            state = state.copyWith(status: VoiceAssistantStateEnum.idle, soundLevel: 0.0);
          }
        }
      },
      onError: (errorMsg) {
        state = state.copyWith(
          status: VoiceAssistantStateEnum.error,
          errorMessage: "Speech recognition error: $errorMsg",
          soundLevel: 0.0,
        );
      },
    );
    _sttInitialized = success;
    return success;
  }

  Future<void> _ensureTtsInitialized() async {
    if (_ttsInitialized) return;

    await _manager.speechService.initialize(
      onStart: () {
        if (state.status != VoiceAssistantStateEnum.error) {
          state = state.copyWith(status: VoiceAssistantStateEnum.speaking);
        }
      },
      onCompletion: () {
        if (state.status == VoiceAssistantStateEnum.speaking) {
          state = state.copyWith(status: VoiceAssistantStateEnum.idle);
        }
      },
      onError: (errorMsg) {
        state = state.copyWith(
          status: VoiceAssistantStateEnum.error,
          errorMessage: "Text-to-Speech error: $errorMsg",
        );
      },
    );
    _ttsInitialized = true;
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    final granted = status.isGranted;
    state = state.copyWith(permissionGranted: granted);
    if (!granted) {
      state = state.copyWith(
        status: VoiceAssistantStateEnum.error,
        errorMessage: "Microphone permission is required to use Voice Assistant.",
      );
    }
    return granted;
  }

  Future<void> startListening() async {
    final hasPermission = await requestMicrophonePermission();
    if (!hasPermission) return;

    // Stop speaking if assistant is playing audio
    await _manager.speechService.stop();

    final sttReady = await _ensureSpeechInitialized();
    if (!sttReady) {
      state = state.copyWith(
        status: VoiceAssistantStateEnum.error,
        errorMessage: "Speech recognition is unavailable on this device.",
      );
      return;
    }

    state = state.copyWith(
      status: VoiceAssistantStateEnum.listening,
      currentInputText: '',
      errorMessage: null,
      soundLevel: 0.0,
    );

    try {
      await _manager.recognitionService.startListening(
        onResult: (words, isFinal) {
          state = state.copyWith(currentInputText: words);
          if (isFinal && words.trim().isNotEmpty) {
            sendMessage(words);
          }
        },
        onSoundLevel: (level) {
          state = state.copyWith(soundLevel: level);
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: VoiceAssistantStateEnum.error,
        errorMessage: "Failed to start listening: ${e.toString()}",
      );
    }
  }

  Future<void> stopListening() async {
    if (state.status != VoiceAssistantStateEnum.listening) return;

    await _manager.recognitionService.stopListening();
    final textToSend = state.currentInputText.trim();
    if (textToSend.isNotEmpty) {
      sendMessage(textToSend);
    } else {
      state = state.copyWith(status: VoiceAssistantStateEnum.idle, soundLevel: 0.0);
    }
  }

  Future<void> cancelListening() async {
    await _manager.recognitionService.cancelListening();
    state = state.copyWith(
      status: VoiceAssistantStateEnum.idle,
      currentInputText: '',
      soundLevel: 0.0,
    );
  }

  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    // Stop any active speech/recognition
    await _manager.stopAll();
    await _manager.speechService.stop();
    await _manager.recognitionService.stopListening();

    final userMsg = VoiceMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: cleanText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      status: VoiceAssistantStateEnum.thinking,
      messages: [...state.messages, userMsg],
      currentInputText: '',
      errorMessage: null,
      soundLevel: 0.0,
    );

    try {
      final replyText = await _manager.chatService.sendMessage(cleanText);
      
      final assistantMsg = VoiceMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        status: VoiceAssistantStateEnum.speaking,
        messages: [...state.messages, assistantMsg],
      );

      // Convert reply to speech
      await _ensureTtsInitialized();
      await _manager.speechService.speak(replyText);
    } catch (e) {
      state = state.copyWith(
        status: VoiceAssistantStateEnum.error,
        errorMessage: "Network error: Failed to get response from AI. Please try again.",
      );
    }
  }

  Future<void> stopSpeaking() async {
    await _manager.speechService.stop();
    state = state.copyWith(status: VoiceAssistantStateEnum.idle);
  }

  Future<void> retry() async {
    // Find the last user message in history
    final lastUserMsg = state.messages.lastWhere(
      (m) => m.isUser,
      orElse: () => VoiceMessage(id: '', text: '', isUser: true, timestamp: DateTime.fromMillisecondsSinceEpoch(0)),
    );

    if (lastUserMsg.text.isNotEmpty) {
      // Remove any trailing messages after the user message (like errors or failed attempts)
      final userIndex = state.messages.indexOf(lastUserMsg);
      final trimmedMessages = state.messages.sublist(0, userIndex);
      state = state.copyWith(messages: trimmedMessages);

      await sendMessage(lastUserMsg.text);
    } else {
      state = state.copyWith(status: VoiceAssistantStateEnum.idle, errorMessage: null);
    }
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: null, status: VoiceAssistantStateEnum.idle);
  }

  void reset() {
    _manager.speechService.stop();
    _manager.recognitionService.cancelListening();
    state = VoiceAssistantUIState.initial();
  }

}
