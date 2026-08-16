import 'package:flutter_test/flutter_test.dart';
import 'package:lakoli_mobile/data/models/user_model.dart';
import 'package:lakoli_mobile/domain/entities/user_entity.dart';

void main() {
  group('UserModel.fromJson', () {
    test('parses la forme réelle renvoyée par UserResource pour son propre profil', () {
      final json = {
        'id': '019f-abc',
        'full_name': 'Mariam Diallo',
        'phone': '620111222',
        'email': null,
        'avatar_url': null,
        'cover_photo_url': null,
        'bio': null,
        'role': 'user',
        'created_at': '2026-08-01T10:00:00.000000Z',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, '019f-abc');
      expect(model.fullName, 'Mariam Diallo');
      expect(model.phone, '620111222');
      expect(model.role, 'user');
    });

    test("tolère l'absence de phone/email (profil d'un autre utilisateur, when() renvoie false côté Laravel)", () {
      final json = {
        'id': '019f-def',
        'full_name': 'École Kaloum',
        'avatar_url': 'https://minio/kaloum.jpg',
        'role': 'ecole',
        'created_at': '2026-08-01T10:00:00.000000Z',
      };

      final model = UserModel.fromJson(json);

      expect(model.phone, isNull);
      expect(model.email, isNull);
      expect(model.avatarUrl, 'https://minio/kaloum.jpg');
    });

    test('toEntity() traduit le rôle texte en UserRole', () {
      final model = UserModel.fromJson({
        'id': '1',
        'full_name': 'X',
        'role': 'ecole',
        'created_at': '2026-08-01T10:00:00.000000Z',
      });

      expect(model.toEntity().role, UserRole.ecole);
    });
  });
}
