import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String avatarUrl,
    required String bio,
    @Default(<String>[]) List<String> portfolioImages,
    String? remarkName,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(false) bool isFollowing,
    @Default('male') String gender,
    String? birthday,
    @Default(false) bool isProfileCompleted,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
