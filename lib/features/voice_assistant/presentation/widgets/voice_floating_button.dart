import 'dart:math' as math;
import 'package:flutter/material.dart';

class VoiceFloatingButton extends StatefulWidget {
  final VoidCallback onTap;

  const VoiceFloatingButton({super.key, required this.onTap});

  @override
  State<VoiceFloatingButton> createState() => _VoiceFloatingButtonState();
}

class _VoiceFloatingButtonState extends State<VoiceFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D7C8A);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (math.sin(_controller.value * math.pi * 2) * 0.04);
        return Transform.scale(
          scale: scale,
          child: FloatingActionButton(
            heroTag: 'voice_assistant_fab',
            onPressed: widget.onTap,
            backgroundColor: primaryColor,
            elevation: 6,
            shape: const CircleBorder(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse halo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withOpacity(0.4 * (1.0 - _controller.value)),
                      width: 10 * _controller.value,
                    ),
                  ),
                ),
                const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 26,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
