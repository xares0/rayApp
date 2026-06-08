import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../repositories/app_repository.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileUser extends _$ProfileUser {
  @override
  User build(String userId) {
    return AppRepository.instance.getUser(userId);
  }

  void toggleFollow() {
    final user = state;
    final isFollowing = user.isFollowing;
    state = user.copyWith(
      isFollowing: !isFollowing,
      followersCount: user.followersCount + (isFollowing ? -1 : 1),
    );
  }
}

@riverpod
class ProfilePosts extends _$ProfilePosts {
  @override
  List<Post> build(String userId) {
    return AppRepository.instance.getPostsForUser(userId);
  }
}
