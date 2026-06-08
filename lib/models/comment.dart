import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String postId,
    required String userId,
    required String content,
    required DateTime createdAt,
    @Default(0) int likesCount,
    // 二级回复：所属一级评论 id（null = 一级评论）
    String? parentId,
    // 被回复用户（「用户A 回复 用户B」中的 B）
    String? replyToUserId,
    String? replyToUserName,
    // Optional attached user data for hydration
    User? author,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}
