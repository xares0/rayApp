import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/screens/profile/subscreens/report_screen.dart';

void main() {
  testWidgets('举报页渲染 Figma 关键内容', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const MaterialApp(
        home: ReportScreen(targetType: ReportTargetType.user, targetId: 'u1'),
      ),
    );

    expect(find.text('举报'), findsOneWidget);
    expect(find.text('HI，给出你的小建议把~'), findsOneWidget);
    expect(find.text('请选择举报类型'), findsOneWidget);
    expect(find.text('违法违禁'), findsOneWidget);
    expect(find.text('请上传举报截图'), findsOneWidget);
    expect(find.text('请输入举报原因'), findsOneWidget);
    expect(find.text('0/3'), findsOneWidget);
    expect(find.text('0/1000'), findsOneWidget);
    expect(tester.getTopLeft(find.text('举报')), const Offset(18, 100));
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('report.backButton'))),
      const Offset(14, 62),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.backButton'))),
      const Size(20, 20),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('report.title'))),
      const Offset(18, 100),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.title'))),
      const Size(80, 28),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('report.subtitle'))),
      const Offset(18, 136),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.subtitle'))),
      const Size(168, 22),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.smileDecoration'))),
      const Offset(248, 99),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('report.smileDecoration'))),
      const Size(109.5, 78.2),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('report.reasonCard'))),
      const Offset(14, 172),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.reasonCard'))),
      const Size(347, 159),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.reasonChip.0'))),
      const Offset(29, 212),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.reasonChip.1'))),
      const Offset(148, 212),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.reasonChip.2'))),
      const Offset(260, 212),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.reasonChip.6'))),
      const Offset(29, 290),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.reasonChip.0'))),
      const Size(93, 27),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('report.uploadCard'))),
      const Offset(14, 345),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.uploadCard'))),
      const Size(347, 139),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.addImageCell'))),
      const Offset(29, 385),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.addImageCell'))),
      const Size(89, 89),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.addImageIcon'))),
      const Offset(63, 419),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.addImageCount'))),
      const Offset(66, 440),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('report.descCard'))),
      const Offset(14, 498),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.descCard'))),
      const Size(347, 190),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('report.descInput'))),
      const Offset(29, 538),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.descInput'))),
      const Size(318, 136),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.submitButton'))),
      const Offset(14, 702),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.submitButton'))),
      const Size(347, 48),
    );
  });

  testWidgets('举报页已选和已上传态贴近 vv2 B 态', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const MaterialApp(
        home: ReportScreen(
          targetType: ReportTargetType.user,
          targetId: 'u1',
          initialSelectedReason: '违法违禁',
          initialImagePaths: ['placeholder'],
          usePlaceholderThumbnails: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('违法违禁'), findsOneWidget);
    expect(find.text('0/1000'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('report.reasonSelectedMark.3')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('report.addImageCell')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.imageThumb.0'))),
      const Offset(134, 385),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('report.imageThumb.0'))),
      const Size(89, 89),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.imageThumbMask.0'))),
      const Offset(134, 385),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('report.imageThumbMask.0'))),
      const Size(89, 32),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('report.imageThumbDelete.0'))),
      const Offset(205, 387),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('report.imageThumbDelete.0'))),
      const Size(16, 16),
    );

    final submitBackground = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey<String>('report.submitBackground')),
    );
    final decoration = submitBackground.decoration as BoxDecoration;
    expect(decoration.color, const Color(0xFF999999));
    expect(decoration.gradient, isNull);
  });

  testWidgets('举报页上传满 3 张后隐藏上传入口并三图并列', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const MaterialApp(
        home: ReportScreen(
          targetType: ReportTargetType.user,
          targetId: 'u1',
          initialImagePaths: ['a', 'b', 'c'],
          usePlaceholderThumbnails: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('report.addImageCell')),
        findsNothing);
    expect(
        tester.getTopLeft(
            find.byKey(const ValueKey<String>('report.imageThumb.0'))),
        const Offset(29, 385));
    expect(
        tester.getTopLeft(
            find.byKey(const ValueKey<String>('report.imageThumb.1'))),
        const Offset(134, 385));
    expect(
        tester.getTopLeft(
            find.byKey(const ValueKey<String>('report.imageThumb.2'))),
        const Offset(239, 385));
  });

  testWidgets('举报页未满 3 张时添加格不裁切已选缩略图', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const MaterialApp(
        home: ReportScreen(
          targetType: ReportTargetType.user,
          targetId: 'u1',
          initialImagePaths: ['a', 'b'],
          usePlaceholderThumbnails: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('report.addImageCell')),
        findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(
        tester.getTopLeft(
            find.byKey(const ValueKey<String>('report.imageThumb.0'))),
        const Offset(134, 385));
    expect(
        tester.getTopLeft(
            find.byKey(const ValueKey<String>('report.imageThumb.1'))),
        const Offset(233, 385));
  });
}
