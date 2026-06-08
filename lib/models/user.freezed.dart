// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get avatarUrl => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  List<String> get portfolioImages => throw _privateConstructorUsedError;
  String? get remarkName => throw _privateConstructorUsedError;
  int get followersCount => throw _privateConstructorUsedError;
  int get followingCount => throw _privateConstructorUsedError;
  bool get isFollowing => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  String? get birthday => throw _privateConstructorUsedError;
  bool get isProfileCompleted => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String id,
      String name,
      String avatarUrl,
      String bio,
      List<String> portfolioImages,
      String? remarkName,
      int followersCount,
      int followingCount,
      bool isFollowing,
      String gender,
      String? birthday,
      bool isProfileCompleted});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = null,
    Object? bio = null,
    Object? portfolioImages = null,
    Object? remarkName = freezed,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? isFollowing = null,
    Object? gender = null,
    Object? birthday = freezed,
    Object? isProfileCompleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: null == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      portfolioImages: null == portfolioImages
          ? _value.portfolioImages
          : portfolioImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      remarkName: freezed == remarkName
          ? _value.remarkName
          : remarkName // ignore: cast_nullable_to_non_nullable
              as String?,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String?,
      isProfileCompleted: null == isProfileCompleted
          ? _value.isProfileCompleted
          : isProfileCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String avatarUrl,
      String bio,
      List<String> portfolioImages,
      String? remarkName,
      int followersCount,
      int followingCount,
      bool isFollowing,
      String gender,
      String? birthday,
      bool isProfileCompleted});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = null,
    Object? bio = null,
    Object? portfolioImages = null,
    Object? remarkName = freezed,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? isFollowing = null,
    Object? gender = null,
    Object? birthday = freezed,
    Object? isProfileCompleted = null,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: null == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      portfolioImages: null == portfolioImages
          ? _value._portfolioImages
          : portfolioImages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      remarkName: freezed == remarkName
          ? _value.remarkName
          : remarkName // ignore: cast_nullable_to_non_nullable
              as String?,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String?,
      isProfileCompleted: null == isProfileCompleted
          ? _value.isProfileCompleted
          : isProfileCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      required this.name,
      required this.avatarUrl,
      required this.bio,
      final List<String> portfolioImages = const <String>[],
      this.remarkName,
      this.followersCount = 0,
      this.followingCount = 0,
      this.isFollowing = false,
      this.gender = 'male',
      this.birthday,
      this.isProfileCompleted = false})
      : _portfolioImages = portfolioImages;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String avatarUrl;
  @override
  final String bio;
  final List<String> _portfolioImages;
  @override
  @JsonKey()
  List<String> get portfolioImages {
    if (_portfolioImages is EqualUnmodifiableListView) return _portfolioImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_portfolioImages);
  }

  @override
  final String? remarkName;
  @override
  @JsonKey()
  final int followersCount;
  @override
  @JsonKey()
  final int followingCount;
  @override
  @JsonKey()
  final bool isFollowing;
  @override
  @JsonKey()
  final String gender;
  @override
  final String? birthday;
  @override
  @JsonKey()
  final bool isProfileCompleted;

  @override
  String toString() {
    return 'User(id: $id, name: $name, avatarUrl: $avatarUrl, bio: $bio, portfolioImages: $portfolioImages, remarkName: $remarkName, followersCount: $followersCount, followingCount: $followingCount, isFollowing: $isFollowing, gender: $gender, birthday: $birthday, isProfileCompleted: $isProfileCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality()
                .equals(other._portfolioImages, _portfolioImages) &&
            (identical(other.remarkName, remarkName) ||
                other.remarkName == remarkName) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.isProfileCompleted, isProfileCompleted) ||
                other.isProfileCompleted == isProfileCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      avatarUrl,
      bio,
      const DeepCollectionEquality().hash(_portfolioImages),
      remarkName,
      followersCount,
      followingCount,
      isFollowing,
      gender,
      birthday,
      isProfileCompleted);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String id,
      required final String name,
      required final String avatarUrl,
      required final String bio,
      final List<String> portfolioImages,
      final String? remarkName,
      final int followersCount,
      final int followingCount,
      final bool isFollowing,
      final String gender,
      final String? birthday,
      final bool isProfileCompleted}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get avatarUrl;
  @override
  String get bio;
  @override
  List<String> get portfolioImages;
  @override
  String? get remarkName;
  @override
  int get followersCount;
  @override
  int get followingCount;
  @override
  bool get isFollowing;
  @override
  String get gender;
  @override
  String? get birthday;
  @override
  bool get isProfileCompleted;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
