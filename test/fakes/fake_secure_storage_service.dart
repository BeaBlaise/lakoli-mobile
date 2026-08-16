import 'package:lakoli_mobile/core/storage/secure_storage_service.dart';

/// Stockage en mémoire pour les tests — évite de dépendre du canal de plateforme réel de
/// flutter_secure_storage, qui n'a pas d'implémentation disponible dans l'environnement de
/// test (ni Keychain iOS ni Keystore Android n'existent en `flutter test`).
class FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> saveToken(String token) async => _store['auth_token'] = token;

  @override
  Future<String?> readToken() async => _store['auth_token'];

  @override
  Future<void> deleteToken() async => _store.remove('auth_token');

  @override
  Future<void> saveActiveRole(String role) async => _store['active_role'] = role;

  @override
  Future<String?> readActiveRole() async => _store['active_role'];

  @override
  Future<void> clearAll() async => _store.clear();
}
