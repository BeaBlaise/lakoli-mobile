import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lakoli_mobile/core/errors/app_exception.dart';
import 'package:lakoli_mobile/data/datasources/auth_remote_datasource.dart';
import 'package:lakoli_mobile/data/models/user_model.dart';
import 'package:lakoli_mobile/data/repositories/auth_repository_impl.dart';

import '../../fakes/fake_secure_storage_service.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource remote;
  late FakeSecureStorageService storage;
  late AuthRepositoryImpl repository;

  const user = UserModel(id: '1', fullName: 'Mariam Diallo', role: 'user', phone: '620111222');

  setUp(() {
    remote = MockAuthRemoteDataSource();
    storage = FakeSecureStorageService();
    repository = AuthRepositoryImpl(remote, storage);
  });

  group('login', () {
    test('sur succès, sauvegarde le token et renvoie l\'utilisateur', () async {
      when(() => remote.login(phone: '620111222', password: 'secret'))
          .thenAnswer((_) async => (user, 'plain-text-token'));

      final result = await repository.login(phone: '620111222', password: 'secret');

      expect(result.isSuccess, isTrue);
      result.when(
        success: (u) => expect(u.fullName, 'Mariam Diallo'),
        failure: (_) => fail('devait réussir'),
      );
      expect(await storage.readToken(), 'plain-text-token');
    });

    test('sur identifiants incorrects (422), ne stocke aucun token et renvoie l\'erreur', () async {
      when(() => remote.login(phone: '620111222', password: 'faux'))
          .thenThrow(const ServerException('Identifiants incorrects.', statusCode: 422));

      final result = await repository.login(phone: '620111222', password: 'faux');

      expect(result.isSuccess, isFalse);
      expect(await storage.readToken(), isNull);
    });
  });

  group('logout', () {
    test('nettoie le stockage local même si l\'appel réseau échoue (token déjà invalide côté serveur)', () async {
      await storage.saveToken('ancien-token');
      when(() => remote.logout()).thenThrow(const UnauthenticatedException());

      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      expect(await storage.readToken(), isNull);
    });
  });

  group('hasStoredSession', () {
    test('faux tant qu\'aucun token n\'a été sauvegardé', () async {
      expect(await repository.hasStoredSession(), isFalse);
    });

    test('vrai une fois un token stocké', () async {
      await storage.saveToken('token');
      expect(await repository.hasStoredSession(), isTrue);
    });
  });
}
