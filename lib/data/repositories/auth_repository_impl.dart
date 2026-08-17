import '../../core/errors/app_exception.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  @override
  Future<Result<UserEntity>> register({required String phone, required String password, required String fullName}) {
    return _runAndPersist(() => _remote.register(phone: phone, password: password, fullName: fullName));
  }

  @override
  Future<Result<UserEntity>> registerEcole({
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
  }) {
    return _runAndPersist(() => _remote.registerEcole(
          nom: nom,
          phone: phone,
          password: password,
          typeEtablissement: typeEtablissement,
          region: region,
          prefecture: prefecture,
          commune: commune,
          quartier: quartier,
          email: email,
          description: description,
        ));
  }

  @override
  Future<Result<UserEntity>> login({required String phone, required String password}) {
    return _runAndPersist(() => _remote.login(phone: phone, password: password));
  }

  Future<Result<UserEntity>> _runAndPersist(Future<(UserModel, String)> Function() call) async {
    try {
      final (user, token) = await call();
      await _storage.saveToken(token);
      return Result.success(user.toEntity());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remote.logout();
    } on AppException {
      // Le token peut déjà être invalide côté serveur (expiré/révoqué ailleurs) — la
      // déconnexion locale doit réussir dans tous les cas, l'utilisateur veut sortir.
    } finally {
      await _storage.clearAll();
    }
    return const Result.success(null);
  }

  @override
  Future<Result<UserEntity>> currentUser() async {
    try {
      final user = await _remote.me();
      return Result.success(user.toEntity());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<bool> hasStoredSession() async {
    final token = await _storage.readToken();
    return token != null;
  }

  @override
  Future<Result<UserEntity>> switchActiveRole(UserRole role) async {
    try {
      final user = await _remote.switchActiveRole(_roleToString(role));
      return Result.success(user.toEntity());
    } on AppException catch (e) {
      return Result.failure(e);
    }
  }

  String _roleToString(UserRole role) => switch (role) {
        UserRole.user => 'user',
        UserRole.ecole => 'ecole',
        UserRole.admin => 'admin',
      };
}
