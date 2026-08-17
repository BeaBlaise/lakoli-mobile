import '../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Appels HTTP bruts, sans logique de stockage ni de mapping vers le domaine — c'est le
/// rôle du repository. Un datasource ne connaît que l'API.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<(UserModel, String)> register({required String phone, required String password, required String fullName}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'phone': phone, 'password': password, 'full_name': fullName},
    );
    final body = response.data!;
    return (UserModel.fromJson(body['user'] as Map<String, dynamic>), body['token'] as String);
  }

  /// Inscription école — voir domain/entities/ecole_registration.dart pour la justification :
  /// un flux distinct de register(), pas une variante, qui crée à la fois le rôle école et le
  /// rôle utilisateur.
  Future<(UserModel, String)> registerEcole({
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
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register-ecole',
      data: {
        'nom': nom,
        'phone': phone,
        'password': password,
        if (typeEtablissement != null) 'type_etablissement': typeEtablissement,
        if (region != null) 'region': region,
        if (prefecture != null) 'prefecture': prefecture,
        if (commune != null) 'commune': commune,
        if (quartier != null) 'quartier': quartier,
        if (email != null) 'email': email,
        if (description != null) 'description': description,
      },
    );
    final body = response.data!;
    return (UserModel.fromJson(body['user'] as Map<String, dynamic>), body['token'] as String);
  }

  Future<(UserModel, String)> login({required String phone, required String password}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
    final body = response.data!;
    return (UserModel.fromJson(body['user'] as Map<String, dynamic>), body['token'] as String);
  }

  Future<void> logout() => _client.post<void>('/auth/logout');

  Future<UserModel> me() async {
    final response = await _client.get<Map<String, dynamic>>('/auth/me');
    return UserModel.fromJson(response.data!['user'] as Map<String, dynamic>);
  }

  Future<UserModel> switchActiveRole(String role) async {
    final response = await _client.post<Map<String, dynamic>>('/profil/basculer', data: {'role': role});
    return UserModel.fromJson(response.data!['user'] as Map<String, dynamic>);
  }
}
