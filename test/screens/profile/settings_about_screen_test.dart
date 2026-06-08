import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/screens/profile/subscreens/about_us_screen.dart';
import 'package:ray_app/screens/profile/subscreens/settings_screen.dart';

void main() {
  testWidgets('设置页补齐关于我们和检查更新入口', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SettingsScreen()),
      ),
    );

    expect(find.text('实名认证'), findsOneWidget);
    expect(find.text('注销账号'), findsOneWidget);
    expect(find.text('黑名单'), findsOneWidget);
    expect(find.text('意见与反馈'), findsOneWidget);
    expect(find.text('关于我们'), findsOneWidget);
    expect(find.text('检查更新'), findsOneWidget);
  });

  testWidgets('关于我们页展示版本和协议入口', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const MaterialApp(home: AboutUsScreen()),
    );

    expect(find.text('关于我们'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('about.appIcon')), findsOneWidget);
    expect(find.text('photomate'), findsOneWidget);
    expect(find.text('版本：V1.0.2'), findsOneWidget);
    expect(find.text('用户协议'), findsOneWidget);
    expect(find.text('隐私政策'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('about.appIcon'))),
      const Size(96, 96),
    );
  });
}
