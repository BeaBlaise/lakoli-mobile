import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';

/// Attache le token Sanctum à chaque requête et signale une session expirée/révoquée à
/// l'appelant — Sanctum n'a pas de refresh token (les personal access tokens n'expirent pas
/// par défaut côté serveur), donc "gérer l'expiration" ici veut dire : détecter le 401,
/// nettoyer le stockage local, et laisser la couche présentation rediriger vers la connexion.
/// Ne tente jamais de deviner une permission côté client — un 401/403 vient toujours du
/// backend, jamais d'une logique locale.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, {required this.onUnauthenticated});

  final SecureStorageService _storage;
  final Future<void> Function() onUnauthenticated;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.deleteToken();
      await onUnauthenticated();
    }
    handler.next(err);
  }
}
