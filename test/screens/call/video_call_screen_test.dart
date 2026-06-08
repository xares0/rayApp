import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/call/video_call_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
  });

  Future<void> pumpVideoCall(
    WidgetTester tester, {
    VideoCallState state = VideoCallState.active,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: VideoCallScreen(
            otherUserId: 'u4',
            initialState: state,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('视频通话中展示 vv2 浮层信息', (tester) async {
    await pumpVideoCall(tester);

    expect(find.text('棠也'), findsOneWidget);
    expect(find.text('+'), findsOneWidget);
    expect(find.text('时长：01:09'), findsOneWidget);
    expect(find.text('赠送'), findsOneWidget);
    expect(find.text('x1'), findsOneWidget);
    expect(find.textContaining('系统通知：平台文明交友'), findsOneWidget);
    expect(find.text('聊点刺激的事情...'), findsOneWidget);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.topInfoBar'))),
      const Offset(4, 47),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('videoCall.topInfoBar'))),
      const Size(182, 49),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.activeName'))),
      const Offset(61, 50),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.activeAvatar'))),
      const Offset(11, 52),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('videoCall.activeAvatar'))),
      const Size(40, 40),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.followButton'))),
      const Offset(139, 62),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('videoCall.followButton'))),
      const Size(38, 20),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.durationText'))),
      const Offset(61, 75),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.selfWindow'))),
      const Offset(12, 111),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('videoCall.selfWindow'))),
      const Size(98, 137),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.sideTool.emoji'))),
      const Offset(327, 127),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('videoCall.sideTool.emoji'))),
      const Size(34, 34),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.sideTool.camera'))),
      const Offset(327, 173),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.sideTool.video'))),
      const Offset(327, 219),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.sideTool.mic'))),
      const Offset(327, 265),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.giftBubble'))),
      const Offset(14, 531),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.messagePanel'))),
      const Offset(14, 580),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.giftButton'))),
      const Offset(319, 665),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('videoCall.inputBar'))),
      const Offset(14, 738),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.videoButton'))),
      const Offset(328, 741),
    );
  });

  testWidgets('主动发起视频通话展示单个挂断按钮', (tester) async {
    await pumpVideoCall(tester, state: VideoCallState.outgoingB);

    expect(find.text('棠也'), findsOneWidget);
    expect(find.byIcon(Icons.call_end), findsOneWidget);
    expect(find.byIcon(Icons.call), findsNothing);
    final outgoingNameRect = tester
        .getRect(find.byKey(const ValueKey<String>('videoCall.outgoingName')));
    expect(outgoingNameRect.center.dx, closeTo(187.5, 0.5));
    expect(outgoingNameRect.top, closeTo(623, 0.1));
    expect(find.byKey(const ValueKey<String>('videoCall.closeButton')),
        findsNothing);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.hangUpButton'))),
      const Offset(152.5, 669),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('videoCall.hangUpButton'))),
      const Size(70, 70),
    );
  });

  testWidgets('被邀请视频通话展示接听和挂断按钮', (tester) async {
    await pumpVideoCall(tester, state: VideoCallState.outgoingA);

    expect(find.text('棠也'), findsOneWidget);
    expect(find.byIcon(Icons.call), findsOneWidget);
    expect(find.byIcon(Icons.call_end), findsOneWidget);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.answerButton'))),
      const Offset(50, 669),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.hangUpButton'))),
      const Offset(255, 669),
    );
  });

  testWidgets('视频通话清屏态隐藏浮层', (tester) async {
    await pumpVideoCall(tester, state: VideoCallState.clearScreen);

    expect(find.text('Alice Wonders'), findsNothing);
    expect(find.text('棠也'), findsNothing);
    expect(find.text('聊点刺激的事情...'), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.selfWindow'))),
      const Offset(12, 111),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('videoCall.closeButton'))),
      const Offset(343, 64),
    );
  });
}
