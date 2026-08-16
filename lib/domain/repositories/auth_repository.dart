import '../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// Contrat métier — la présentation ne dépend que de ceci, jamais de la couche data
/// directement, pour pouvoir remplacer l'implémentation (ex. mock en test) sans y toucher.
abstract interface class AuthRepository {
  Future<Result<UserEntity>> register({required String phone, required String password, required String fullName});

  Future<Result<UserEntity>> login({required String phone, required String password});

  Future<Result<void>> logout();

  Future<Result<UserEntity>> currentUser();

  /// Session déjà connue en local (token stocké), sans appel réseau — utilisé au démarrage
  /// pour décider immédiatement de l'écran initial pendant que [currentUser] revalide.
  Future<bool> hasStoredSession();

  /// Bascule de profil (compte double-rôle utilisateur/école) — voir CLAUDE.md du dépôt lakoli,
  /// section "Bascule de profil". [role] doit être l'une des valeurs de [UserRole] déjà tenues
  /// par le compte (voir [UserEntity.availableRoles]) ; le serveur refuse sinon (403).
  Future<Result<UserEntity>> switchActiveRole(UserRole role);
}
