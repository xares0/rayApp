// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      mediaPath: json['mediaPath'] as String?,
      thumbnailPath: json['thumbnailPath'] as String?,
      voiceDurationSeconds: (json['voiceDurationSeconds'] as num?)?.toInt(),
      emojiLabel: json['emojiLabel'] as String?,
      sendStatus:
          $enumDecodeNullable(_$MessageSendStatusEnumMap, json['sendStatus']) ??
              MessageSendStatus.sent,
      hiddenForUserIds: (json['hiddenForUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      recalledByUserId: json['recalledByUserId'] as String?,
      recalledAt: json['recalledAt'] == null
          ? null
          : DateTime.parse(json['recalledAt'] as String),
      otherUser: json['otherUser'] == null
          ? null
          : User.fromJson(json['otherUser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'mediaPath': instance.mediaPath,
      'thumbnailPath': instance.thumbnailPath,
      'voiceDurationSeconds': instance.voiceDurationSeconds,
      'emojiLabel': instance.emojiLabel,
      'sendStatus': _$MessageSendStatusEnumMap[instance.sendStatus]!,
      'hiddenForUserIds': instance.hiddenForUserIds,
      'recalledByUserId': instance.recalledByUserId,
      'recalledAt': instance.recalledAt?.toIso8601String(),
      'otherUser': instance.otherUser,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.emoji: 'emoji',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.voice: 'voice',
  MessageType.recall: 'recall',
  MessageType.system: 'system',
};

const _$MessageSendStatusEnumMap = {
  MessageSendStatus.sending: 'sending',
  MessageSendStatus.sent: 'sent',
  MessageSendStatus.failed: 'failed',
};
