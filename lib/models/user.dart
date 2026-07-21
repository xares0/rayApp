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
    @Default('') String bioOriginal,
    @Default(<String>[]) List<String> portfolioImages,
    String? remarkName,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(false) bool isFollowing,
    @Default('male') String gender,
    String? birthday,
    @Default(false) bool isProfileCompleted,
    // 第四次迭代「用户信息字段显示」：以接口返回为准，null 表示未返回不显示
    String? nationality, // 国籍（中文国名，如「中国」「越南」）
    bool? isOnline, // 在线状态
    int? heightCm, // 身高（cm）
    int? weightKg, // 体重（kg）
    String? displayId, // 展示用 ID（如「1123456」）
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
