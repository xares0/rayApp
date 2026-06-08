import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/core/router/app_router.dart';
import 'package:ray_app/models/user.dart';

void main() {
  const incompleteUser = User(
    id: 'u1',
    name: 'Test User',
    avatarUrl: 'avatar.png',
    bio: 'bio',
    isProfileCompleted: false,
  );

  const completedUser = User(
    id: 'u1',
    name: 'Test User',
    avatarUrl: 'avatar.png',
    bio: 'bio',
    isProfileCompleted: true,
  );

  group('appInitialLocation', () {
    test('未登录用户默认进入登录页', () {
      expect(appInitialLocation(null), '/login');
    });

    test('未完善资料用户默认进入完善资料页', () {
      expect(appInitialLocation(incompleteUser), '/profile_setup');
    });

    test('已完善资料用户默认进入首页', () {
      expect(appInitialLocation(completedUser), '/style');
    });
  });

  group('resolveAppAuthRedirect', () {
    test('未登录访问受保护页面会跳登录页', () {
      expect(resolveAppAuthRedirect(null, '/style'), '/login');
    });

    test('未完善资料用户访问首页会跳完善资料页', () {
      expect(
        resolveAppAuthRedirect(incompleteUser, '/style'),
        '/profile_setup',
      );
    });

    test('未完善资料用户停留在完善资料页时不再跳转', () {
      expect(resolveAppAuthRedirect(incompleteUser, '/profile_setup'), isNull);
    });

    test('已完善资料用户再进完善资料页会回首页', () {
      expect(resolveAppAuthRedirect(completedUser, '/profile_setup'), '/style');
    });

    test('已完善资料用户可以正常留在首页', () {
      expect(resolveAppAuthRedirect(completedUser, '/style'), isNull);
    });

    test('已登录用户可以正常进入协议页', () {
      expect(resolveAppAuthRedirect(completedUser, '/agreement/user'), isNull);
      expect(
        resolveAppAuthRedirect(completedUser, '/agreement/privacy'),
        isNull,
      );
    });
  });
}
