import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../domain/entities/geographie.dart';

/// GET /api/v1/geographie, chargé une fois (FutureProvider met en cache le résultat tant que
/// le provider n'est pas invalidé) — référentiel statique (8 régions, 46 préfectures, 380
/// communes), utilisé par le formulaire d'inscription école pour ses listes en cascade.
final geographieProvider = FutureProvider<List<RegionGeo>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get<Map<String, dynamic>>('/geographie');
  final regions = response.data!['regions'] as List;
  return regions.map((e) => RegionGeo.fromJson(e as Map<String, dynamic>)).toList();
});
