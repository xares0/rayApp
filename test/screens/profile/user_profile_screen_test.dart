import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/profile/user_profile_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  Future<void> pumpUserProfileScreen(
    WidgetTester tester, {
    bool following = false,
  }) async {
    AppRepository.instance.setFollowing('u1', 'u2', following: following);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: UserProfileScreen(userId: 'u2'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('用户主页展示 Figma 关键区块和主操作按钮', (tester) async {
    await pumpUserProfileScreen(tester);

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(
      find.byKey(const ValueKey('userProfile.scrollView')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('userProfile.heroBlurBand')), findsOneWidget);
    expect(find.byKey(const ValueKey('userProfile.hero')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('userProfile.thumbnailStrip')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('userProfile.contentPanel')), findsOneWidget);
    expect(find.byKey(const ValueKey('userProfile.insightCard')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('userProfile.recentPostsCard')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('userProfile.followButton')), findsOneWidget);
    expect(find.byKey(const ValueKey('userProfile.chatButton')), findsOneWidget);
  });

  testWidgets('点击更多按钮会展示举报和拉黑悬浮菜单', (tester) async {
    await pumpUserProfileScreen(tester);

    await tester.tap(find.byKey(const ValueKey('userProfile.moreButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('userProfile.moreMenu')), findsOneWidget);
    expect(find.text('举报'), findsOneWidget);
    expect(find.text('拉黑'), findsOneWidget);
  });

  testWidgets('头像姓名行不会被顶部封面和模糊条遮挡', (tester) async {
    await pumpUserProfileScreen(tester);

    final blurBandRect = tester.getRect(
      find.byKey(const ValueKey('userProfile.heroBlurBand')),
    );
    final nameInPanel = find.descendant(
      of: find.byKey(const ValueKey('userProfile.contentPanel')),
      matching: find.text('Alice Wonders'),
    );
    final nameTop = tester.getTopLeft(nameInPanel).dy;

    expect(nameTop, greaterThanOrEqualTo(blurBandRect.bottom + 8));
  });

  testWidgets('已关注用户点击按钮会出现取关确认弹窗', (tester) async {
    await pumpUserProfileScreen(tester, following: true);

    expect(find.text('已关注'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('userProfile.followButton')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('userProfile.unfollowDialog')),
      findsOneWidget,
    );
    expect(find.text('温馨提示'), findsOneWidget);
    expect(find.text('是否取关此用户？'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('确认'), findsOneWidget);
  });

  testWidgets('点击近期投稿箭头会进入最近动态列表页', (tester) async {
    final router = GoRouter(
      initialLocation: '/user_profile/u2',
      routes: [
        GoRoute(
          path: '/user_profile/:userId',
          builder: (context, state) =>
              UserProfileScreen(userId: state.pathParameters['userId']!),
        ),
        GoRoute(
          path: '/user_posts/:userId',
          builder: (context, state) =>
              Text('posts:${state.pathParameters['userId']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('userProfile.recentPostsArrow')));
    await tester.pumpAndSettle();

    expect(find.text('posts:u2'), findsOneWidget);
  });
}
