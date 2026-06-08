import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/screens/checkin/checkin_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('签到弹窗按 Figma 布局渲染并可点击签到', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final todayDay = DateTime.now().weekday;
    final unsignedDay = todayDay == 1 ? 2 : 1;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: _CheckinDialogHost(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Reset Monday'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('Day 7'), findsOneWidget);
    expect(find.text('立即签到'), findsOneWidget);
    expect(
      find.byKey(ValueKey<String>('checkin.dayState.$todayDay.available')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey<String>('checkin.dayState.$unsignedDay.future')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('checkin.panel'))),
      const Offset(26, 171),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('checkin.panel'))),
      const Size(323, 479),
    );
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey<String>('checkin.titleImage')),
      ),
      const Offset(104.65, 146),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('checkin.titleImage'))),
      const Size(156.98, 89.74),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('checkin.resetText'))),
      const Offset(138, 241),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('checkin.dayFrame.1'))),
      const Offset(52, 287),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('checkin.dayFrame.1'))),
      const Size(72, 71),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('checkin.dayIcon.1'))),
      const Offset(62, 291),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('checkin.reward.1'))),
      const Offset(81.64, 332),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('checkin.dayLabel.1'))),
      const Offset(69.64, 348),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('checkin.dayFrame.3'))),
      const Offset(222.64, 288),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('checkin.dayFrame.3'))),
      const Size(102, 71),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('checkin.dayFrame.7'))),
      const Offset(53, 475),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('checkin.dayFrame.7'))),
      const Size(269, 71),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('checkin.ctaButton'))),
      const Offset(118, 571),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('checkin.ctaButton'))),
      const Size(141, 42),
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('checkin.ctaText')),
          )
          .data,
      '立即签到',
    );

    await tester.tap(find.text('立即签到'));
    await tester.pumpAndSettle();

    expect(find.text('签到成功'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('checkin.openButton')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey<String>('checkin.dayState.$todayDay.signed')),
      findsOneWidget,
    );
    expect(
      tester.getSize(
        find.byKey(ValueKey<String>('checkin.signedBadge.$todayDay')),
      ),
      const Size(16, 16),
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('checkin.ctaText')),
          )
          .data,
      '已签到',
    );
  });
}

class _CheckinDialogHost extends StatelessWidget {
  const _CheckinDialogHost();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        key: const ValueKey<String>('checkin.openButton'),
        onPressed: () => showCheckinDialog(context),
        child: const Text('open'),
      ),
    );
  }
}
