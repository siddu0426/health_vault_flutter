class VoiceMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const VoiceMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  VoiceMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return VoiceMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
