import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/video_entity.dart';

final myVideosControllerProvider = AsyncNotifierProvider<MyVideosController, List<VideoEntity>>(MyVideosController.new);

class MyVideosController extends AsyncNotifier<List<VideoEntity>> {
  @override
  Future<List<VideoEntity>> build() async {
    final result = await ref.read(videoRepositoryProvider).myVideos();
    return result.when(success: (list) => list, failure: (exception) => throw exception);
  }

  Future<String?> upload(String videoPath, {String? contenu}) async {
    final current = state.valueOrNull;
    if (current == null) return null;

    final result = await ref.read(videoRepositoryProvider).upload(videoPath, contenu: contenu);
    return result.when(
      success: (video) {
        state = AsyncData([video, ...current]);
        return null;
      },
      failure: (exception) => exception.message,
    );
  }

  Future<void> delete(String videoId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final result = await ref.read(videoRepositoryProvider).delete(videoId);
    result.when(
      success: (_) => state = AsyncData(current.where((v) => v.id != videoId).toList()),
      failure: (_) {},
    );
  }
}
