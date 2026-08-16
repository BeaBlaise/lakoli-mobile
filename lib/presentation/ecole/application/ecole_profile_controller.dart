import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/ecole_entity.dart';

final ecoleProfileControllerProvider =
    AsyncNotifierProvider.family<EcoleProfileController, EcoleEntity, String>(EcoleProfileController.new);

/// Un contrôleur par école consultée (`family`) — l'app peut avoir plusieurs profils d'école en
/// mémoire à la fois en navigant dans le fil (voir feed_controller.dart, `onOpenEcole`).
class EcoleProfileController extends FamilyAsyncNotifier<EcoleEntity, String> {
  @override
  Future<EcoleEntity> build(String arg) async {
    final result = await ref.read(ecoleRepositoryProvider).show(arg);
    return result.when(success: (ecole) => ecole, failure: (exception) => throw exception);
  }

  Future<void> toggleFollow() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final repo = ref.read(ecoleRepositoryProvider);

    if (current.followStatus == FollowStatus.none) {
      final result = await repo.follow(arg);
      result.when(
        success: (status) => state = AsyncData(
          _withFollow(current, status, current.followersCount + (status == FollowStatus.accepted ? 1 : 0)),
        ),
        failure: (_) {},
      );
      return;
    }

    // "Envoyée" (pending) ou "Abonné" (accepted) : les deux se résolvent par un désabonnement —
    // annuler une demande en attente et se désabonner utilisent la même route côté API
    // (DELETE /ecoles/{ecole}/unfollow, voir CancelFollowAction côté Laravel, qui gère les
    // deux cas identiquement).
    final wasAccepted = current.followStatus == FollowStatus.accepted;
    final result = await repo.unfollow(arg);
    result.when(
      success: (_) => state = AsyncData(
        _withFollow(current, FollowStatus.none, current.followersCount - (wasAccepted ? 1 : 0)),
      ),
      failure: (_) {},
    );
  }

  EcoleEntity _withFollow(EcoleEntity ecole, FollowStatus status, int followersCount) {
    return EcoleEntity(
      id: ecole.id,
      nom: ecole.nom,
      region: ecole.region,
      prefecture: ecole.prefecture,
      commune: ecole.commune,
      description: ecole.description,
      phone: ecole.phone,
      email: ecole.email,
      photoUrl: ecole.photoUrl,
      coverPhotoUrl: ecole.coverPhotoUrl,
      typeEtablissement: ecole.typeEtablissement,
      isOwner: ecole.isOwner,
      followStatus: status,
      followersCount: followersCount,
    );
  }
}
