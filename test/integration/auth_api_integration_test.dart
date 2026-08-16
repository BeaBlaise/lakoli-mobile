import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lakoli_mobile/core/network/api_client.dart';
import 'package:lakoli_mobile/data/datasources/auth_remote_datasource.dart';

import '../fakes/fake_secure_storage_service.dart';

/// Test d'intégration réel — appelle le vrai serveur Laravel de développement
/// (php artisan serve sur 127.0.0.1:8000), pas un mock. Vérifie que le client réseau, les
/// intercepteurs et le parsing des modèles fonctionnent vraiment contre le backend, pas
/// seulement contre une forme JSON supposée.
///
/// Crée un compte jetable avec un numéro de téléphone unique à chaque exécution — n'écrit
/// jamais sur un compte existant. Nettoyer manuellement côté Laravel après coup :
///   php artisan tinker --execute="App\Models\User::where('full_name', 'Test Intégration Mobile')->delete();"
void main() {
  test('inscription puis /auth/me contre le vrai backend Laravel', () async {
    final storage = FakeSecureStorageService();
    final client = ApiClient(
      secureStorage: storage,
      onUnauthenticated: () async {},
      dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1', headers: {'Accept': 'application/json'})),
    );
    final dataSource = AuthRemoteDataSource(client);
    final uniquePhone = '699${DateTime.now().millisecondsSinceEpoch % 1000000}';

    final (registeredUser, token) = await dataSource.register(
      phone: uniquePhone,
      password: 'Password123!',
      fullName: 'Test Intégration Mobile',
    );

    expect(registeredUser.fullName, 'Test Intégration Mobile');
    expect(token, isNotEmpty);

    // /auth/me exige le token dans l'en-tête Authorization — vérifie que AuthInterceptor
    // l'attache bien depuis le stockage, pas seulement que l'endpoint existe.
    await storage.saveToken(token);
    final me = await dataSource.me();

    expect(me.id, registeredUser.id);
    expect(me.phone, uniquePhone);

    // Nettoyage : révoque le token créé par ce test (le compte lui-même est laissé pour
    // inspection manuelle si besoin — supprimé via la commande tinker documentée ci-dessus).
    await dataSource.logout();
  });
}
