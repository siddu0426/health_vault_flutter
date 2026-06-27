import '../../domain/repositories/voice_chat_repository.dart';
import '../datasources/voice_chat_remote_datasource.dart';

class VoiceChatRepositoryImpl implements VoiceChatRepository {
  final VoiceChatRemoteDataSource remoteDataSource;

  VoiceChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> sendMessage(String message) {
    return remoteDataSource.sendMessage(message);
  }
}
