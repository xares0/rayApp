import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/discover/discover_screen.dart';
import 'package:ray_app/screens/moment/moment_detail_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  Future<void> pumpMomentDetail(WidgetTester tester, String postId) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MomentDetailScreen(postId: postId),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('详情页点赞和评论计数使用动态数据源', (tester) async {
    await pumpMomentDetail(tester, 'p1');

    expect(find.text('358'), findsOneWidget);
    expect(find.text('122'), findsOneWidget);
    expect(find.text('共122条评论'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('详情页点赞后同步更新点赞状态和数量', (tester) async {
    await pumpMomentDetail(tester, 'p1');

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();

    expect(find.text('357'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('详情页点赞后列表展示同步后的状态和数量', (tester) async {
    await pumpMomentDetail(tester, 'p1');

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DiscoverScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('357'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('discover.postLikeGroup.0')),
        matching: find.byIcon(Icons.favorite_border),
      ),
      findsOneWidget,
    );
  });
}
