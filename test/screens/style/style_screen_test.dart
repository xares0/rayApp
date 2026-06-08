import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/style/style_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.setCurrentUser('');
  });

  Future<void> pumpStyleScreen(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: StyleScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('点击顶部分类会切到关注占位态', (tester) async {
    await pumpStyleScreen(tester);

    expect(find.text('暂无关注'), findsNothing);

    await tester.tap(find.text('关注'));
    await tester.pumpAndSettle();

    expect(find.text('暂无关注'), findsOneWidget);
  });

  testWidgets('横向滑动内容区会切到关注分类', (tester) async {
    await pumpStyleScreen(tester);

    expect(find.text('暂无关注'), findsNothing);

    await tester.dragFrom(const Offset(320, 420), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('暂无关注'), findsOneWidget);
  });

  testWidgets('推荐瀑布流首屏使用 vv2 示例卡资源', (tester) async {
    await pumpStyleScreen(tester);

    expect(find.text('欣赏美景'), findsNothing);
    expect(find.text('等待开拍'), findsNothing);
    expect(find.text('立即开拍'), findsNothing);
    expect(find.text('推荐'), findsOneWidget);
    expect(find.text('风景'), findsOneWidget);
    expect(find.text('人物'), findsOneWidget);
    expect(find.text('写真'), findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('style.sceneSegment')), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('style.tab.0'))),
      const Offset(14, 62),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('style.tab.1'))),
      const Offset(60, 64),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('style.tab.4'))),
      const Offset(186, 64),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('style.selectedIndicator'))),
      const Offset(26, 86),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('style.selectedIndicator'))),
      const Size(8, 4),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('style.viewToggle')))
          .dx,
      closeTo(346.5, 0.5),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('style.viewToggle')))
          .dy,
      closeTo(69, 0.5),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('style.viewToggle'))),
      const Size(14, 14),
    );
    expect(find.byKey(const ValueKey<String>('style_user_card_u1')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('style_chat_button_u1')),
        findsOneWidget);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('style_user_card_u1')))
          .dy,
      closeTo(98, 0.1),
    );
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('列表模式使用 v3 列表配图资源', (tester) async {
    await pumpStyleScreen(tester);

    await tester.tap(find.byKey(const ValueKey<String>('style.viewToggle')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('style_list_card_u1')),
        findsOneWidget);

    final assetNames = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<AssetImage>()
        .map((image) => image.assetName)
        .where((assetName) => assetName.startsWith('docs/v3/列表配图/'))
        .toList();

    expect(assetNames.length, greaterThanOrEqualTo(3));
    expect(assetNames.toSet().length, greaterThanOrEqualTo(3));
  });

  testWidgets('瀑布流和列表模式展示同一批推荐用户', (tester) async {
    await pumpStyleScreen(tester);

    final recommendedUsers = AppRepository.instance.users
        .where((user) => user.id != AppRepository.officialSupportUserId)
        .toList();

    for (final user in recommendedUsers) {
      expect(find.byKey(ValueKey<String>('style_user_card_${user.id}')),
          findsOneWidget);
    }

    await tester.tap(find.byKey(const ValueKey<String>('style.viewToggle')));
    await tester.pumpAndSettle();

    for (final user in recommendedUsers) {
      expect(find.byKey(ValueKey<String>('style_list_card_${user.id}')),
          findsOneWidget);
    }
  });

  testWidgets('推荐 tab 点击拍友卡片会进入个人主页', (tester) async {
    final router = GoRouter(
      initialLocation: '/style',
      routes: [
        GoRoute(
          path: '/style',
          builder: (context, state) => const StyleScreen(),
        ),
        GoRoute(
          path: '/moment_detail/:id',
          builder: (context, state) =>
              Text('detail:${state.pathParameters['id']}'),
        ),
        GoRoute(
          path: '/user_profile/:userId',
          builder: (context, state) =>
              Text('profile:${state.pathParameters['userId']}'),
        ),
        GoRoute(
          path: '/chat/:userId',
          builder: (context, state) =>
              Text('chat:${state.pathParameters['userId']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('style_user_card_u1')));
    await tester.pumpAndSettle();

    expect(find.text('profile:u1'), findsOneWidget);
  });

  testWidgets('关注 tab 点击拍友卡片也进入个人主页', (tester) async {
    // u2 关注了 u1,切到 u2 身份后 关注 tab 会展示 u1 的卡片
    AppRepository.instance.setCurrentUser('u2');
    addTearDown(() => AppRepository.instance.setCurrentUser(''));

    final router = GoRouter(
      initialLocation: '/style',
      routes: [
        GoRoute(
          path: '/style',
          builder: (context, state) => const StyleScreen(),
        ),
        GoRoute(
          path: '/moment_detail/:id',
          builder: (context, state) =>
              Text('detail:${state.pathParameters['id']}'),
        ),
        GoRoute(
          path: '/user_profile/:userId',
          builder: (context, state) =>
              Text('profile:${state.pathParameters['userId']}'),
        ),
        GoRoute(
          path: '/chat/:userId',
          builder: (context, state) =>
              Text('chat:${state.pathParameters['userId']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('关注'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('style_user_card_u1')));
    await tester.pumpAndSettle();

    expect(find.text('profile:u1'), findsOneWidget);
  });

  testWidgets('点击聊天按钮会进入IM页面', (tester) async {
    final router = GoRouter(
      initialLocation: '/style',
      routes: [
        GoRoute(
          path: '/style',
          builder: (context, state) => const StyleScreen(),
        ),
        GoRoute(
          path: '/moment_detail/:id',
          builder: (context, state) =>
              Text('detail:${state.pathParameters['id']}'),
        ),
        GoRoute(
          path: '/user_profile/:userId',
          builder: (context, state) =>
              Text('profile:${state.pathParameters['userId']}'),
        ),
        GoRoute(
          path: '/chat/:userId',
          builder: (context, state) =>
              Text('chat:${state.pathParameters['userId']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('style_chat_button_u1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('chat:u1'), findsOneWidget);
  });
}
