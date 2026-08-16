import 'package:flutter_test/flutter_test.dart';
import 'package:lakoli_mobile/data/models/publication_model.dart';

void main() {
  group('PublicationModel.fromJson', () {
    test('parses une publication organique (non sponsorisée)', () {
      final json = {
        'id': 'pub-1',
        'contenu': 'Rentrée des classes le 3 septembre.',
        'image_url': null,
        'images': <String>[],
        'created_at': '2026-08-10T08:00:00.000000Z',
        'ecole_id': 'ecole-1',
        'ecole': {'id': 'ecole-1', 'nom': 'École Kaloum', 'region': 'Conakry', 'photo_url': null},
        'likes_count': 4,
        'comments_count': 1,
        'user_liked': false,
        'sponsor_actif': false,
        'sponsor_statut': null,
        'sponsor_niveau': null,
        'sponsor_expire_at': null,
        'sponsor_vues': null,
      };

      final model = PublicationModel.fromJson(json);

      expect(model.contenu, 'Rentrée des classes le 3 septembre.');
      expect(model.ecole.nom, 'École Kaloum');
      expect(model.sponsorActif, isFalse);
      expect(model.likesCount, 4);
    });

    test('parses une publication sponsorisée — le client ne doit jamais inventer ce badge', () {
      final json = {
        'id': 'pub-2',
        'contenu': 'Portes ouvertes ce samedi.',
        'image_url': 'https://minio/photo.jpg',
        'images': <String>[],
        'created_at': '2026-08-10T08:00:00.000000Z',
        'ecole_id': 'ecole-2',
        'ecole': {'id': 'ecole-2', 'nom': 'Lycée Donka', 'region': 'Conakry', 'photo_url': 'https://minio/logo.jpg'},
        'likes_count': 12,
        'comments_count': 3,
        'user_liked': true,
        'sponsor_actif': true,
        'sponsor_niveau': 'NATIONAL',
        'sponsor_vues': 87,
      };

      final model = PublicationModel.fromJson(json);

      expect(model.sponsorActif, isTrue);
      expect(model.sponsorNiveau, 'NATIONAL');
      expect(model.sponsorVues, 87);
      expect(model.userLiked, isTrue);
    });

    test('toEntity() reporte fidèlement les champs sponsor', () {
      final model = PublicationModel.fromJson({
        'id': 'pub-3',
        'contenu': 'x',
        'created_at': '2026-08-10T08:00:00.000000Z',
        'ecole_id': 'ecole-3',
        'ecole': {'id': 'ecole-3', 'nom': 'X'},
        'sponsor_actif': true,
        'sponsor_niveau': 'REGIONAL',
      });

      final entity = model.toEntity();

      expect(entity.sponsorActif, isTrue);
      expect(entity.sponsorNiveau, 'REGIONAL');
      expect(entity.author.nom, 'X');
    });
  });
}
