// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get receiverId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  String? get mediaPath => throw _privateConstructorUsedError;
  String? get thumbnailPath => throw _privateConstructorUsedError;
  int? get voiceDurationSeconds => throw _privateConstructorUsedError;
  String? get emojiLabel => throw _privateConstructorUsedError;
  MessageSendStatus get sendStatus => throw _privateConstructorUsedError;
  List<String> get hiddenForUserIds => throw _privateConstructorUsedError;
  String? get recalledByUserId => throw _privateConstructorUsedError;
  DateTime? get recalledAt =>
      throw _privateConstructorUsedError; // Attached user for list display
  User? get otherUser => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      String senderId,
      String receiverId,
      String content,
      DateTime createdAt,
      bool isRead,
      MessageType type,
      String? mediaPath,
      String? thumbnailPath,
      int? voiceDurationSeconds,
      String? emojiLabel,
      MessageSendStatus sendStatus,
      List<String> hiddenForUserIds,
      String? recalledByUserId,
      DateTime? recalledAt,
      User? otherUser});

  $UserCopyWith<$Res>? get otherUser;
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? type = null,
    Object? mediaPath = freezed,
    Object? thumbnailPath = freezed,
    Object? voiceDurationSeconds = freezed,
    Object? emojiLabel = freezed,
    Object? sendStatus = null,
    Object? hiddenForUserIds = null,
    Object? recalledByUserId = freezed,
    Object? recalledAt = freezed,
    Object? otherUser = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      mediaPath: freezed == mediaPath
          ? _value.mediaPath
          : mediaPath // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailPath: freezed == thumbnailPath
          ? _value.thumbnailPath
          : thumbnailPath // ignore: cast_nullable_to_non_nullable
              as String?,
      voiceDurationSeconds: freezed == voiceDurationSeconds
          ? _value.voiceDurationSeconds
          : voiceDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      emojiLabel: freezed == emojiLabel
          ? _value.emojiLabel
          : emojiLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      sendStatus: null == sendStatus
          ? _value.sendStatus
          : sendStatus // ignore: cast_nullable_to_non_nullable
              as MessageSendStatus,
      hiddenForUserIds: null == hiddenForUserIds
          ? _value.hiddenForUserIds
          : hiddenForUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recalledByUserId: freezed == recalledByUserId
          ? _value.recalledByUserId
          : recalledByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      recalledAt: freezed == recalledAt
          ? _value.recalledAt
          : recalledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      otherUser: freezed == otherUser
          ? _value.otherUser
          : otherUser // ignore: cast_nullable_to_non_nullable
              as User?,
    ) as $Val);
  }

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get otherUser {
    if (_value.otherUser == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.otherUser!, (value) {
      return _then(_value.copyWith(otherUser: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String senderId,
      String receiverId,
      String content,
      DateTime createdAt,
      bool isRead,
      MessageType type,
      String? mediaPath,
      String? thumbnailPath,
      int? voiceDurationSeconds,
      String? emojiLabel,
      MessageSendStatus sendStatus,
      List<String> hiddenForUserIds,
      String? recalledByUserId,
      DateTime? recalledAt,
      User? otherUser});

  @override
  $UserCopyWith<$Res>? get otherUser;
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? type = null,
    Object? mediaPath = freezed,
    Object? thumbnailPath = freezed,
    Object? voiceDurationSeconds = freezed,
    Object? emojiLabel = freezed,
    Object? sendStatus = null,
    Object? hiddenForUserIds = null,
    Object? recalledByUserId = freezed,
    Object? recalledAt = freezed,
    Object? otherUser = freezed,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      mediaPath: freezed == mediaPath
          ? _value.mediaPath
          : mediaPath // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailPath: freezed == thumbnailPath
          ? _value.thumbnailPath
          : thumbnailPath // ignore: cast_nullable_to_non_nullable
              as String?,
      voiceDurationSeconds: freezed == voiceDurationSeconds
          ? _value.voiceDurationSeconds
          : voiceDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      emojiLabel: freezed == emojiLabel
          ? _value.emojiLabel
          : emojiLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      sendStatus: null == sendStatus
          ? _value.sendStatus
          : sendStatus // ignore: cast_nullable_to_non_nullable
              as MessageSendStatus,
      hiddenForUserIds: null == hiddenForUserIds
          ? _value._hiddenForUserIds
          : hiddenForUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recalledByUserId: freezed == recalledByUserId
          ? _value.recalledByUserId
          : recalledByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      recalledAt: freezed == recalledAt
          ? _value.recalledAt
          : recalledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      otherUser: freezed == otherUser
          ? _value.otherUser
          : otherUser // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.senderId,
      required this.receiverId,
      required this.content,
      required this.createdAt,
      this.isRead = false,
      this.type = MessageType.text,
      this.mediaPath,
      this.thumbnailPath,
      this.voiceDurationSeconds,
      this.emojiLabel,
      this.sendStatus = MessageSendStatus.sent,
      final List<String> hiddenForUserIds = const <String>[],
      this.recalledByUserId,
      this.recalledAt,
      this.otherUser})
      : _hiddenForUserIds = hiddenForUserIds;

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String receiverId;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final MessageType type;
  @override
  final String? mediaPath;
  @override
  final String? thumbnailPath;
  @override
  final int? voiceDurationSeconds;
  @override
  final String? emojiLabel;
  @override
  @JsonKey()
  final MessageSendStatus sendStatus;
  final List<String> _hiddenForUserIds;
  @override
  @JsonKey()
  List<String> get hiddenForUserIds {
    if (_hiddenForUserIds is EqualUnmodifiableListView)
      return _hiddenForUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hiddenForUserIds);
  }

  @override
  final String? recalledByUserId;
  @override
  final DateTime? recalledAt;
// Attached user for list display
  @override
  final User? otherUser;

  @override
  String toString() {
    return 'Message(id: $id, senderId: $senderId, receiverId: $receiverId, content: $content, createdAt: $createdAt, isRead: $isRead, type: $type, mediaPath: $mediaPath, thumbnailPath: $thumbnailPath, voiceDurationSeconds: $voiceDurationSeconds, emojiLabel: $emojiLabel, sendStatus: $sendStatus, hiddenForUserIds: $hiddenForUserIds, recalledByUserId: $recalledByUserId, recalledAt: $recalledAt, otherUser: $otherUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.mediaPath, mediaPath) ||
                other.mediaPath == mediaPath) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            (identical(other.voiceDurationSeconds, voiceDurationSeconds) ||
                other.voiceDurationSeconds == voiceDurationSeconds) &&
            (identical(other.emojiLabel, emojiLabel) ||
                other.emojiLabel == emojiLabel) &&
            (identical(other.sendStatus, sendStatus) ||
                other.sendStatus == sendStatus) &&
            const DeepCollectionEquality()
                .equals(other._hiddenForUserIds, _hiddenForUserIds) &&
            (identical(other.recalledByUserId, recalledByUserId) ||
                other.recalledByUserId == recalledByUserId) &&
            (identical(other.recalledAt, recalledAt) ||
                other.recalledAt == recalledAt) &&
            (identical(other.otherUser, otherUser) ||
                other.otherUser == otherUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      senderId,
      receiverId,
      content,
      createdAt,
      isRead,
      type,
      mediaPath,
      thumbnailPath,
      voiceDurationSeconds,
      emojiLabel,
      sendStatus,
      const DeepCollectionEquality().hash(_hiddenForUserIds),
      recalledByUserId,
      recalledAt,
      otherUser);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      required final String senderId,
      required final String receiverId,
      required final String content,
      required final DateTime createdAt,
      final bool isRead,
      final MessageType type,
      final String? mediaPath,
      final String? thumbnailPath,
      final int? voiceDurationSeconds,
      final String? emojiLabel,
      final MessageSendStatus sendStatus,
      final List<String> hiddenForUserIds,
      final String? recalledByUserId,
      final DateTime? recalledAt,
      final User? otherUser}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get senderId;
  @override
  String get receiverId;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  bool get isRead;
  @override
  MessageType get type;
  @override
  String? get mediaPath;
  @override
  String? get thumbnailPath;
  @override
  int? get voiceDurationSeconds;
  @override
  String? get emojiLabel;
  @override
  MessageSendStatus get sendStatus;
  @override
  List<String> get hiddenForUserIds;
  @override
  String? get recalledByUserId;
  @override
  DateTime? get recalledAt; // Attached user for list display
  @override
  User? get otherUser;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
