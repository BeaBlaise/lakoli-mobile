import '../../core/network/api_client.dart';
import '../models/commentaire_model.dart';

class CommentaireRemoteDataSource {
  CommentaireRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<CommentaireModel>> list(String publicationId) async {
    final response = await _client.get<Map<String, dynamic>>('/publications/$publicationId/commentaires');
    final commentaires = response.data!['commentaires'] as List;
    return commentaires.map((e) => CommentaireModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> create(String publicationId, String contenu, {String? parentId}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/publications/$publicationId/commentaires',
      data: {'contenu': contenu, if (parentId != null) 'parent_id': parentId},
    );
    return response.data!['id'] as String;
  }

  Future<void> delete(String commentaireId) => _client.delete<void>('/commentaires/$commentaireId');
}
