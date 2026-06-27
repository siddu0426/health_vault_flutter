import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../providers/voice_assistant_provider.dart';

class MicWaveIndicator extends StatefulWidget {
  final VoiceAssistantStateEnum state;
  final double soundLevel;
  final VoidCallback onTap;

  const MicWaveIndicator({
    super.key,
    required this.state,
    required this.soundLevel,
    required this.onTap,
  });

  @override
  State<MicWaveIndicator> createState() => _MicWaveIndicatorState();
}

class _MicWaveIndicatorState extends State<MicWaveIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D7C8A);
    const thinkingColor = Color(0xFF8B5CF6); // Purple
    const speakingColor = Color(0xFF10B981); // Success Green
    const errorColor = Color(0xFFEF4444); // Danger Red

    Color activeColor;
    IconData iconData;
    bool animateWaves = false;
    double scaleFactor = 1.0;

    switch (widget.state) {
      case VoiceAssistantStateEnum.listening:
        activeColor = primaryColor;
        iconData = Icons.mic;
        animateWaves = true;
        // Normalize sound level from speech_to_text (typically -2 to 10+)
        final db = widget.soundLevel;
        final normalized = (db + 2.0).clamp(0.0, 15.0) / 15.0; // 0.0 to 1.0
        scaleFactor = 1.0 + (normalized * 0.45);
        break;
      case VoiceAssistantStateEnum.thinking:
        activeColor = thinkingColor;
        iconData = Icons.psychology;
        animateWaves = true;
        scaleFactor = 1.0 + (math.sin(_pulseController.value * math.pi * 2) * 0.08);
        break;
      case VoiceAssistantStateEnum.speaking:
        activeColor = speakingColor;
        iconData = Icons.volume_up;
        animateWaves = true;
        scaleFactor = 1.0 + (math.sin(_pulseController.value * math.pi * 2) * 0.12);
        break;
      case VoiceAssistantStateEnum.error:
        activeColor = errorColor;
        iconData = Icons.gpp_bad;
        animateWaves = false;
        scaleFactor = 1.0;
        break;
      case VoiceAssistantStateEnum.idle:
        activeColor = primaryColor;
        iconData = Icons.mic_none;
        animateWaves = false;
        scaleFactor = 1.0 + (math.sin(_pulseController.value * math.pi * 2) * 0.03); // very subtle breathing
        break;
    }

    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Wave background circles
            if (animateWaves)
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    // Spread the start times of the circles
                    double progress = (_pulseController.value - (index * 0.3)) % 1.0;
                    if (progress < 0) progress += 1.0;

                    double waveScale = 1.0 + (progress * 1.5 * scaleFactor);
                    double opacity = 0.45 * (1.0 - progress);

                    return Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeColor.withOpacity(opacity.clamp(0.0, 1.0)),
                      ),
                      transform: Matrix4.identity()..scale(waveScale),
                    );
                  },
                );
              }),

            // Decorative rotating outer dashed ring for "thinking"
            if (widget.state == VoiceAssistantStateEnum.thinking)
              RotationTransition(
                turns: _rotateController,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: thinkingColor.withOpacity(0.5),
                      width: 2.0,
                    ),
                  ),
                ),
              ),

            // Main central mic button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 90 * scaleFactor,
              height: 90 * scaleFactor,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeColor,
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  customBorder: const CircleBorder(),
                  child: Icon(
                    iconData,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
