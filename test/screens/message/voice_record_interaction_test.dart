import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/screens/message/voice_record_interaction.dart';

void main() {
  test('语音时长格式化符合分秒显示', () {
    expect(formatVoiceRecordDuration(const Duration(seconds: 0)), '0:00');
    expect(formatVoiceRecordDuration(const Duration(seconds: 9)), '0:09');
    expect(formatVoiceRecordDuration(const Duration(seconds: 65)), '1:05');
  });

  test('语音阶段推导符合空闲、录音、可发送、取消和悬停发送状态', () {
    expect(
      deriveVoiceUiStage(
        voiceMode: false,
        isRecording: false,
        willCancel: false,
        hoverSend: false,
        duration: Duration.zero,
      ),
      isNull,
    );
    expect(
      deriveVoiceUiStage(
        voiceMode: true,
        isRecording: false,
        willCancel: false,
        hoverSend: false,
        duration: Duration.zero,
      ),
      VoiceUiStage.voiceIdle,
    );
    expect(
      deriveVoiceUiStage(
        voiceMode: true,
        isRecording: true,
        willCancel: false,
        hoverSend: false,
        duration: const Duration(milliseconds: 300),
      ),
      VoiceUiStage.recording,
    );
    expect(
      deriveVoiceUiStage(
        voiceMode: true,
        isRecording: true,
        willCancel: false,
        hoverSend: false,
        duration: const Duration(milliseconds: 900),
      ),
      VoiceUiStage.recording,
    );
    expect(
      deriveVoiceUiStage(
        voiceMode: true,
        isRecording: true,
        willCancel: false,
        hoverSend: false,
        duration: const Duration(seconds: 1),
      ),
      VoiceUiStage.recordingReadyToSend,
    );
    expect(
      deriveVoiceUiStage(
        voiceMode: true,
        isRecording: true,
        willCancel: true,
        hoverSend: false,
        duration: const Duration(seconds: 1),
      ),
      VoiceUiStage.recordingWillCancel,
    );
    expect(
      deriveVoiceUiStage(
        voiceMode: true,
        isRecording: true,
        willCancel: false,
        hoverSend: true,
        duration: const Duration(seconds: 1),
      ),
      VoiceUiStage.recordingHoverSend,
    );
  });

  test('语音交互文案会随状态切换', () {
    expect(shouldShowVoiceIdleHint(VoiceUiStage.voiceIdle), isTrue);
    expect(shouldShowVoiceIdleHint(VoiceUiStage.recording), isFalse);
    expect(buildVoiceBottomPrimaryText(VoiceUiStage.recording), '松开发送');
    expect(
      buildVoiceBottomPrimaryText(VoiceUiStage.recordingReadyToSend),
      '说完了',
    );
    expect(
      buildVoiceBottomPrimaryText(VoiceUiStage.recordingWillCancel),
      '松手取消',
    );
    expect(
      buildVoiceBottomPrimaryText(VoiceUiStage.recordingHoverSend),
      '松手发送',
    );
    expect(buildVoiceSideHintText(VoiceUiStage.recording), '上滑取消');
    expect(buildVoiceSideHintText(VoiceUiStage.recordingWillCancel), isNull);
    expect(buildVoiceSideHintText(VoiceUiStage.recordingHoverSend), isNull);
    expect(buildVoiceSideHintText(VoiceUiStage.recordingReadyToSend), '上滑取消');
    expect(
      buildVoiceHoldButtonText(
        isRecording: false,
        willCancel: false,
        hoverSend: false,
      ),
      '按住说话',
    );
    expect(
      buildVoiceHoldButtonText(
        isRecording: true,
        willCancel: false,
        hoverSend: false,
      ),
      '松开发送，上滑取消',
    );
    expect(
      buildVoiceHoldButtonText(
        isRecording: true,
        willCancel: true,
        hoverSend: false,
      ),
      '松手取消发送',
    );
    expect(
      buildVoiceHoldButtonText(
        isRecording: true,
        willCancel: false,
        hoverSend: true,
      ),
      '松手发送',
    );
  });

  testWidgets('语音空闲提示条完整显示，不裁切', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: VoiceIdleHintBar(),
          ),
        ),
      ),
    );

    expect(find.text(kVoiceIdleHintText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('录音态浮层根据阶段切换主文案和取消态样式', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              VoiceRecordingOverlay(
                stage: VoiceUiStage.recording,
                duration: Duration(milliseconds: 300),
                pulseTick: 0,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('松开发送'), findsOneWidget);
    expect(find.text('上滑取消'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('voice.recordingFrame')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('voice.waveform')), findsOneWidget);
    expect(
      tester
          .getTopLeft(
              find.byKey(const ValueKey<String>('voice.recordingFrame')))
          .dy,
      closeTo(644, 0.1),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('voice.waveform')))
          .dy,
      closeTo(694, 0.1),
    );
    expect(find.text(kVoiceIdleHintText), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              VoiceRecordingOverlay(
                stage: VoiceUiStage.recordingReadyToSend,
                duration: Duration(seconds: 1),
                pulseTick: 0,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('说完了'), findsOneWidget);
    expect(find.text('上滑取消'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('voice.readyToSendButton')),
        findsOneWidget);
    expect(
      tester
          .getTopLeft(
              find.byKey(const ValueKey<String>('voice.readyToSendButton')))
          .dy,
      closeTo(736, 0.1),
    );
    expect(find.text(kVoiceIdleHintText), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              VoiceRecordingOverlay(
                stage: VoiceUiStage.recordingWillCancel,
                duration: Duration(seconds: 1),
                pulseTick: 0,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('松手取消'), findsOneWidget);
    expect(find.text(kVoiceIdleHintText), findsNothing);
  });

  testWidgets('录音悬停发送态显示松手发送文案', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              VoiceRecordingOverlay(
                stage: VoiceUiStage.recordingHoverSend,
                duration: Duration(seconds: 2),
                pulseTick: 0,
                hoverTarget: VoiceHoverTarget.send,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('松手发送'), findsOneWidget);
    expect(find.text(kVoiceIdleHintText), findsNothing);
  });

  test('shouldShowVoiceRecordingOverlay 包含 recordingHoverSend', () {
    expect(
      shouldShowVoiceRecordingOverlay(VoiceUiStage.recordingHoverSend),
      isTrue,
    );
  });

  test('不足一秒的语音会判定为过短', () {
    expect(isVoiceMessageTooShort(const Duration(milliseconds: 500)), isTrue);
    expect(isVoiceMessageTooShort(const Duration(seconds: 1)), isFalse);
  });
}
