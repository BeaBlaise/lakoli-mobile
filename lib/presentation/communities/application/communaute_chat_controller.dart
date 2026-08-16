import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/communaute_post_model.dart';
import '../../../domain/entities/communaute_post_entity.dart';

final communauteChatControllerProvider =
    AsyncNotifierProvider.family<CommunauteChatController, List<CommunautePostEntity>, String>(CommunauteChatController.new);

/// Un contrôleur par communauté ouverte (`family`). Temps réel via le canal privé
/// `communaute.{id}` (voir App\Events\CommunautePostCreated côté Laravel) — dart_pusher_channels
/// est un client bas niveau, contrairement à Laravel Echo côté web : `event.data` arrive comme
/// une chaîne JSON encodée (protocole Pusher standard), pas déjà décodée en Map, donc un
/// jsonDecode() manuel est nécessaire ici (voir _onPostCreated).
class CommunauteChatController extends FamilyAsyncNotifier<List<CommunautePostEntity>, String> {
  PrivateChannel? _channel;
  StreamSubscription<ChannelReadEvent>? _subscription;

  @override
  Future<List<CommunautePostEntity>> build(String arg) async {
    ref.onDispose(_teardown);

    final result = await ref.read(communauteRepositoryProvider).messages(arg);
    final posts = result.when(success: (list) => list, failure: (exception) => throw exception);

    await _subscribeRealtime(arg);

    return posts;
  }

  Future<void> _subscribeRealtime(String communauteId) async {
    final reverb = ref.read(reverbServiceProvider);
    await reverb.connect();

    final channel = await reverb.privateChannel('private-communaute.$communauteId');
    _channel = channel;
    _subscription = channel.bind('post.created').listen(_onPostCreated);
    channel.subscribeIfNotUnsubscribed();
  }

  void _onPostCreated(ChannelReadEvent event) {
    final raw = event.data;
    final json = raw is String ? jsonDecode(raw) as Map<String, dynamic> : raw as Map<String, dynamic>;
    final post = CommunautePostModel.fromJson(json).toEntity();

    final current = state.valueOrNull;
    if (current == null) return;
    // Un message envoyé par ce même appareil arrive aussi via ce canal (Reverb rediffuse à
    // tous les abonnés, y compris l'émetteur) — évite un doublon avec la mise à jour optimiste
    // déjà faite par sendMessage().
    if (current.any((p) => p.id == post.id)) return;

    state = AsyncData([...current, post]);
  }

  Future<void> sendMessage(String contenu, {String? imagePath, String? replyToId}) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final result = await ref
        .read(communauteRepositoryProvider)
        .postMessage(arg, contenu, imagePath: imagePath, replyToId: replyToId);

    result.when(
      success: (post) {
        final latest = state.valueOrNull ?? current;
        if (latest.any((p) => p.id == post.id)) return;
        state = AsyncData([...latest, post]);
      },
      failure: (_) {},
    );
  }

  Future<void> toggleLike(CommunautePostEntity post) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final optimistic = post.copyWith(
      userLiked: !post.userLiked,
      likesCount: post.userLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    state = AsyncData(_replace(current, optimistic));

    final repo = ref.read(communauteRepositoryProvider);
    final result = optimistic.userLiked ? await repo.like(post.id) : await repo.unlike(post.id);

    result.when(
      success: (counts) {
        final (likesCount, userLiked) = counts;
        final latest = state.valueOrNull;
        if (latest == null) return;
        state = AsyncData(_replace(latest, post.copyWith(likesCount: likesCount, userLiked: userLiked)));
      },
      failure: (_) {
        final latest = state.valueOrNull;
        if (latest == null) return;
        state = AsyncData(_replace(latest, post));
      },
    );
  }

  Future<void> deleteMessage(String postId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final result = await ref.read(communauteRepositoryProvider).deleteMessage(postId);
    result.when(
      success: (_) => state = AsyncData(current.where((p) => p.id != postId).toList()),
      failure: (_) {},
    );
  }

  List<CommunautePostEntity> _replace(List<CommunautePostEntity> items, CommunautePostEntity updated) {
    return items.map((p) => p.id == updated.id ? updated : p).toList();
  }

  void _teardown() {
    _subscription?.cancel();
    _channel?.unsubscribe();
  }
}
