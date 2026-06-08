import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/call/call_records_screen.dart';
import 'package:ray_app/screens/profile/subscreens/feedback_screen.dart';
import 'package:ray_app/screens/profile/subscreens/my_pinned_screen.dart';
import 'package:ray_app/screens/profile/subscreens/visitors_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  tearDown(() {
    AppRepository.instance.setCurrentUser('');
  });

  testWidgets('访客页按 vv2 结构展示标题和访客列表', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: VisitorsScreen()),
      ),
    );

    expect(find.text('我的访客'), findsOneWidget);
    expect(find.text('棠也'), findsNWidgets(2));
    expect(find.text('25'), findsNWidgets(2));
    expect(find.text('5分钟前'), findsOneWidget);
    expect(find.text('刚刚'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('visitors.titleFrame'))),
      const Offset(128, 58),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('visitors.titleFrame'))),
      const Size(120, 28),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('visitors.backFrame'))),
      const Offset(14, 62),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('visitors.item.0'))),
      const Offset(0, 109),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('visitors.item.1'))),
      const Offset(0, 177),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('visitors.avatar.0'))),
      const Offset(11, 109),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('visitors.avatar.0'))),
      const Size(42, 42),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('visitors.name.0'))),
      const Offset(62, 106),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('visitors.badge.0'))),
      const Offset(62, 127),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('visitors.badge.0'))),
      const Size(36, 14),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('visitors.time.0'))),
      const Offset(62, 143),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('visitors.divider'))),
      const Offset(59, 166),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('visitors.name.1'))),
      const Offset(62, 174),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('visitors.badge.1'))),
      const Offset(62, 195),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('visitors.time.1'))),
      const Offset(62, 211),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('visitors.badgeIcon.0'))),
      const Size(10, 10),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('visitors.badgeAge.0'))),
      const Offset(80, 127),
    );
  });

  testWidgets('访客页点击列表项进入对应访客主页', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    final router = GoRouter(
      initialLocation: '/visitors',
      routes: [
        GoRoute(
          path: '/visitors',
          builder: (_, __) => const VisitorsScreen(),
        ),
        GoRoute(
          path: '/user_profile/:userId',
          builder: (_, state) => Text('user:${state.pathParameters['userId']}'),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const Text('profile:self'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('visitors.item.0')));
    await tester.pumpAndSettle();

    expect(find.text('user:u4'), findsOneWidget);
  });

  testWidgets('通话记录页按 vv2 结构展示标题和回拨按钮', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CallRecordsScreen()),
      ),
    );

    expect(find.text('通话记录'), findsOneWidget);
    expect(find.text('棠也'), findsOneWidget);
    expect(find.text('02:00'), findsOneWidget);
    expect(find.text('3分钟前'), findsOneWidget);
    expect(find.text('回拨'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('callRecords.titleFrame'))),
      const Offset(128, 58),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('callRecords.titleFrame'))),
      const Size(120, 28),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('callRecords.backFrame'))),
      const Offset(14, 62),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('callRecords.item.0'))),
      const Offset(0, 109),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('callRecords.avatar.0'))),
      const Offset(11, 109),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('callRecords.avatar.0'))),
      const Size(42, 42),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('callRecords.name.0'))),
      const Offset(62, 112),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('callRecords.duration.0'))),
      const Offset(62, 135),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('callRecords.time.0'))),
      const Offset(290, 112),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('callRecords.callback.0'))),
      const Offset(300, 134),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('callRecords.callback.0'))),
      const Size(64, 22),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('callRecords.callbackIcon.0'))),
      const Offset(305, 138),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('callRecords.callbackIcon.0'))),
      const Size(14, 14),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('callRecords.callbackText.0'))),
      const Offset(322, 136),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('callRecords.divider.0'))),
      const Offset(59, 166),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('callRecords.divider.0'))),
      const Size(301.5, 0.5),
    );
  });

  testWidgets('通话记录回拨按钮区分语音视频和未接状态', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    final now = DateTime.now();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CallRecordsScreen(
            initialRecords: [
              CallRecord(
                id: 'audio',
                userId: 'u4',
                type: CallType.audioIncoming,
                durationLabel: '02:00',
                time: now.subtract(const Duration(minutes: 3)),
              ),
              CallRecord(
                id: 'video',
                userId: 'u5',
                type: CallType.videoOutgoing,
                durationLabel: '01:12',
                time: now.subtract(const Duration(minutes: 4)),
              ),
              CallRecord(
                id: 'missed',
                userId: 'u6',
                type: CallType.missedIncoming,
                durationLabel: '00:00',
                time: now.subtract(const Duration(minutes: 5)),
              ),
            ],
          ),
        ),
      ),
    );

    final audioIcon = tester.widget<Icon>(
      find.byKey(const ValueKey<String>('callRecords.callbackIcon.0')),
    );
    expect(audioIcon.icon, Icons.call_rounded);

    final videoIcon = tester.widget<Icon>(
      find.byKey(const ValueKey<String>('callRecords.callbackIcon.1')),
    );
    expect(videoIcon.icon, Icons.videocam_rounded);

    expect(find.text('未接来电'), findsOneWidget);
    final missedDuration = tester.widget<Text>(
      find.byKey(const ValueKey<String>('callRecords.duration.2')),
    );
    expect(missedDuration.style?.color, const Color(0xFFFF4D4D));
  });

  testWidgets('通话记录回拨进入视频通话邀请页', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    final router = GoRouter(
      initialLocation: '/call_records',
      routes: [
        GoRoute(
          path: '/call_records',
          builder: (context, state) => const CallRecordsScreen(),
        ),
        GoRoute(
          path: '/call/video/:userId',
          builder: (context, state) => Text(
            'video:${state.pathParameters['userId']}:${state.uri.queryParameters['state']}',
          ),
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
      find.byKey(const ValueKey<String>('callRecords.callback.0')),
    );
    await tester.pumpAndSettle();

    expect(find.text('video:u4:outgoingB'), findsOneWidget);
  });

  testWidgets('意见反馈类型默认不选中', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const MaterialApp(home: FeedbackScreen()),
    );

    for (var i = 0; i < 7; i++) {
      expect(
        find.byKey(ValueKey<String>('feedback.typeChipSelectedBorder.$i')),
        findsNothing,
      );
    }
  });

  testWidgets('我的置顶页按 vv2 结构展示标题和置顶用户', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MyPinnedScreen()),
      ),
    );

    expect(find.text('我的置顶'), findsOneWidget);
    expect(find.text('棠也'), findsOneWidget);
    expect(find.text('社牛属性拉满！刷到就是缘分'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('myPinned.titleFrame'))),
      const Offset(128, 58),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('myPinned.titleFrame'))),
      const Size(120, 28),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('myPinned.backFrame'))),
      const Offset(14, 62),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('myPinned.backFrame'))),
      const Size(20, 20),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('myPinned.item.0'))),
      const Offset(0, 109),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('myPinned.avatar.0'))),
      const Offset(11, 109),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('myPinned.avatar.0'))),
      const Size(42, 42),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('myPinned.name.0'))),
      const Offset(62, 112),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('myPinned.bio.0'))),
      const Offset(62, 135),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('myPinned.divider.0'))),
      const Offset(59, 166),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('myPinned.divider.0'))),
      const Size(301.5, 0.5),
    );
  });

  testWidgets('意见反馈页复用顶部背景并展示关键表单', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const MaterialApp(home: FeedbackScreen()),
    );

    expect(find.text('意见与反馈'), findsOneWidget);
    expect(find.text('HI，给出你的小建议把~'), findsOneWidget);
    expect(find.text('请选择反馈类型'), findsOneWidget);
    expect(find.text('闪退/卡顿'), findsOneWidget);
    expect(find.text('请上传反馈截图'), findsOneWidget);
    expect(find.text('0/3'), findsOneWidget);
    expect(find.text('请输入反馈详情'), findsOneWidget);
    expect(find.text('0/1000'), findsOneWidget);
    expect(find.text('提交'), findsOneWidget);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('feedback.backFrame'))),
      const Offset(14, 62),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('feedback.backFrame'))),
      const Size(20, 20),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.headerTitle'))),
      const Offset(18, 100),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('feedback.headerTitle'))),
      const Size(120, 28),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.headerSubtitle'))),
      const Offset(18, 136),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('feedback.headerSubtitle'))),
      const Size(210, 22),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.smileDecoration'))),
      const Offset(248, 99),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('feedback.smileDecoration'))),
      const Size(109.5, 78.2),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('feedback.typeCard'))),
      const Offset(14, 172),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('feedback.typeCard'))),
      const Size(347, 159),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.typeChip.0'))),
      const Offset(29, 212),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('feedback.typeChip.0'))),
      const Size(93, 27),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.typeChip.1'))),
      const Offset(148, 212),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.typeChip.2'))),
      const Offset(260, 212),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.uploadCard'))),
      const Offset(14, 345),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('feedback.uploadCard'))),
      const Size(347, 139),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.addImageBox'))),
      const Offset(29, 385),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('feedback.addImageBox'))),
      const Size(89, 89),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.detailCard'))),
      const Offset(14, 498),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('feedback.detailCard'))),
      const Size(347, 190),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.detailInput'))),
      const Offset(29, 538),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('feedback.detailInput'))),
      const Size(317, 136),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.submitButton'))),
      const Offset(14, 702),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('feedback.submitButton'))),
      const Size(347, 48),
    );
    final disabledSubmitDecoration = tester
        .widget<AnimatedContainer>(
          find.byKey(const ValueKey<String>('feedback.submitButton')),
        )
        .decoration as BoxDecoration;
    expect(disabledSubmitDecoration.color, const Color(0xFF999999));
    expect(disabledSubmitDecoration.gradient, isNull);
  });

  testWidgets('意见反馈已填写态按 vv2 展示缩略图和激活提交按钮', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    final imageA = await _createTinyPng('feedback_a.png');
    final imageB = await _createTinyPng('feedback_b.png');

    await tester.pumpWidget(
      MaterialApp(
        home: FeedbackScreen(
          initialSelectedTypes: const {3},
          initialImages: [imageA, imageB],
          initialContent: '闪退发生在点击拍摄按钮之后',
          usePlaceholderThumbnails: true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('闪退/卡顿'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.typeChip.3'))),
      const Offset(29, 251),
    );
    final selectedChipDecoration = tester
        .widget<Container>(
          find.byKey(
            const ValueKey<String>('feedback.typeChipSelectedBorder.3'),
          ),
        )
        .decoration as BoxDecoration;
    expect(
      (selectedChipDecoration.gradient as LinearGradient).colors,
      const [Color(0xFF7DDFFF), Color(0xFFDCA0FF)],
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.addImageBox'))),
      const Offset(29, 385),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.thumbnail.0'))),
      const Offset(134, 385),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('feedback.thumbnail.0'))),
      const Size(89, 89),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.thumbnailMask.0'))),
      const Offset(134, 385),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('feedback.thumbnailMask.0'))),
      const Size(89, 32),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.thumbnailDelete.0'))),
      const Offset(205, 387),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('feedback.thumbnailDelete.0'))),
      const Size(16, 16),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.thumbnail.1'))),
      const Offset(239, 385),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('feedback.submitButton'))),
      const Offset(14, 708),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('feedback.submitButton'))),
      const Size(347, 48),
    );
    final submitDecoration = tester
        .widget<AnimatedContainer>(
          find.byKey(const ValueKey<String>('feedback.submitButton')),
        )
        .decoration as BoxDecoration;
    expect(
      (submitDecoration.gradient as LinearGradient).colors,
      const [Color(0xFFDA99FF), Color(0xFFA575FF)],
    );
  });
}

Future<File> _createTinyPng(String name) async {
  return File('${Directory.systemTemp.path}/$name');
}
