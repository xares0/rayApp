import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ray_app/screens/main/main_skeleton.dart';

void main() {
  testWidgets('底部tab按区域平分，点击分区空白处也能切换页面', (tester) async {
    final router = GoRouter(
      initialLocation: '/style',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainSkeleton(child: child),
          routes: [
            GoRoute(
              path: '/style',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('style-page'))),
            ),
            GoRoute(
              path: '/discover',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('discover-page'))),
            ),
            GoRoute(
              path: '/messages',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('messages-page'))),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('profile-page'))),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('style-page'), findsOneWidget);

    final discoverTab = find.byKey(
      const ValueKey<String>('bottom_tab_/discover'),
    );
    final tabRect = tester.getRect(discoverTab);

    await tester.tapAt(Offset(tabRect.left + 6, tabRect.center.dy));
    await tester.pumpAndSettle();

    expect(find.text('discover-page'), findsOneWidget);
  });
}
