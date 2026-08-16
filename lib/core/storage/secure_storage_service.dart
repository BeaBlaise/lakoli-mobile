import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage sécurisé du token Sanctum — Keychain sur iOS, Keystore/EncryptedSharedPreferences
/// sur Android. Jamais dans shared_preferences en clair : c'est le seul secret que ce client
/// détient, et il donne accès au compte de l'utilisateur.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _activeRoleKey = 'active_role';

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  /// Mise en cache locale du rôle actif (bascule utilisateur/école) pour un affichage
  /// immédiat au démarrage, avant que /auth/me n'ait répondu — toujours revalidée contre
  /// la réponse serveur ensuite, jamais utilisée seule pour une décision de permission.
  Future<void> saveActiveRole(String role) => _storage.write(key: _activeRoleKey, value: role);

  Future<String?> readActiveRole() => _storage.read(key: _activeRoleKey);

  Future<void> clearAll() => _storage.deleteAll();
}
