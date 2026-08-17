import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Parse la forme renvoyée par App\Http\Resources\UserResource. `phone`/`email`/`active_role`/
/// `available_roles` sont `$this->when(...)` côté Laravel — absents du JSON (pas juste null)
/// pour tout profil qui n'est pas le sien, donc lus ici avec un accès optionnel plutôt qu'un
/// champ requis.
///
/// Généré avec freezed + json_serializable (voir pubspec.yaml, "Génération de code") plutôt
/// qu'un fromJson()/toEntity() écrit à la main comme avant — élimine la classe de bugs "l'API
/// change de forme, le parsing manuel reste désynchronisé sans avertissement du compilateur".
/// Après toute modification des champs ci-dessous, régénérer avec :
///   dart run build_runner build --delete-conflicting-outputs
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    String? role,
    String? phone,
    String? email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'cover_photo_url') String? coverPhotoUrl,
    String? bio,
    // UserResource (api) now exposes these for the authenticated user's own profile,
    // matching HandleInertiaRequests on the web side (fixed 2026-08-16). Still nullable/
    // defaulted since /ecoles, /publications, etc. embed other users' UserResource shapes
    // without them ($this->when(... own profile only ...) on the Laravel side).
    @JsonKey(name: 'active_role') String? activeRole,
    @JsonKey(name: 'available_roles') @Default(<String>[]) List<String> availableRoles,
    // Idem : self-only côté Laravel (voir UserResource, ajouté 2026-08-17 pour que le mobile
    // puisse détecter une école fraîchement inscrite encore EN_ATTENTE de validation admin —
    // voir CreatePublicationPage/VideosPage). `ecole` reste une Map brute plutôt qu'une classe
    // freezed dédiée : trois champs, jamais manipulé ailleurs qu'ici, ne justifie pas une
    // nouvelle classe générée.
    Map<String, dynamic>? ecole,
    @JsonKey(name: 'unread_notifications_count') @Default(0) int unreadNotificationsCount,
    @JsonKey(name: 'unread_communautes_count') @Default(0) int unreadCommunautesCount,
    @JsonKey(name: 'unread_messages_count') @Default(0) int unreadMessagesCount,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

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
      ecole: ecole != null
          ? UserEcoleEntity(
              id: ecole!['id'] as String,
              nom: ecole!['nom'] as String,
              statut: ecoleStatutFromString(ecole!['statut'] as String),
            )
          : null,
      unreadNotificationsCount: unreadNotificationsCount,
      unreadCommunautesCount: unreadCommunautesCount,
      unreadMessagesCount: unreadMessagesCount,
    );
  }
}
