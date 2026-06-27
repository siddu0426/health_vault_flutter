import 'package:flutter/material.dart';
import '../../models/voice_message.dart';

class ChatBubble extends StatelessWidget {
  final VoiceMessage message;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const ChatBubble({
    super.key,
    required this.message,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D7C8A);
    const userBubbleColor = primaryColor;
    const assistantBubbleColor = Colors.white;
    const userTextColor = Colors.white;
    const assistantTextColor = Color(0xFF1E293B); // Slate-800
    const borderColor = Color(0xFFE2E8F0); // Slate-200

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE9F5F6),
              child: Icon(
                Icons.health_and_safety_outlined,
                size: 18,
                color: primaryColor.withOpacity(0.9),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser ? userBubbleColor : assistantBubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: message.isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(0),
                      bottomRight: message.isUser
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
                    ),
                    border: message.isUser
                        ? null
                        : Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? userTextColor : assistantTextColor,
                          fontSize: 14.5,
                          height: 1.4,
                          fontWeight: message.isUser
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      if (!message.isUser && onActionTap != null && actionLabel != null) ...[
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: onActionTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F5F6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.open_in_new,
                                  size: 14,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  actionLabel!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8), // Slate-400
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFCBD5E1),
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
