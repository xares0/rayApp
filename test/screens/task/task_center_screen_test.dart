import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/screens/checkin/checkin_provider.dart';
import 'package:ray_app/screens/task/task_center_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('任务中心按 vv2 坐标展示签到 banner 和权益卡', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TaskCenterScreen(checkedInToday: false),
        ),
      ),
    );

    expect(find.text('签到有礼'), findsOneWidget);
    expect(find.text('立即签到'), findsOneWidget);
    expect(find.text('领取权益'), findsOneWidget);
    expect(find.text('签到规则'), findsOneWidget);
    expect(find.text('已领取'), findsOneWidget);
    expect(find.text('待领取'), findsNWidgets(6));
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('taskCenter.titleFrame'))),
      const Offset(138, 58),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('taskCenter.titleFrame'))),
      const Size(100, 28),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('taskCenter.backButton'))),
      const Offset(14, 62),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('taskCenter.backButton'))),
      const Size(20, 20),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('taskCenter.giftDecoration'))),
      const Offset(219, 47),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('taskCenter.banner'))),
      const Offset(14, 96),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('taskCenter.banner'))),
      const Size(347, 130),
    );
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey<String>('taskCenter.signInButton')),
      ),
      const Offset(244, 170),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey<String>('taskCenter.signInButton')),
      ),
      const Size(80, 25),
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('taskCenter.signInButtonText')),
          )
          .data,
      '立即签到',
    );
    final signInButton = tester.widget<Container>(
      find.byKey(const ValueKey<String>('taskCenter.signInButtonBackground')),
    );
    final signInDecoration = signInButton.decoration as BoxDecoration;
    expect(signInDecoration.gradient, isNotNull);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('taskCenter.section.领取权益'))),
      const Offset(27, 242),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('taskCenter.section.签到规则'))),
      const Offset(27, 629),
    );
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey<String>('taskCenter.benefitPanel')),
      ),
      const Offset(14, 273),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey<String>('taskCenter.benefitPanel')),
      ),
      const Size(347, 256),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('taskCenter.day.1'))),
      const Offset(31, 316),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('taskCenter.day.4'))),
      const Offset(280, 316),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('taskCenter.day.5'))),
      const Offset(75, 414),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('taskCenter.day.7'))),
      const Offset(241, 414),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('taskCenter.day.1'))),
      const Size(70, 80),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('taskCenter.dayCta.1'))),
      const Offset(39, 369),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('taskCenter.dayCta.1'))),
      const Size(53, 20),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('taskCenter.dayReward.1'))),
      const Offset(31, 351),
    );
  });

  testWidgets('任务中心签到按钮已签到态和立即签到互斥', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: TaskCenterScreen(checkedInToday: true)),
      ),
    );

    expect(find.text('立即签到'), findsNothing);
    expect(find.text('已签到'), findsOneWidget);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('taskCenter.signInButton'))),
      const Offset(244, 170),
    );
    final signInButton = tester.widget<Container>(
      find.byKey(const ValueKey<String>('taskCenter.signInButtonBackground')),
    );
    final signInDecoration = signInButton.decoration as BoxDecoration;
    expect(signInDecoration.color, const Color(0xFFEDEDED));
    expect(signInDecoration.gradient, isNull);
  });

  testWidgets('任务中心默认跟随真实签到状态显示已签到', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    late WidgetRef capturedRef;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              return const TaskCenterScreen();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await capturedRef.read(checkinProvider.notifier).signIn();
    await tester.pumpAndSettle();

    expect(find.text('立即签到'), findsNothing);
    expect(find.text('已签到'), findsOneWidget);

    final signInButton = tester.widget<Container>(
      find.byKey(const ValueKey<String>('taskCenter.signInButtonBackground')),
    );
    final signInDecoration = signInButton.decoration as BoxDecoration;
    expect(signInDecoration.color, const Color(0xFFEDEDED));
    expect(signInDecoration.gradient, isNull);
  });
}
