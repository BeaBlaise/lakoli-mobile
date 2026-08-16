import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/message_entity.dart';
import '../../auth/application/auth_controller.dart';

final conversationsControllerProvider =
    AsyncNotifierProvider<ConversationsController, List<ConversationEntity>>(ConversationsController.new);

class ConversationsController extends AsyncNotifier<List<ConversationEntity>> {
  @override
  Future<List<ConversationEntity>> build() async {
    ref.watch(authControllerProvider);

    final result = await ref.read(messageRepositoryProvider).conversations();
    return result.when(success: (list) => list, failure: (exception) => throw exception);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<ConversationEntity>>();
    state = await AsyncValue.guard(() => build());
  }

  void markRead(String conversationId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.map((c) => c.id == conversationId ? c.copyWith(unread: false) : c).toList());
  }
}
