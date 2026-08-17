import 'package:equatable/equatable.dart';

enum UserRole { user, ecole, admin }

UserRole userRoleFromString(String? value) => switch (value) {
      'ecole' => UserRole.ecole,
      'admin' => UserRole.admin,
      _ => UserRole.user,
    };

enum EcoleStatut { enAttente, validee, refusee }

EcoleStatut ecoleStatutFromString(String value) => switch (value) {
      'VALIDEE' => EcoleStatut.validee,
      'REFUSEE' => EcoleStatut.refusee,
      _ => EcoleStatut.enAttente,
    };

/// École de l'utilisateur courant — présent uniquement sur son propre profil (voir
/// App\Http\Resources\UserResource côté Laravel, `ecole` est self-only comme phone/email).
/// `statut` est ce qui permet de savoir si un compte école fraîchement inscrit est encore en
/// attente de validation admin — voir CreatePublicationPage/VideosPage, qui affichent un état
/// dédié plutôt qu'un formulaire de publication qui échouerait en 403.
class UserEcoleEntity extends Equatable {
  const UserEcoleEntity({required this.id, required this.nom, required this.statut});

  final String id;
  final String nom;
  final EcoleStatut statut;

  @override
  List<Object?> get props => [id, nom, statut];
}

/// Objet métier pur — ignore tout de la forme JSON de l'API. Voir data/models/user_model.dart
/// pour la conversion depuis/vers la réponse Laravel.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.role,
    this.activeRole,
    this.availableRoles = const [],
    this.phone,
    this.email,
    this.avatarUrl,
    this.coverPhotoUrl,
    this.bio,
    this.ecole,
    this.unreadNotificationsCount = 0,
    this.unreadCommunautesCount = 0,
    this.unreadMessagesCount = 0,
  });

  final String id;
  final String fullName;
  final UserRole role;

  /// Identité actuellement "portée" par le compte — distincte de [role] quand un compte
  /// école a basculé vers son profil personnel. Null tant que /auth/me n'a pas répondu.
  final UserRole? activeRole;
  final List<UserRole> availableRoles;

  final String? phone;
  final String? email;
  final String? avatarUrl;
  final String? coverPhotoUrl;
  final String? bio;
  final UserEcoleEntity? ecole;
  final int unreadNotificationsCount;
  final int unreadCommunautesCount;
  final int unreadMessagesCount;

  bool get canSwitchProfile => availableRoles.length > 1;

  @override
  List<Object?> get props => [
        id,
        fullName,
        role,
        activeRole,
        availableRoles,
        phone,
        email,
        avatarUrl,
        coverPhotoUrl,
        bio,
        ecole,
        unreadNotificationsCount,
        unreadCommunautesCount,
        unreadMessagesCount,
      ];
}
