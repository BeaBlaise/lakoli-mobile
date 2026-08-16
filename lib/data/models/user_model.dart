import '../../domain/entities/user_entity.dart';

/// Parse la forme renvoyée par App\Http\Resources\UserResource. `phone`/`email` sont
/// `$this->when(...)` côté Laravel — absents du JSON (pas juste null) pour tout profil qui
/// n'est pas le sien, donc lus ici avec un accès optionnel plutôt qu'un champ requis.
class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.role,
    this.phone,
    this.email,
    this.avatarUrl,
    this.coverPhotoUrl,
    this.bio,
    this.activeRole,
    this.availableRoles = const [],
  });

  final String id;
  final String fullName;
  final String? role;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final String? coverPhotoUrl;
  final String? bio;
  final String? activeRole;
  final List<String> availableRoles;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      bio: json['bio'] as String?,
      // active_role / available_roles ne viennent pas encore de l'API mobile aujourd'hui —
      // UserResource ne les expose pas (contrairement à HandleInertiaRequests côté web).
      // Lus ici en tolérant leur absence : voir l'audit Phase 1, section bascule de profil.
      activeRole: json['active_role'] as String?,
      availableRoles: (json['available_roles'] as List?)?.cast<String>() ?? const [],
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      fullName: fullName,
      role: userRoleFromString(role),
      activeRole: activeRole != null ? userRoleFromString(activeRole) : null,
      availableRoles: availableRoles.map(userRoleFromString).toList(),
      phone: phone,
      email: email,
      avatarUrl: avatarUrl,
      coverPhotoUrl: coverPhotoUrl,
      bio: bio,
    );
  }
}
