import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    AuthRemoteDataSource(ref.watch(apiClientProvider)),
    ref.watch(secureStorageServiceProvider),
  );
});

final authControllerProvider = AsyncNotifierProvider<AuthController, UserEntity?>(AuthController.new);

/// État de session unique pour toute l'app — `null` veut dire "non connecté" (pas "en
/// chargement" : ça, c'est AsyncLoading, géré séparément par AsyncNotifier). Le router lit
/// cet état pour décider entre écrans publics et protégés (voir core/router/app_router.dart).
class AuthController extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    final repository = ref.watch(authRepositoryProvider);

    if (!await repository.hasStoredSession()) return null;

    // Un token existe localement mais peut avoir été révoqué côté serveur entre deux
    // lancements de l'app (déconnexion depuis un autre appareil, admin, etc.) — toujours
    // revalidé auprès de /auth/me plutôt que de faire confiance au seul stockage local.
    final result = await repository.currentUser();
    return result.when(success: (user) => user, failure: (_) => null);
  }

  Future<AppException?> login({required String phone, required String password}) async {
    state = const AsyncLoading<UserEntity?>().copyWithPrevious(state);
    final result = await ref.read(authRepositoryProvider).login(phone: phone, password: password);
    return result.when(
      success: (user) {
        state = AsyncData(user);
        return null;
      },
      failure: (exception) {
        state = AsyncData(state.valueOrNull);
        return exception;
      },
    );
  }

  Future<AppException?> register({required String phone, required String password, required String fullName}) async {
    state = const AsyncLoading<UserEntity?>().copyWithPrevious(state);
    final result = await ref
        .read(authRepositoryProvider)
        .register(phone: phone, password: password, fullName: fullName);
    return result.when(
      success: (user) {
        state = AsyncData(user);
        return null;
      },
      failure: (exception) {
        state = AsyncData(state.valueOrNull);
        return exception;
      },
    );
  }

  Future<AppException?> registerEcole({
    required String nom,
    required String phone,
    required String password,
    String? typeEtablissement,
    String? region,
    String? prefecture,
    String? commune,
    String? quartier,
    String? email,
    String? description,
  }) async {
    state = const AsyncLoading<UserEntity?>().copyWithPrevious(state);
    final result = await ref.read(authRepositoryProvider).registerEcole(
          nom: nom,
          phone: phone,
          password: password,
          typeEtablissement: typeEtablissement,
          region: region,
          prefecture: prefecture,
          commune: commune,
          quartier: quartier,
          email: email,
          description: description,
        );
    return result.when(
      success: (user) {
        state = AsyncData(user);
        return null;
      },
      failure: (exception) {
        state = AsyncData(state.valueOrNull);
        return exception;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  /// Appelé par ApiClient/AuthInterceptor quand un 401 arrive depuis n'importe quel appel
  /// réseau de l'app — pas seulement l'écran de connexion. Ne fait pas d'appel réseau
  /// supplémentaire : le token est déjà supprimé côté SecureStorageService par l'interceptor.
  Future<void> handleUnauthenticated() async {
    state = const AsyncData(null);
  }

  Future<AppException?> switchActiveRole(UserRole role) async {
    final previous = state.valueOrNull;
    state = const AsyncLoading<UserEntity?>().copyWithPrevious(state);
    final result = await ref.read(authRepositoryProvider).switchActiveRole(role);
    return result.when(
      success: (user) {
        state = AsyncData(user);
        return null;
      },
      failure: (exception) {
        state = AsyncData(previous);
        return exception;
      },
    );
  }
}
