import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_app/screens/message/system_notifications_screen.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SystemNotificationsScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('互动通知默认被点赞页贴近 vv2 内容', (tester) async {
    await pumpScreen(tester);

    expect(find.text('互动通知'), findsOneWidget);
    expect(find.text('被点赞'), findsOneWidget);
    expect(find.text('我点赞的'), findsOneWidget);
    expect(find.text('被评论'), findsOneWidget);
    expect(find.text('被回复'), findsOneWidget);
    expect(find.text('棠也'), findsNWidgets(3));
    expect(find.text('赞'), findsNWidgets(3));
    expect(find.text('5分钟前'), findsNWidgets(3));
    expect(find.textContaining('把孤独'), findsOneWidget);
    final titleRect =
        tester.getRect(find.byKey(const ValueKey<String>('interaction.title')));
    expect(titleRect.center.dx, closeTo(188, 0.5));
    expect(titleRect.top, 58);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('interaction.backFrame'))),
      const Offset(14, 62),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('interaction.backFrame'))),
      const Size(20, 20),
    );
    final tab0TopLeft = tester
        .getTopLeft(find.byKey(const ValueKey<String>('interaction.tab.0')));
    final tab1TopLeft = tester
        .getTopLeft(find.byKey(const ValueKey<String>('interaction.tab.1')));
    final tab2TopLeft = tester
        .getTopLeft(find.byKey(const ValueKey<String>('interaction.tab.2')));
    final tab3TopLeft = tester
        .getTopLeft(find.byKey(const ValueKey<String>('interaction.tab.3')));
    expect(tab0TopLeft.dx, closeTo(14, 0.5));
    expect(tab0TopLeft.dy, 97);
    expect(tab1TopLeft.dx, closeTo(108, 0.5));
    expect(tab1TopLeft.dy, 97);
    expect(tab2TopLeft.dx, closeTo(218, 0.5));
    expect(tab2TopLeft.dy, 97);
    expect(tab3TopLeft.dx, closeTo(312, 0.5));
    expect(tab3TopLeft.dy, 97);
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('interaction.tab.1')))
          .height,
      22,
    );
    expect(
      find.byKey(const ValueKey<String>('interaction.selectedArrow')),
      findsNothing,
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('interaction.row.0'))),
      const Offset(0, 139),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('interaction.avatar.0'))),
      const Offset(11, 139),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('interaction.avatar.0'))),
      const Size(42, 42),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('interaction.name.0'))),
      const Offset(62, 139),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('interaction.action.0'))),
      const Offset(62, 164),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('interaction.trailing.0'))),
      const Offset(312, 132),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('interaction.trailing.0'))),
      const Size(48, 56),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('interaction.divider.0'))),
      const Offset(59, 201),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('interaction.divider.0'))),
      const Size(301.5, 0.5),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('interaction.row.1'))),
      const Offset(0, 211),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('interaction.avatar.1'))),
      const Offset(11, 211),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('interaction.trailing.1'))),
      const Offset(312, 204),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('interaction.divider.1'))),
      const Offset(59, 273),
    );
  });

  testWidgets('互动通知无数据时展示 vv2 空态插画', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('我点赞的'));
    await tester.pumpAndSettle();

    expect(find.text('页面啥也没有'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('interaction_empty_illustration')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey<String>('interaction_empty_illustration')),
      ),
      const Offset(96, 314),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey<String>('interaction_empty_illustration')),
      ),
      const Size(184, 184),
    );
    expect(
      tester.getTopLeft(find.text('页面啥也没有')),
      const Offset(146, 497),
    );
  });
}
