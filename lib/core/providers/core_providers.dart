import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/auth/application/auth_controller.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// L'ApiClient a besoin de pouvoir déclencher une déconnexion locale sur un 401 venant de
/// n'importe quel appel réseau, pas seulement ceux de l'écran de connexion — d'où la
/// dépendance vers authControllerProvider ici plutôt que l'inverse.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    secureStorage: ref.watch(secureStorageServiceProvider),
    onUnauthenticated: () => ref.read(authControllerProvider.notifier).handleUnauthenticated(),
  );
});
