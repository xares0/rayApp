import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/profile/subscreens/friends_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  tearDown(() {
    AppRepository.instance.setCurrentUser('');
  });

  testWidgets('我的好友页按 vv2 展示顶部和好友卡片', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: FriendsScreen()),
      ),
    );

    expect(find.text('我的好友'), findsOneWidget);
    expect(find.text('Alice Wonders'), findsOneWidget);
    expect(find.text('胶片玩家，周末探店拍摄'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('friends.titleFrame'))),
      const Offset(128, 58),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('friends.titleFrame'))),
      const Size(120, 28),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('friends.backFrame'))),
      const Offset(14, 62),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('friends.card.0'))),
      const Offset(14, 99),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('friends.card.0'))),
      const Size(347, 62),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('friends.card.1'))),
      const Offset(14, 169),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('friends.avatar.0'))),
      const Offset(24, 109),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('friends.avatar.0'))),
      const Size(42, 42),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('friends.name.0'))),
      const Offset(75, 110),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('friends.bio.0'))),
      const Offset(75, 137),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('friends.messageButton.0'))),
      const Offset(304, 117),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('friends.messageButton.0'))),
      const Size(42, 27),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('friends.messageIcon.0'))),
      const Size(22, 22),
    );
  });

  testWidgets('我的好友页在宽屏设备保持消息按钮右边距', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: FriendsScreen()),
      ),
    );

    final cardRect =
        tester.getRect(find.byKey(const ValueKey<String>('friends.card.0')));
    final buttonRect = tester
        .getRect(find.byKey(const ValueKey<String>('friends.messageButton.0')));

    expect(cardRect.left, 14);
    expect(cardRect.right, 379);
    expect(buttonRect.width, 42);
    expect(cardRect.right - buttonRect.right, 15);
    expect(393 - buttonRect.right, 29);
  });
}
