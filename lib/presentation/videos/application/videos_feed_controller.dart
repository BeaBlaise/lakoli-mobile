import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/video_entity.dart';
import '../../auth/application/auth_controller.dart';

class VideosFeedState {
  const VideosFeedState({this.items = const [], this.nextPageUrl, this.isLoadingMore = false});

  final List<VideoEntity> items;
  final String? nextPageUrl;
  final bool isLoadingMore;

  bool get hasMore => nextPageUrl != null;

  VideosFeedState copyWith({List<VideoEntity>? items, String? nextPageUrl, bool clearNextPageUrl = false, bool? isLoadingMore}) {
    return VideosFeedState(
      items: items ?? this.items,
      nextPageUrl: clearNextPageUrl ? null : (nextPageUrl ?? this.nextPageUrl),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final videosFeedControllerProvider =
    AsyncNotifierProvider<VideosFeedController, VideosFeedState>(VideosFeedController.new);

class VideosFeedController extends AsyncNotifier<VideosFeedState> {
  @override
  Future<VideosFeedState> build() async {
    ref.watch(authControllerProvider);

    final result = await ref.read(videoRepositoryProvider).feed(page: 1);
    return result.when(
      success: (page) => VideosFeedState(items: page.items, nextPageUrl: page.nextPageUrl),
      failure: (exception) => throw exception,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<VideosFeedState>();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final uri = Uri.parse(current.nextPageUrl!);
    final page = int.tryParse(uri.queryParameters['page'] ?? '') ?? 1;
    final result = await ref.read(videoRepositoryProvider).feed(page: page);

    result.when(
      success: (data) => state = AsyncData(
        current.copyWith(
          items: [...current.items, ...data.items],
          nextPageUrl: data.nextPageUrl,
          clearNextPageUrl: data.nextPageUrl == null,
          isLoadingMore: false,
        ),
      ),
      failure: (_) => state = AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }

  Future<void> registerView(String videoId) {
    return ref.read(videoRepositoryProvider).incrementView(videoId);
  }
}
