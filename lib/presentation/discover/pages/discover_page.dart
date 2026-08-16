import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/domain/ecole_card_view.dart';
import '../../shared/widgets/states/empty_state_view.dart';
import '../../shared/widgets/states/error_state_view.dart';
import '../application/discover_controller.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoverControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Découvrir')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: AppTextField(
              hint: 'Rechercher une école par son nom',
              suffixIcon: const Icon(Icons.search_rounded),
              onChanged: (value) => ref.read(discoverControllerProvider.notifier).search(value),
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: ErrorStateView(
                  exception: error is AppException ? error : UnexpectedResponseException(error.toString()),
                  onRetry: () => ref.invalidate(discoverControllerProvider),
                ),
              ),
              data: (data) {
                if (data.items.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.explore_outlined,
                    title: 'Aucune école trouvée',
                    message: 'Essayez un autre nom, ou parcourez plus tard quand de nouvelles écoles rejoignent Lakoli.',
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 400) {
                      ref.read(discoverControllerProvider.notifier).loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                    itemCount: data.items.length + (data.hasMore ? 1 : 0),
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      if (index >= data.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
                        );
                      }

                      final ecole = data.items[index];
                      final location = [ecole.commune, ecole.prefecture, ecole.region]
                          .firstWhere((p) => p != null, orElse: () => null);

                      return EcoleCardView(
                        nom: ecole.nom,
                        location: location,
                        onTap: () => context.push('/ecoles/${ecole.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
