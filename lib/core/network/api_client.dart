import 'package:dio/dio.dart';

import '../config/env.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Client HTTP central — seul point du code qui connaît l'URL de base, les en-têtes par
/// défaut et la traduction des erreurs Dio en [AppException]. Aucun repository ne doit
/// construire de requête HTTP en dehors de cette classe.
class ApiClient {
  ApiClient({
    required SecureStorageService secureStorage,
    required Future<void> Function() onUnauthenticated,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                // Réseau mobile faible : un timeout trop court transforme une simple lenteur
                // en erreur ; trop long, l'utilisateur reste bloqué sans retour. 15s pour les
                // requêtes normales, une valeur plus généreuse est passée explicitement pour
                // les uploads (voir postMultipart).
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      AuthInterceptor(secureStorage, onUnauthenticated: onUnauthenticated),
    );
  }

  final Dio _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _guard(() => _dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return _guard(() => _dio.post<T>(path, data: data));
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) {
    return _guard(() => _dio.patch<T>(path, data: data));
  }

  Future<Response<T>> delete<T>(String path, {Object? data}) {
    return _guard(() => _dio.delete<T>(path, data: data));
  }

  /// Upload multipart (image/vidéo) avec un timeout dédié, plus permissif que le reste de
  /// l'API — voir la contrainte de compression vidéo serveur (jusqu'à 1 Go en amont).
  Future<Response<T>> postMultipart<T>(String path, FormData data, {ProgressCallback? onSendProgress}) {
    return _guard(
      () => _dio.post<T>(
        path,
        data: data,
        onSendProgress: onSendProgress,
        options: Options(sendTimeout: const Duration(minutes: 5)),
      ),
    );
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  AppException _mapException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      default:
        break;
    }

    final response = e.response;
    if (response == null) {
      return const NetworkException();
    }

    final status = response.statusCode ?? 0;
    final body = response.data;
    final message = _extractMessage(body) ?? 'Une erreur est survenue. Réessayez.';

    if (status == 401) return UnauthenticatedException(message);
    if (status == 403) return ForbiddenException(message);
    if (status == 422) {
      return ServerException(message, statusCode: status, errors: _extractValidationErrors(body));
    }

    return ServerException(message, statusCode: status);
  }

  String? _extractMessage(Object? body) {
    if (body is Map && body['message'] is String) return body['message'] as String;
    return null;
  }

  Map<String, List<String>>? _extractValidationErrors(Object? body) {
    if (body is! Map || body['errors'] is! Map) return null;
    final errors = body['errors'] as Map;
    return errors.map(
      (key, value) => MapEntry(key.toString(), (value as List).map((e) => e.toString()).toList()),
    );
  }
}
