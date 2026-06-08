import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/profile/subscreens/profile_followers_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  testWidgets('点击粉丝列表头像会进入个人主页', (tester) async {
    final router = GoRouter(
      initialLocation: '/profile_followers',
      routes: [
        GoRoute(
          path: '/profile_followers',
          builder: (context, state) => const ProfileFollowersScreen(),
        ),
        GoRoute(
          path: '/user_profile/:userId',
          builder: (context, state) =>
              Text('profile:${state.pathParameters['userId']}'),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const Text('profile:self'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CircleAvatar).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('profile:'), findsOneWidget);
  });
}
