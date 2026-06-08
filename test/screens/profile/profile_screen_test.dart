import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpProfileWithSize(
    WidgetTester tester,
    Size size, {
    double topPadding = 44,
    double bottomPadding = 34,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    tester.view.padding = FakeViewPadding(
      top: topPadding,
      bottom: bottomPadding,
    );
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('我的页面展示 vv2 关键入口和礼物数', (tester) async {
    await pumpProfile(tester);

    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.text('签到有礼'), findsOneWidget);
    expect(find.text('我的投稿'), findsOneWidget);
    expect(find.text('我的礼物'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('客服中心'), findsOneWidget);
    expect(find.text('我的置顶'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('通话记录'), findsOneWidget);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('profile.backButton'))),
      const Offset(18, 51),
    );
    expect(
        find.byKey(const ValueKey<String>('profile.moreButton')), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('profile.avatar'))),
      const Offset(24, 91),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('profile.avatar'))),
      const Size(57, 57),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('profile.name'))).dx,
      closeTo(91, 0.5),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('profile.name'))).dy,
      closeTo(100, 0.5),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('profile.ageBadge')))
          .dx,
      closeTo(91, 0.5),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('profile.ageBadge')))
          .dy,
      closeTo(121, 0.5),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('profile.bio'))).dx,
      closeTo(91, 0.5),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('profile.bio'))).dy,
      closeTo(137, 0.5),
    );
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey<String>('profile.checkinButton')),
      ),
      const Offset(276, 106),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey<String>('profile.checkinButton')),
      ),
      const Size(85, 26),
    );
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey<String>('profile.stat.followers')),
      ),
      const Offset(35, 160),
    );
    final friendsStatTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey<String>('profile.stat.friends')),
    );
    expect(friendsStatTopLeft.dx, closeTo(129, 0.5));
    expect(friendsStatTopLeft.dy, 160);
    final followingStatTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey<String>('profile.stat.following')),
    );
    expect(followingStatTopLeft.dx, closeTo(223, 0.5));
    expect(followingStatTopLeft.dy, 160);
    final visitorsStatTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey<String>('profile.stat.visitors')),
    );
    expect(visitorsStatTopLeft.dx, closeTo(317, 0.5));
    expect(visitorsStatTopLeft.dy, 160);
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey<String>('profile.banner')),
      ),
      const Offset(14, 218),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('profile.banner'))),
      const Size(347, 123),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('profile.menuCard'))),
      const Offset(14, 355),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('profile.menuCard'))),
      const Size(347, 293),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('profile.menu.post'))),
      const Offset(14, 367),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('profile.menu.post'))),
      const Size(347, 49),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('profile.menu.gift'))),
      const Offset(14, 416),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('profile.menu.support'))),
      const Offset(14, 465),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('profile.menu.pinned'))),
      const Offset(14, 514),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('profile.menu.settings'))),
      const Offset(14, 563),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('profile.menu.calls'))),
      const Offset(14, 612),
    );
  });

  testWidgets('我的页面在宽屏设备不沿用窄屏固定宽度', (tester) async {
    await pumpProfileWithSize(
      tester,
      const Size(393, 852),
      topPadding: 59,
    );

    final nameRect =
        tester.getRect(find.byKey(const ValueKey<String>('profile.name')));
    final editRect = tester
        .getRect(find.byKey(const ValueKey<String>('profile.editButton')));
    final checkinRect = tester
        .getRect(find.byKey(const ValueKey<String>('profile.checkinButton')));

    expect(nameRect.width, greaterThan(118));
    expect(nameRect.right, lessThanOrEqualTo(editRect.left));
    expect(editRect.right, lessThan(checkinRect.left));
    expect(393 - checkinRect.right, 14);

    final followersRect = tester
        .getRect(find.byKey(const ValueKey<String>('profile.stat.followers')));
    expect(followersRect.width, greaterThanOrEqualTo(32));

    final menuCardRect =
        tester.getRect(find.byKey(const ValueKey<String>('profile.menuCard')));
    expect(menuCardRect.left, 14);
    expect(menuCardRect.right, 379);
  });
}
