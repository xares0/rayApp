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
  String get bioOriginal => throw _privateConstructorUsedError;
  List<String> get portfolioImages => throw _privateConstructorUsedError;
  String? get remarkName => throw _privateConstructorUsedError;
  int get followersCount => throw _privateConstructorUsedError;
  int get followingCount => throw _privateConstructorUsedError;
  bool get isFollowing => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  String? get birthday => throw _privateConstructorUsedError;
  bool get isProfileCompleted =>
      throw _privateConstructorUsedError; // 第四次迭代「用户信息字段显示」：以接口返回为准，null 表示未返回不显示
  String? get nationality =>
      throw _privateConstructorUsedError; // 国籍（中文国名，如「中国」「越南」）
  bool? get isOnline => throw _privateConstructorUsedError; // 在线状态
  int? get heightCm => throw _privateConstructorUsedError; // 身高（cm）
  int? get weightKg => throw _privateConstructorUsedError; // 体重（kg）
  String? get displayId => throw _privateConstructorUsedError;

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
      String bioOriginal,
      List<String> portfolioImages,
      String? remarkName,
      int followersCount,
      int followingCount,
      bool isFollowing,
      String gender,
      String? birthday,
      bool isProfileCompleted,
      String? nationality,
      bool? isOnline,
      int? heightCm,
      int? weightKg,
      String? displayId});
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
    Object? bioOriginal = null,
    Object? portfolioImages = null,
    Object? remarkName = freezed,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? isFollowing = null,
    Object? gender = null,
    Object? birthday = freezed,
    Object? isProfileCompleted = null,
    Object? nationality = freezed,
    Object? isOnline = freezed,
    Object? heightCm = freezed,
    Object? weightKg = freezed,
    Object? displayId = freezed,
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
      bioOriginal: null == bioOriginal
          ? _value.bioOriginal
          : bioOriginal // ignore: cast_nullable_to_non_nullable
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
      nationality: freezed == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: freezed == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool?,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as int?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as int?,
      displayId: freezed == displayId
          ? _value.displayId
          : displayId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      String bioOriginal,
      List<String> portfolioImages,
      String? remarkName,
      int followersCount,
      int followingCount,
      bool isFollowing,
      String gender,
      String? birthday,
      bool isProfileCompleted,
      String? nationality,
      bool? isOnline,
      int? heightCm,
      int? weightKg,
      String? displayId});
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
    Object? bioOriginal = null,
    Object? portfolioImages = null,
    Object? remarkName = freezed,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? isFollowing = null,
    Object? gender = null,
    Object? birthday = freezed,
    Object? isProfileCompleted = null,
    Object? nationality = freezed,
    Object? isOnline = freezed,
    Object? heightCm = freezed,
    Object? weightKg = freezed,
    Object? displayId = freezed,
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
      bioOriginal: null == bioOriginal
          ? _value.bioOriginal
          : bioOriginal // ignore: cast_nullable_to_non_nullable
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
      nationality: freezed == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: freezed == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool?,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as int?,
      weightKg: freezed == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as int?,
      displayId: freezed == displayId
          ? _value.displayId
          : displayId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      this.bioOriginal = '',
      final List<String> portfolioImages = const <String>[],
      this.remarkName,
      this.followersCount = 0,
      this.followingCount = 0,
      this.isFollowing = false,
      this.gender = 'male',
      this.birthday,
      this.isProfileCompleted = false,
      this.nationality,
      this.isOnline,
      this.heightCm,
      this.weightKg,
      this.displayId})
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
  @override
  @JsonKey()
  final String bioOriginal;
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
// 第四次迭代「用户信息字段显示」：以接口返回为准，null 表示未返回不显示
  @override
  final String? nationality;
// 国籍（中文国名，如「中国」「越南」）
  @override
  final bool? isOnline;
// 在线状态
  @override
  final int? heightCm;
// 身高（cm）
  @override
  final int? weightKg;
// 体重（kg）
  @override
  final String? displayId;

  @override
  String toString() {
    return 'User(id: $id, name: $name, avatarUrl: $avatarUrl, bio: $bio, bioOriginal: $bioOriginal, portfolioImages: $portfolioImages, remarkName: $remarkName, followersCount: $followersCount, followingCount: $followingCount, isFollowing: $isFollowing, gender: $gender, birthday: $birthday, isProfileCompleted: $isProfileCompleted, nationality: $nationality, isOnline: $isOnline, heightCm: $heightCm, weightKg: $weightKg, displayId: $displayId)';
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
            (identical(other.bioOriginal, bioOriginal) ||
                other.bioOriginal == bioOriginal) &&
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
                other.isProfileCompleted == isProfileCompleted) &&
            (identical(other.nationality, nationality) ||
                other.nationality == nationality) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.displayId, displayId) ||
                other.displayId == displayId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      avatarUrl,
      bio,
      bioOriginal,
      const DeepCollectionEquality().hash(_portfolioImages),
      remarkName,
      followersCount,
      followingCount,
      isFollowing,
      gender,
      birthday,
      isProfileCompleted,
      nationality,
      isOnline,
      heightCm,
      weightKg,
      displayId);

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
      final String bioOriginal,
      final List<String> portfolioImages,
      final String? remarkName,
      final int followersCount,
      final int followingCount,
      final bool isFollowing,
      final String gender,
      final String? birthday,
      final bool isProfileCompleted,
      final String? nationality,
      final bool? isOnline,
      final int? heightCm,
      final int? weightKg,
      final String? displayId}) = _$UserImpl;

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
  String get bioOriginal;
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
  bool get isProfileCompleted; // 第四次迭代「用户信息字段显示」：以接口返回为准，null 表示未返回不显示
  @override
  String? get nationality; // 国籍（中文国名，如「中国」「越南」）
  @override
  bool? get isOnline; // 在线状态
  @override
  int? get heightCm; // 身高（cm）
  @override
  int? get weightKg; // 体重（kg）
  @override
  String? get displayId;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
