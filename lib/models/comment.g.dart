// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      parentId: json['parentId'] as String?,
      replyToUserId: json['replyToUserId'] as String?,
      replyToUserName: json['replyToUserName'] as String?,
      author: json['author'] == null
          ? null
          : User.fromJson(json['author'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'userId': instance.userId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'likesCount': instance.likesCount,
      'parentId': instance.parentId,
      'replyToUserId': instance.replyToUserId,
      'replyToUserName': instance.replyToUserName,
      'author': instance.author,
    };
