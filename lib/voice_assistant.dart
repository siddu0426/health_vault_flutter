import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AssistantMessage {
  const AssistantMessage(this.text, {required this.fromUser});

  final String text;
  final bool fromUser;
}

class AssistantReply {
  const AssistantReply(this.text, {this.destination});

  final String text;
  final String? destination;
}

/// Local command engine. Replace this behind an authenticated backend service
/// when a clinical-grade conversational model is selected.
class HealthAssistantEngine {
  AssistantReply reply(String raw) {
    final text = raw.toLowerCase().trim();
    if (text.contains('emergency') || text.contains('allerg')) {
      return const AssistantReply(
        'I can open your emergency card with allergies, blood group, contacts, and critical medicines. For an urgent medical emergency, call local emergency services now.',
        destination: 'emergency',
      );
    }
    if (text.contains('medicine') || text.contains('medication') || text.contains('pill')) {
      return const AssistantReply(
        'You have two evening medicines due at 8:00 PM: Metformin 500 mg and Atorvastatin 20 mg. I can open your medication schedule.',
        destination: 'medications',
      );
    }
    if (text.contains('record') || text.contains('report') || text.contains('result')) {
      return const AssistantReply(
        'Your vault contains lab, prescription, radiology, and vaccine records. I can open it so you can search or share a record.',
        destination: 'records',
      );
    }
    if (text.contains('upload') || text.contains('scan')) {
      return const AssistantReply(
        'I can take you to Upload, where you can scan a report, choose an image, or select a PDF.',
        destination: 'upload',
      );
    }
    if (text.contains('family') || text.contains('robert') || text.contains('member')) {
      return const AssistantReply(
        'I can open your family profiles. Robert has a blood-pressure check due today.',
        destination: 'family',
      );
    }
    if (text.contains('timeline') || text.contains('history')) {
      return const AssistantReply(
        'I can open your health timeline and filter visits, reports, medicines, and vaccines.',
        destination: 'timeline',
      );
    }
    return const AssistantReply(
      'I can help you find records, review today’s medicines, upload a report, open family profiles, or show emergency information. I do not diagnose conditions or replace a clinician.',
    );
  }
}

class VoiceAssistantPage extends StatefulWidget {
  const VoiceAssistantPage({super.key, required this.onBack, required this.onNavigate});

  final VoidCallback onBack;
  final ValueChanged<String> onNavigate;

  @override
  State<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends State<VoiceAssistantPage> {
  final _speech = SpeechToText();
  final _tts = FlutterTts();
  final _engine = HealthAssistantEngine();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<AssistantMessage> _messages = const [
    AssistantMessage(
      'Hello Sarah. I can help with your records, medicines, family profiles, uploads, and emergency card. What do you need?',
      fromUser: false,
    ),
  ].toList();
  bool _listening = false;
  bool _speechReady = false;

  @override
  void initState() {
    super.initState();
    _configureAudio();
  }

  Future<void> _configureAudio() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(.48);
    final ready = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() => _listening = status == 'listening');
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (mounted) setState(() => _speechReady = ready);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      if (_controller.text.trim().isNotEmpty) _send();
      return;
    }
    if (!_speechReady) {
      _show('Microphone access is unavailable. You can still type a message.');
      return;
    }
    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
        setState(() {});
        if (result.finalResult && _controller.text.trim().isNotEmpty) _send();
      },
    );
  }

  Future<void> _send([String? suggestion]) async {
    final text = (suggestion ?? _controller.text).trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _speech.stop();
    final reply = _engine.reply(text);
    setState(() {
      _messages.add(AssistantMessage(text, fromUser: true));
      _messages.add(AssistantMessage(reply.text, fromUser: false));
    });
    _scrollToBottom();
    await _tts.stop();
    await _tts.speak(reply.text);
    if (reply.destination != null && mounted) {
      _show('Tap Open to continue.', action: () => widget.onNavigate(reply.destination!));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _show(String message, {VoidCallback? action}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: action == null ? null : SnackBarAction(label: 'Open', onPressed: action),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0D7C8A);
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
              child: Row(children: [
                IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
                const CircleAvatar(backgroundColor: Color(0xFFE9F5F6), child: Icon(Icons.graphic_eq, color: teal)),
                const SizedBox(width: 10),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Health Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text('Voice and text', style: TextStyle(fontSize: 12, color: Colors.green))])),
                IconButton(tooltip: 'Stop speaking', onPressed: _tts.stop, icon: const Icon(Icons.volume_off_outlined)),
              ]),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return Align(
                alignment: message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 310),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: message.fromUser ? teal : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: message.fromUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(message.text, style: TextStyle(color: message.fromUser ? Colors.white : const Color(0xFF334155), height: 1.35)),
                ),
              );
            },
          ),
        ),
        if (_messages.length == 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: ['Today’s medicines', 'Find my latest report', 'Emergency information'].map((item) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(label: Text(item), onPressed: () => _send(item)),
            )).toList()),
          ),
        Material(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(children: [
                Expanded(child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(hintText: _listening ? 'Listening…' : 'Ask about your health records', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                )),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: _listening ? 'Stop listening' : 'Speak',
                  onPressed: _toggleListening,
                  style: IconButton.styleFrom(backgroundColor: _listening ? Colors.red : teal, fixedSize: const Size(48, 48)),
                  icon: Icon(_listening ? Icons.stop : Icons.mic),
                ),
                IconButton(tooltip: 'Send', onPressed: _send, icon: const Icon(Icons.send, color: teal)),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}
