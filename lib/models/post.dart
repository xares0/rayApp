import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    required String userId,
    required List<String> images,
    required String content,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    @Default(false) bool isLiked,
    required DateTime createdAt,
    // Optional video URL for video posts
    String? videoUrl,
    // Optional category for filtering (风景/人物/写真)
    String? category,
    // Optional attached user data for hydration
    User? author,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
