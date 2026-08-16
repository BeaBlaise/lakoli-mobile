import '../../core/utils/result.dart';
import '../entities/message_entity.dart';

abstract interface class MessageRepository {
  Future<Result<List<ConversationEntity>>> conversations();

  Future<Result<List<UserSearchResult>>> searchUsers(String query);

  Future<Result<String>> startConversation(String userId);

  /// (messages, l'utilisateur courant peut-il répondre) — `can_reply` reflète le blocage dans
  /// les deux sens, voir Api\V1\MessageController::messages().
  Future<Result<(List<MessageEntity>, bool)>> messages(String conversationId);

  Future<Result<MessageEntity>> sendMessage(String conversationId, String contenu, {String? imagePath});

  Future<Result<void>> block(String userId);
  Future<Result<void>> unblock(String userId);
}
