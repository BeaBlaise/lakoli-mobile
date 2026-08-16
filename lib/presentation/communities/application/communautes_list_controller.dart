import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/communaute_entity.dart';
import '../../auth/application/auth_controller.dart';

final communautesListControllerProvider =
    AsyncNotifierProvider<CommunautesListController, List<CommunauteEntity>>(CommunautesListController.new);

class CommunautesListController extends AsyncNotifier<List<CommunauteEntity>> {
  @override
  Future<List<CommunauteEntity>> build() async {
    ref.watch(authControllerProvider);

    final result = await ref.read(communauteRepositoryProvider).list();
    return result.when(success: (list) => list, failure: (exception) => throw exception);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<CommunauteEntity>>();
    state = await AsyncValue.guard(() => build());
  }

  Future<String?> join(CommunauteEntity communaute) async {
    final current = state.valueOrNull;
    if (current == null) return null;

    final result = await ref.read(communauteRepositoryProvider).join(communaute.id);
    return result.when(
      success: (_) {
        state = AsyncData(_replace(current, communaute.copyWith(joined: true, membresCount: communaute.membresCount + 1)));
        return null;
      },
      failure: (exception) => exception.message,
    );
  }

  Future<void> leave(CommunauteEntity communaute) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final result = await ref.read(communauteRepositoryProvider).leave(communaute.id);
    result.when(
      success: (_) => state = AsyncData(
        _replace(current, communaute.copyWith(joined: false, membresCount: communaute.membresCount - 1, unreadCount: 0)),
      ),
      failure: (_) {},
    );
  }

  List<CommunauteEntity> _replace(List<CommunauteEntity> items, CommunauteEntity updated) {
    return items.map((c) => c.id == updated.id ? updated : c).toList();
  }
}
