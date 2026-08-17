import '../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// Contrat métier — la présentation ne dépend que de ceci, jamais de la couche data
/// directement, pour pouvoir remplacer l'implémentation (ex. mock en test) sans y toucher.
abstract interface class AuthRepository {
  Future<Result<UserEntity>> register({required String phone, required String password, required String fullName});

  /// Distinct de [register] — crée à la fois un rôle école et un rôle utilisateur, plus une
  /// école en attente de validation admin. Voir Api\V1\AuthController::registerEcole() côté
  /// Laravel.
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
  });

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
