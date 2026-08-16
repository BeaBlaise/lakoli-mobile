import 'package:equatable/equatable.dart';

enum UserRole { user, ecole, admin }

UserRole userRoleFromString(String? value) => switch (value) {
      'ecole' => UserRole.ecole,
      'admin' => UserRole.admin,
      _ => UserRole.user,
    };

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

  bool get canSwitchProfile => availableRoles.length > 1;

  @override
  List<Object?> get props => [id, fullName, role, activeRole, availableRoles, phone, email, avatarUrl, coverPhotoUrl, bio];
}
