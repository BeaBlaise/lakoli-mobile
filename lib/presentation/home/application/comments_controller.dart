import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/commentaire_entity.dart';
import '../../auth/application/auth_controller.dart';

final commentsControllerProvider =
    AsyncNotifierProvider.family<CommentsController, List<CommentaireEntity>, String>(CommentsController.new);

/// Un contrôleur par publication (`family`, clé = publicationId) — voir
/// ecole_profile_controller.dart pour le même choix et sa justification.
class CommentsController extends FamilyAsyncNotifier<List<CommentaireEntity>, String> {
  @override
  Future<List<CommentaireEntity>> build(String arg) async {
    final result = await ref.read(commentaireRepositoryProvider).list(arg);
    return result.when(success: (list) => list, failure: (exception) => throw exception);
  }

  /// [parentId] non-null pour répondre à un commentaire — un seul niveau de profondeur, voir
  /// CommentaireEntity ("un commentaire n'a qu'un seul niveau de réponses côté backend").
  Future<void> post(String contenu, {String? parentId}) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final me = ref.read(authControllerProvider).valueOrNull;
    if (me == null) return;

    final result = await ref.read(commentaireRepositoryProvider).create(arg, contenu, parentId: parentId);

    result.when(
      success: (id) {
        final optimistic = CommentaireEntity(
          id: id,
          contenu: contenu,
          createdAt: DateTime.now(),
          userId: me.id,
          userName: me.fullName,
          userAvatarUrl: me.avatarUrl,
          parentId: parentId,
        );

        if (parentId == null) {
          state = AsyncData([...current, optimistic]);
        } else {
          // Insère la réponse sous son commentaire parent plutôt qu'à la racine — la forme
          // organisée (replies imbriquées) doit rester cohérente avec ce que renverrait un
          // rechargement complet depuis l'API.
          state = AsyncData(
            current.map((c) {
              if (c.id != parentId) return c;
              return CommentaireEntity(
                id: c.id,
                contenu: c.contenu,
                createdAt: c.createdAt,
                userId: c.userId,
                userName: c.userName,
                userAvatarUrl: c.userAvatarUrl,
                parentId: c.parentId,
                replies: [...c.replies, optimistic],
              );
            }).toList(),
          );
        }
      },
      failure: (_) {},
    );
  }

  Future<void> delete(String commentaireId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final result = await ref.read(commentaireRepositoryProvider).delete(commentaireId);

    result.when(
      success: (_) {
        state = AsyncData(
          current
              .where((c) => c.id != commentaireId)
              .map((c) => CommentaireEntity(
                    id: c.id,
                    contenu: c.contenu,
                    createdAt: c.createdAt,
                    userId: c.userId,
                    userName: c.userName,
                    userAvatarUrl: c.userAvatarUrl,
                    parentId: c.parentId,
                    replies: c.replies.where((r) => r.id != commentaireId).toList(),
                  ))
              .toList(),
        );
      },
      failure: (_) {},
    );
  }
}
