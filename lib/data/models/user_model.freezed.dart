// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get id;@JsonKey(name: 'full_name') String get fullName; String? get role; String? get phone; String? get email;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'cover_photo_url') String? get coverPhotoUrl; String? get bio;// UserResource (api) now exposes these for the authenticated user's own profile,
// matching HandleInertiaRequests on the web side (fixed 2026-08-16). Still nullable/
// defaulted since /ecoles, /publications, etc. embed other users' UserResource shapes
// without them ($this->when(... own profile only ...) on the Laravel side).
@JsonKey(name: 'active_role') String? get activeRole;@JsonKey(name: 'available_roles') List<String> get availableRoles;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.coverPhotoUrl, coverPhotoUrl) || other.coverPhotoUrl == coverPhotoUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.activeRole, activeRole) || other.activeRole == activeRole)&&const DeepCollectionEquality().equals(other.availableRoles, availableRoles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,role,phone,email,avatarUrl,coverPhotoUrl,bio,activeRole,const DeepCollectionEquality().hash(availableRoles));

@override
String toString() {
  return 'UserModel(id: $id, fullName: $fullName, role: $role, phone: $phone, email: $email, avatarUrl: $avatarUrl, coverPhotoUrl: $coverPhotoUrl, bio: $bio, activeRole: $activeRole, availableRoles: $availableRoles)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String? role, String? phone, String? email,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'cover_photo_url') String? coverPhotoUrl, String? bio,@JsonKey(name: 'active_role') String? activeRole,@JsonKey(name: 'available_roles') List<String> availableRoles
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? role = freezed,Object? phone = freezed,Object? email = freezed,Object? avatarUrl = freezed,Object? coverPhotoUrl = freezed,Object? bio = freezed,Object? activeRole = freezed,Object? availableRoles = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,coverPhotoUrl: freezed == coverPhotoUrl ? _self.coverPhotoUrl : coverPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,activeRole: freezed == activeRole ? _self.activeRole : activeRole // ignore: cast_nullable_to_non_nullable
as String?,availableRoles: null == availableRoles ? _self.availableRoles : availableRoles // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String? role,  String? phone,  String? email, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'cover_photo_url')  String? coverPhotoUrl,  String? bio, @JsonKey(name: 'active_role')  String? activeRole, @JsonKey(name: 'available_roles')  List<String> availableRoles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.role,_that.phone,_that.email,_that.avatarUrl,_that.coverPhotoUrl,_that.bio,_that.activeRole,_that.availableRoles);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String? role,  String? phone,  String? email, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'cover_photo_url')  String? coverPhotoUrl,  String? bio, @JsonKey(name: 'active_role')  String? activeRole, @JsonKey(name: 'available_roles')  List<String> availableRoles)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.fullName,_that.role,_that.phone,_that.email,_that.avatarUrl,_that.coverPhotoUrl,_that.bio,_that.activeRole,_that.availableRoles);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'full_name')  String fullName,  String? role,  String? phone,  String? email, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'cover_photo_url')  String? coverPhotoUrl,  String? bio, @JsonKey(name: 'active_role')  String? activeRole, @JsonKey(name: 'available_roles')  List<String> availableRoles)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.role,_that.phone,_that.email,_that.avatarUrl,_that.coverPhotoUrl,_that.bio,_that.activeRole,_that.availableRoles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({required this.id, @JsonKey(name: 'full_name') required this.fullName, this.role, this.phone, this.email, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'cover_photo_url') this.coverPhotoUrl, this.bio, @JsonKey(name: 'active_role') this.activeRole, @JsonKey(name: 'available_roles') final  List<String> availableRoles = const <String>[]}): _availableRoles = availableRoles,super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'full_name') final  String fullName;
@override final  String? role;
@override final  String? phone;
@override final  String? email;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'cover_photo_url') final  String? coverPhotoUrl;
@override final  String? bio;
// UserResource (api) now exposes these for the authenticated user's own profile,
// matching HandleInertiaRequests on the web side (fixed 2026-08-16). Still nullable/
// defaulted since /ecoles, /publications, etc. embed other users' UserResource shapes
// without them ($this->when(... own profile only ...) on the Laravel side).
@override@JsonKey(name: 'active_role') final  String? activeRole;
 final  List<String> _availableRoles;
@override@JsonKey(name: 'available_roles') List<String> get availableRoles {
  if (_availableRoles is EqualUnmodifiableListView) return _availableRoles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableRoles);
}


/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.coverPhotoUrl, coverPhotoUrl) || other.coverPhotoUrl == coverPhotoUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.activeRole, activeRole) || other.activeRole == activeRole)&&const DeepCollectionEquality().equals(other._availableRoles, _availableRoles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,role,phone,email,avatarUrl,coverPhotoUrl,bio,activeRole,const DeepCollectionEquality().hash(_availableRoles));

@override
String toString() {
  return 'UserModel(id: $id, fullName: $fullName, role: $role, phone: $phone, email: $email, avatarUrl: $avatarUrl, coverPhotoUrl: $coverPhotoUrl, bio: $bio, activeRole: $activeRole, availableRoles: $availableRoles)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String? role, String? phone, String? email,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'cover_photo_url') String? coverPhotoUrl, String? bio,@JsonKey(name: 'active_role') String? activeRole,@JsonKey(name: 'available_roles') List<String> availableRoles
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? role = freezed,Object? phone = freezed,Object? email = freezed,Object? avatarUrl = freezed,Object? coverPhotoUrl = freezed,Object? bio = freezed,Object? activeRole = freezed,Object? availableRoles = null,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,coverPhotoUrl: freezed == coverPhotoUrl ? _self.coverPhotoUrl : coverPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,activeRole: freezed == activeRole ? _self.activeRole : activeRole // ignore: cast_nullable_to_non_nullable
as String?,availableRoles: null == availableRoles ? _self._availableRoles : availableRoles // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
