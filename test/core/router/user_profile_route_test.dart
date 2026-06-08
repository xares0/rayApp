import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/core/router/user_profile_route.dart';

void main() {
  test('点击他人头像时进入用户详情页', () {
    expect(
      resolveUserProfileRoute(userId: 'u2', currentUserId: 'u1'),
      '/user_profile/u2',
    );
  });

  test('点击自己的头像时进入我的页面', () {
    expect(
      resolveUserProfileRoute(userId: 'u1', currentUserId: 'u1'),
      '/profile',
    );
  });
}
