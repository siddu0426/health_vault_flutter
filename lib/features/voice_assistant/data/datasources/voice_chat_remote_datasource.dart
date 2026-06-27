import '../../services/voice_chat_service.dart';

abstract class VoiceChatRemoteDataSource {
  Future<String> sendMessage(String message);
}

class VoiceChatRemoteDataSourceImpl implements VoiceChatRemoteDataSource {
  final VoiceChatService _service;

  VoiceChatRemoteDataSourceImpl(this._service);

  @override
  Future<String> sendMessage(String message) {
    return _service.sendMessage(message);
  }
}
