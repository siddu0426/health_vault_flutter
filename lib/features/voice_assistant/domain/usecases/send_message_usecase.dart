import '../repositories/voice_chat_repository.dart';

class SendMessageUseCase {
  final VoiceChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<String> call(String message) {
    return repository.sendMessage(message);
  }
}
