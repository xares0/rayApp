import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/discover/discover_screen.dart';
import 'package:ray_app/screens/moment/moment_detail_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('');
  });

  Future<void> pumpDiscoverScreen(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DiscoverScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('点击顶部分类会切到关注占位态', (tester) async {
    await pumpDiscoverScreen(tester);

    expect(find.text('暂无关注'), findsNothing);

    await tester.tap(find.text('关注'));
    await tester.pumpAndSettle();

    expect(find.text('暂无关注'), findsOneWidget);
  });

  testWidgets('推荐动态首屏展示 vv2 示例卡内容', (tester) async {
    await pumpDiscoverScreen(tester);

    expect(find.text('棠也'), findsNWidgets(2));
    expect(find.text('发布动态'), findsOneWidget);
    expect(find.text('推荐'), findsOneWidget);
    expect(find.text('探索未知，感受自然之美。'), findsNWidgets(2));
    expect(find.text('1个小时前'), findsNWidgets(2));
    expect(find.text('358'), findsNWidgets(2));
    expect(find.text('122'), findsNWidgets(2));
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.heroBanner'))),
      const Offset(0, 41),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('discover.heroBanner'))),
      const Size(375, 166),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.publishButton'))),
      const Offset(63, 174),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('discover.publishButton'))),
      const Size(87, 29),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.paipaiLogo'))),
      const Offset(13, 46),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('discover.paipaiLogo'))),
      const Size(78, 30),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('discover.tab.0')))
          .dx,
      14,
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('discover.tab.0')))
          .dy,
      closeTo(221, 0.5),
    );
    expect(
      tester
          .getTopLeft(
              find.byKey(const ValueKey<String>('discover.tabIndicator.0')))
          .dx,
      26,
    );
    expect(
      tester
          .getTopLeft(
              find.byKey(const ValueKey<String>('discover.tabIndicator.0')))
          .dy,
      closeTo(245, 0.5),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('discover.tabIndicator.0'))),
      const Size(8, 4),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('discover.tab.1')))
          .dx,
      closeTo(60, 0.5),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('discover.tab.1')))
          .dy,
      closeTo(223, 0.5),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('discover.tab.4')))
          .dx,
      closeTo(186, 0.5),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('discover.tab.4')))
          .dy,
      closeTo(223, 0.5),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.notifyPrimary'))),
      const Offset(322, 225),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('discover.notifyPrimary'))),
      const Size(16, 16),
    );
    expect(
      find.byKey(const ValueKey<String>('discover.notifySecondary')),
      findsNothing,
    );
    expect(find.text('双击查看动态组件'), findsNothing);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.postCard.0'))),
      const Offset(14, 259),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('discover.postCard.0'))),
      const Size(347, 229),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.postAvatar.0'))),
      const Offset(28, 275),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('discover.postAvatar.0'))),
      const Size(35, 35),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.postName.0'))),
      const Offset(69, 275),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.postMore.0'))),
      const Offset(331, 280),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('discover.postMore.0'))),
      const Size(24, 24),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.postContent.0'))),
      const Offset(28, 318),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.postImage.0.0'))),
      const Offset(28, 344),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('discover.postImage.0.0'))),
      const Size(102, 104),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.postImage.0.1'))),
      const Offset(137, 344),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.postImage.0.2'))),
      const Offset(246, 344),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.postLikeGroup.0'))),
      const Offset(239, 456),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('discover.postCommentGroup.0'))),
      const Offset(303, 456),
    );
  });

  testWidgets('列表点赞后详情页展示同步后的状态和数量', (tester) async {
    await pumpDiscoverScreen(tester);

    await tester
        .tap(find.byKey(const ValueKey<String>('discover.postLikeGroup.0')));
    await tester.pump();

    final post = AppRepository.instance.getPostById('p1')!;
    expect(post.isLiked, isFalse);
    expect(post.likesCount, 357);
    expect(find.text('357'), findsOneWidget);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MomentDetailScreen(postId: 'p1'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('357'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('横向滑动内容区会切到关注分类', (tester) async {
    await pumpDiscoverScreen(tester);

    expect(find.text('暂无关注'), findsNothing);

    await tester.fling(
        find.byType(DiscoverScreen), const Offset(-400, 0), 1200);
    await tester.pumpAndSettle();

    expect(find.text('暂无关注'), findsOneWidget);
  });
}
