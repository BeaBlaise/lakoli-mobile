import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_remote_datasource.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl(this._remote);

  final MessageRemoteDataSource _remote;

  @override
  Future<Result<List<ConversationEntity>>> conversations() async {
    try {
      final models = await _remote.conversations();
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<List<UserSearchResult>>> searchUsers(String query) async {
    try {
      return Result.success(await _remote.searchUsers(query));
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<String>> startConversation(String userId) async {
    try {
      return Result.success(await _remote.startConversation(userId));
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<(List<MessageEntity>, bool)>> messages(String conversationId) async {
    try {
      final (models, canReply) = await _remote.messages(conversationId);
      return Result.success((models.map((m) => m.toEntity()).toList(), canReply));
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<MessageEntity>> sendMessage(String conversationId, String contenu, {String? imagePath}) async {
    try {
      final model = await _remote.sendMessage(conversationId, contenu, imagePath: imagePath);
      return Result.success(model.toEntity());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> block(String userId) => _run(() => _remote.block(userId));

  @override
  Future<Result<void>> unblock(String userId) => _run(() => _remote.unblock(userId));

  Future<Result<void>> _run(Future<void> Function() call) async {
    try {
      await call();
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }
}
