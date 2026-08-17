import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/ecole_dashboard_entity.dart';
import '../../auth/application/auth_controller.dart';

final ecoleDashboardControllerProvider =
    AsyncNotifierProvider<EcoleDashboardController, EcoleDashboardEntity>(EcoleDashboardController.new);

class EcoleDashboardController extends AsyncNotifier<EcoleDashboardEntity> {
  @override
  Future<EcoleDashboardEntity> build() async {
    ref.watch(authControllerProvider);

    final result = await ref.read(ecoleDashboardRepositoryProvider).fetch();
    return result.when(success: (data) => data, failure: (exception) => throw exception);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<EcoleDashboardEntity>();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> acceptFollowRequest(FollowRequestEntity request) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWithoutRequest(request.id));

    final result = await ref.read(ecoleDashboardRepositoryProvider).acceptFollowRequest(request.id);
    result.when(
      success: (_) {},
      failure: (_) => refresh(),
    );
  }

  Future<void> refuseFollowRequest(FollowRequestEntity request) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWithoutRequest(request.id));

    final result = await ref.read(ecoleDashboardRepositoryProvider).refuseFollowRequest(request.id);
    result.when(
      success: (_) {},
      failure: (_) => refresh(),
    );
  }
}
