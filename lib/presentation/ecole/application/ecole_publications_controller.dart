import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/publication_entity.dart';
import '../../auth/application/auth_controller.dart';

final ecolePublicationsControllerProvider =
    AsyncNotifierProvider<EcolePublicationsController, List<PublicationEntity>>(EcolePublicationsController.new);

/// Publications de l'école courante, pour son propre tableau de bord — réutilise GET
/// /api/v1/ecoles/{ecole}/publications (voir PublicationRepository.listForEcole).
class EcolePublicationsController extends AsyncNotifier<List<PublicationEntity>> {
  @override
  Future<List<PublicationEntity>> build() async {
    final me = ref.watch(authControllerProvider).valueOrNull;
    final ecoleId = me?.ecole?.id;
    if (ecoleId == null) return [];

    final result = await ref.read(publicationRepositoryProvider).listForEcole(ecoleId);
    return result.when(success: (page) => page.items, failure: (exception) => throw exception);
  }

  Future<void> delete(String publicationId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final result = await ref.read(publicationRepositoryProvider).delete(publicationId);
    result.when(
      success: (_) => state = AsyncData(current.where((p) => p.id != publicationId).toList()),
      failure: (_) {},
    );
  }
}
