import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/call/voice_call_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
  });

  Future<void> pumpVoiceCall(
    WidgetTester tester, {
    VoiceCallState state = VoiceCallState.outgoing,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: VoiceCallScreen(
            otherUserId: 'u4',
            initialState: state,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('发起语音通话展示等待接听和资料卡', (tester) async {
    await pumpVoiceCall(tester);

    expect(find.text('棠也'), findsOneWidget);
    expect(find.text('等待接听...'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('voiceCall.callerCard')),
        findsNothing);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('voiceCall.largeAvatar'))),
      const Offset(112.5, 210),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('voiceCall.largeAvatar'))),
      const Size(150, 150),
    );
    expect(find.byKey(const ValueKey<String>('voiceCall.topRightIcon')),
        findsNothing);
    final displayNameRect = tester
        .getRect(find.byKey(const ValueKey<String>('voiceCall.displayName')));
    expect(displayNameRect.center.dx, closeTo(187.5, 0.5));
    expect(displayNameRect.top, closeTo(372, 0.1));
    expect(
      tester
          .getTopLeft(
              find.byKey(const ValueKey<String>('voiceCall.statusText')))
          .dy,
      closeTo(508, 0.1),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('voiceCall.hangUpButton'))),
      const Offset(152.5, 669),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('voiceCall.hangUpButton'))),
      const Size(70, 70),
    );
  });

  testWidgets('被邀请语音通话展示接听文案和双按钮', (tester) async {
    await pumpVoiceCall(tester, state: VoiceCallState.incoming);

    expect(find.text('棠也正在邀请你语音通话...'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('voiceCall.callerCard')),
        findsNothing);
    expect(find.byIcon(Icons.call), findsOneWidget);
    expect(find.byIcon(Icons.call_end), findsOneWidget);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('voiceCall.hangUpButton'))),
      const Offset(50, 669),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('voiceCall.answerButton'))),
      const Offset(255, 669),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('voiceCall.answerButton'))),
      const Size(70, 70),
    );
  });

  testWidgets('语音通话接听中展示计时和单个挂断按钮', (tester) async {
    await pumpVoiceCall(tester, state: VoiceCallState.active);

    expect(find.text('00:23'), findsOneWidget);
    expect(find.byIcon(Icons.call_end), findsOneWidget);
    expect(find.byIcon(Icons.call), findsNothing);
    expect(find.text('27岁'), findsNothing);
    expect(find.byKey(const ValueKey<String>('voiceCall.callerCard')),
        findsNothing);
    expect(
      tester
          .getTopLeft(
              find.byKey(const ValueKey<String>('voiceCall.statusText')))
          .dy,
      closeTo(635, 0.1),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('voiceCall.hangUpButton'))),
      const Offset(152.5, 669),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('voiceCall.hangUpButton'))),
      const Size(70, 70),
    );
  });
}
