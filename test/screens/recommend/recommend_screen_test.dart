import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/recommend/recommend_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  testWidgets('点击推荐流头像会进入个人主页而不是聊天页', (tester) async {
    final router = GoRouter(
      initialLocation: '/recommend',
      routes: [
        GoRoute(
          path: '/recommend',
          builder: (context, state) => const RecommendScreen(),
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
        GoRoute(
          path: '/chat/:userId',
          builder: (context, state) =>
              Text('chat:${state.pathParameters['userId']}'),
        ),
        GoRoute(
          path: '/moment_detail/:id',
          builder: (context, state) =>
              Text('detail:${state.pathParameters['id']}'),
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
    expect(find.textContaining('chat:'), findsNothing);
  });
}
