// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  role: json['role'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  coverPhotoUrl: json['cover_photo_url'] as String?,
  bio: json['bio'] as String?,
  activeRole: json['active_role'] as String?,
  availableRoles:
      (json['available_roles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  ecole: json['ecole'] as Map<String, dynamic>?,
  unreadNotificationsCount:
      (json['unread_notifications_count'] as num?)?.toInt() ?? 0,
  unreadCommunautesCount:
      (json['unread_communautes_count'] as num?)?.toInt() ?? 0,
  unreadMessagesCount: (json['unread_messages_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'role': instance.role,
      'phone': instance.phone,
      'email': instance.email,
      'avatar_url': instance.avatarUrl,
      'cover_photo_url': instance.coverPhotoUrl,
      'bio': instance.bio,
      'active_role': instance.activeRole,
      'available_roles': instance.availableRoles,
      'ecole': instance.ecole,
      'unread_notifications_count': instance.unreadNotificationsCount,
      'unread_communautes_count': instance.unreadCommunautesCount,
      'unread_messages_count': instance.unreadMessagesCount,
    };
