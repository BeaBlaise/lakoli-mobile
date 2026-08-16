import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/message_model.dart';
import '../../../domain/entities/message_entity.dart';

class ChatState {
  const ChatState({required this.messages, required this.canReply});

  final List<MessageEntity> messages;
  final bool canReply;

  ChatState copyWith({List<MessageEntity>? messages, bool? canReply}) {
    return ChatState(messages: messages ?? this.messages, canReply: canReply ?? this.canReply);
  }
}

final chatControllerProvider = AsyncNotifierProvider.family<ChatController, ChatState, String>(ChatController.new);

/// Un contrôleur par conversation ouverte (`family`). Temps réel via le canal privé
/// `conversation.{id}` (App\Events\MessageSent) — même remarque que
/// communaute_chat_controller.dart sur le décodage manuel de event.data.
class ChatController extends FamilyAsyncNotifier<ChatState, String> {
  PrivateChannel? _channel;
  StreamSubscription<ChannelReadEvent>? _subscription;

  @override
  Future<ChatState> build(String arg) async {
    ref.onDispose(_teardown);

    final result = await ref.read(messageRepositoryProvider).messages(arg);
    final state = result.when(
      success: (data) {
        final (messages, canReply) = data;
        return ChatState(messages: messages, canReply: canReply);
      },
      failure: (exception) => throw exception,
    );

    await _subscribeRealtime(arg);

    return state;
  }

  Future<void> _subscribeRealtime(String conversationId) async {
    final reverb = ref.read(reverbServiceProvider);
    await reverb.connect();

    final channel = await reverb.privateChannel('private-conversation.$conversationId');
    _channel = channel;
    _subscription = channel.bind('message.sent').listen(_onMessageSent);
    channel.subscribeIfNotUnsubscribed();
  }

  void _onMessageSent(ChannelReadEvent event) {
    final raw = event.data;
    final json = raw is String ? jsonDecode(raw) as Map<String, dynamic> : raw as Map<String, dynamic>;
    final message = MessageModel.fromJson(json).toEntity();

    final current = state.valueOrNull;
    if (current == null) return;
    if (current.messages.any((m) => m.id == message.id)) return;

    state = AsyncData(current.copyWith(messages: [...current.messages, message]));
  }

  Future<void> send(String contenu, {String? imagePath}) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final result = await ref.read(messageRepositoryProvider).sendMessage(arg, contenu, imagePath: imagePath);

    result.when(
      success: (message) {
        final latest = state.valueOrNull ?? current;
        if (latest.messages.any((m) => m.id == message.id)) return;
        state = AsyncData(latest.copyWith(messages: [...latest.messages, message]));
      },
      failure: (_) {},
    );
  }

  void _teardown() {
    _subscription?.cancel();
    _channel?.unsubscribe();
  }
}
