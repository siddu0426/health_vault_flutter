import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/voice_assistant_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/mic_wave_indicator.dart';
import '../widgets/thinking_indicator.dart';

class VoiceAssistantPage extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<String> onNavigate;

  const VoiceAssistantPage({
    super.key,
    required this.onBack,
    required this.onNavigate,
  });

  @override
  ConsumerState<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends ConsumerState<VoiceAssistantPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isTextMode = false;

  @override
  void initState() {
    super.initState();
    // Auto-scroll on initial load after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String? _getNavigationDestination(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('emergency card')) return 'emergency';
    if (lower.contains('medication schedule') || lower.contains('medicine schedule')) return 'medications';
    if (lower.contains('lab, prescription, radiology')) return 'records';
    if (lower.contains('take you to upload')) return 'upload';
    if (lower.contains('family profiles')) return 'family';
    if (lower.contains('health timeline')) return 'timeline';
    return null;
  }

  String? _getNavigationLabel(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('emergency card')) return 'Open Emergency Card';
    if (lower.contains('medication schedule') || lower.contains('medicine schedule')) return 'Open Medications';
    if (lower.contains('lab, prescription, radiology')) return 'Open Health Records';
    if (lower.contains('take you to upload')) return 'Open Upload Portal';
    if (lower.contains('family profiles')) return 'Open Family Profiles';
    if (lower.contains('health timeline')) return 'Open Health Timeline';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceAssistantStateProvider);
    final notifier = ref.read(voiceAssistantStateProvider.notifier);

    // Trigger scroll to bottom when messages list size changes
    ref.listen(voiceAssistantStateProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          next.status == VoiceAssistantStateEnum.thinking) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    const teal = Color(0xFF0D7C8A);
    const slate500 = Color(0xFF64748B);
    const slate900 = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Matching AppColors.background
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      notifier.reset();
                      widget.onBack();
                    },
                    icon: const Icon(Icons.arrow_back, color: slate900),
                  ),
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE9F5F6),
                    radius: 18,
                    child: Icon(Icons.graphic_eq, color: teal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Health AI Assistant',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: slate900,
                          ),
                        ),
                        Text(
                          _getStatusText(state.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(state.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Clear history',
                    onPressed: () => notifier.reset(),
                    icon: const Icon(Icons.refresh, color: slate500, size: 22),
                  ),
                  if (state.status == VoiceAssistantStateEnum.speaking)
                    IconButton(
                      tooltip: 'Stop speaking',
                      onPressed: () => notifier.stopSpeaking(),
                      icon: const Icon(Icons.volume_off, color: teal, size: 22),
                    ),
                ],
              ),
            ),

            // Chat Messages Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: state.messages.length +
                    (state.status == VoiceAssistantStateEnum.thinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.messages.length) {
                    return const ThinkingIndicator();
                  }

                  final message = state.messages[index];
                  final dest = _getNavigationDestination(message.text);
                  final label = _getNavigationLabel(message.text);

                  return ChatBubble(
                    message: message,
                    onActionTap: dest != null
                        ? () => widget.onNavigate(dest)
                        : null,
                    actionLabel: label,
                  );
                },
              ),
            ),

            // Suggestion Chips (only when conversation is fresh)
            if (state.messages.length == 1 &&
                state.status == VoiceAssistantStateEnum.idle)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    'Check my medications',
                    'Open emergency card',
                    'View recent lab reports',
                    'Show family profiles',
                  ].map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          suggestion,
                          style: const TextStyle(
                            color: teal,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () => notifier.sendMessage(suggestion),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Error Message Banner (if any)
            if (state.errorMessage != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12.5),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF991B1B), size: 18),
                      onPressed: () => notifier.clearErrorMessage(),
                    ),
                  ],
                ),
              ),

            // Real-time voice transcript text preview
            if (state.status == VoiceAssistantStateEnum.listening &&
                state.currentInputText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  state.currentInputText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: teal,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Bottom Input Controls
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEFF3F7))),
              ),
              child: _isTextMode ? _buildTextInput(notifier) : _buildVoiceInput(state, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceInput(VoiceAssistantUIState state, VoiceAssistantNotifier notifier) {
    final isListening = state.status == VoiceAssistantStateEnum.listening;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isListening)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ActionChip(
              avatar: const Icon(Icons.stop, size: 16, color: Colors.white),
              label: const Text(
                'Stop Listening',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
              onPressed: () => notifier.stopListening(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Action: Cancel or Switch to Keyboard
            IconButton(
              tooltip: isListening ? 'Cancel' : 'Keyboard input',
              onPressed: isListening
                  ? () => notifier.cancelListening()
                  : () {
                      setState(() {
                        _isTextMode = true;
                      });
                    },
              icon: Icon(
                isListening ? Icons.close : Icons.keyboard,
                color: const Color(0xFF64748B),
                size: 26,
              ),
            ),

            // Middle Action: Animated Microphone
            MicWaveIndicator(
              state: state.status,
              soundLevel: state.soundLevel,
              onTap: () {
                if (isListening) {
                  notifier.stopListening();
                } else {
                  notifier.startListening();
                }
              },
            ),

            // Right Action: Retry or Reset
            IconButton(
              tooltip: state.status == VoiceAssistantStateEnum.error ? 'Retry' : 'Reset chat',
              onPressed: state.status == VoiceAssistantStateEnum.error
                  ? () => notifier.retry()
                  : () => notifier.reset(),
              icon: Icon(
                state.status == VoiceAssistantStateEnum.error ? Icons.replay : Icons.cleaning_services_outlined,
                color: const Color(0xFF64748B),
                size: 26,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextInput(VoiceAssistantNotifier notifier) {
    const primaryColor = Color(0xFF0D7C8A);
    return Row(
      children: [
        IconButton(
          tooltip: 'Voice mode',
          onPressed: () {
            setState(() {
              _isTextMode = false;
            });
          },
          icon: const Icon(Icons.mic, color: primaryColor, size: 26),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _textController,
            textInputAction: TextInputAction.send,
            onSubmitted: (text) {
              if (text.trim().isNotEmpty) {
                notifier.sendMessage(text);
                _textController.clear();
              }
            },
            decoration: InputDecoration(
              hintText: 'Type a message...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFEFF3F7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: primaryColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: primaryColor),
          onPressed: () {
            final text = _textController.text.trim();
            if (text.isNotEmpty) {
              notifier.sendMessage(text);
              _textController.clear();
            }
          },
          icon: const Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  String _getStatusText(VoiceAssistantStateEnum status) {
    switch (status) {
      case VoiceAssistantStateEnum.listening:
        return 'Listening…';
      case VoiceAssistantStateEnum.thinking:
        return 'Thinking…';
      case VoiceAssistantStateEnum.speaking:
        return 'Speaking…';
      case VoiceAssistantStateEnum.error:
        return 'Error';
      case VoiceAssistantStateEnum.idle:
        return 'Online';
    }
  }

  Color _getStatusColor(VoiceAssistantStateEnum status) {
    switch (status) {
      case VoiceAssistantStateEnum.listening:
        return const Color(0xFF0D7C8A);
      case VoiceAssistantStateEnum.thinking:
        return Colors.purple;
      case VoiceAssistantStateEnum.speaking:
        return Colors.green;
      case VoiceAssistantStateEnum.error:
        return Colors.red;
      case VoiceAssistantStateEnum.idle:
        return Colors.green;
    }
  }
}
