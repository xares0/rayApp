import 'package:flutter/material.dart';

const Duration kMinVoiceMessageDuration = Duration(seconds: 1);
const Duration kVoiceReadyToSendStageDelay = kMinVoiceMessageDuration;
const String kVoiceIdleHintText = '按住说话，手指上滑可取消';

enum VoiceHoverTarget { none, cancel, send }

enum VoiceUiStage {
  voiceIdle,
  recording,
  recordingReadyToSend,
  recordingWillCancel,
  recordingHoverSend,
}

VoiceUiStage? deriveVoiceUiStage({
  required bool voiceMode,
  required bool isRecording,
  required bool willCancel,
  required bool hoverSend,
  required Duration duration,
}) {
  if (!voiceMode) return null;
  if (!isRecording) return VoiceUiStage.voiceIdle;
  if (willCancel) return VoiceUiStage.recordingWillCancel;
  if (hoverSend) return VoiceUiStage.recordingHoverSend;
  if (duration < kVoiceReadyToSendStageDelay) {
    return VoiceUiStage.recording;
  }
  return VoiceUiStage.recordingReadyToSend;
}

bool isVoiceMessageTooShort(Duration duration) {
  return duration < kMinVoiceMessageDuration;
}

bool shouldShowVoiceIdleHint(VoiceUiStage? stage) {
  return stage == VoiceUiStage.voiceIdle;
}

bool shouldShowVoiceRecordingOverlay(VoiceUiStage? stage) {
  return stage == VoiceUiStage.recording ||
      stage == VoiceUiStage.recordingReadyToSend ||
      stage == VoiceUiStage.recordingWillCancel ||
      stage == VoiceUiStage.recordingHoverSend;
}

String formatVoiceRecordDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String buildVoiceHoldButtonText({
  required bool isRecording,
  required bool willCancel,
  required bool hoverSend,
}) {
  if (!isRecording) return '按住说话';
  if (willCancel) return '松手取消发送';
  if (hoverSend) return '松手发送';
  return '松开发送，上滑取消';
}

String buildVoiceBottomPrimaryText(VoiceUiStage stage) {
  switch (stage) {
    case VoiceUiStage.voiceIdle:
      return '';
    case VoiceUiStage.recording:
      return '松开发送';
    case VoiceUiStage.recordingReadyToSend:
      return '说完了';
    case VoiceUiStage.recordingWillCancel:
      return '松手取消';
    case VoiceUiStage.recordingHoverSend:
      return '松手发送';
  }
}

String? buildVoiceSideHintText(VoiceUiStage stage) {
  switch (stage) {
    case VoiceUiStage.recording:
      return '上滑取消';
    case VoiceUiStage.recordingReadyToSend:
      return '上滑取消';
    case VoiceUiStage.recordingWillCancel:
      return null;
    case VoiceUiStage.recordingHoverSend:
      return null;
    case VoiceUiStage.voiceIdle:
      return null;
  }
}

Alignment buildVoiceSideHintAlignment(VoiceUiStage stage) {
  switch (stage) {
    case VoiceUiStage.recordingWillCancel:
      return const Alignment(-0.62, 0);
    case VoiceUiStage.recording:
    case VoiceUiStage.recordingReadyToSend:
    case VoiceUiStage.recordingHoverSend:
    case VoiceUiStage.voiceIdle:
      return const Alignment(0.6, 0);
  }
}

class VoiceIdleHintBar extends StatelessWidget {
  const VoiceIdleHintBar({
    super.key,
    this.text = kVoiceIdleHintText,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width - 40;
    return Center(
      child: Container(
        constraints: BoxConstraints(
          minHeight: 34,
          maxWidth: maxWidth,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F2FF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFDCCEFF)),
        ),
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8E7CF7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 18 / 13,
          ),
        ),
      ),
    );
  }
}

typedef VoiceCirclePositionsCallback = void Function(
  Offset cancelCenter,
  Offset sendCenter,
);

class VoiceRecordingOverlay extends StatefulWidget {
  const VoiceRecordingOverlay({
    super.key,
    required this.stage,
    required this.duration,
    required this.pulseTick,
    this.bottomInset = 0,
    this.hoverTarget = VoiceHoverTarget.none,
    this.onCirclePositionsReady,
  });

  final VoiceUiStage stage;
  final Duration duration;
  final int pulseTick;
  final double bottomInset;
  final VoiceHoverTarget hoverTarget;
  final VoiceCirclePositionsCallback? onCirclePositionsReady;

  @override
  State<VoiceRecordingOverlay> createState() => _VoiceRecordingOverlayState();
}

class _VoiceRecordingOverlayState extends State<VoiceRecordingOverlay> {
  final GlobalKey _cancelCircleKey = GlobalKey();
  final GlobalKey _sendCircleKey = GlobalKey();

  bool get _isCancelStage => widget.stage == VoiceUiStage.recordingWillCancel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportCirclePositions();
    });
  }

  void _reportCirclePositions() {
    if (widget.onCirclePositionsReady == null) return;
    final cancelCenter = _centerOfKey(_cancelCircleKey);
    final sendCenter = _centerOfKey(_sendCircleKey);
    if (cancelCenter != null && sendCenter != null) {
      widget.onCirclePositionsReady!(cancelCenter, sendCenter);
    }
  }

  Offset? _centerOfKey(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final size = renderBox.size;
    return renderBox.localToGlobal(Offset(size.width / 2, size.height / 2));
  }

  @override
  Widget build(BuildContext context) {
    final sideHint = buildVoiceSideHintText(widget.stage);
    final bottomPrimary = buildVoiceBottomPrimaryText(widget.stage);
    return IgnorePointer(
      ignoring: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / 375;
          final top = (constraints.maxHeight - widget.bottomInset) -
              (812 - 644) * scale;
          return Stack(
            children: [
              Positioned(
                left: 88 * scale,
                top: top,
                width: 200 * scale,
                height: 200 * scale,
                child: SizedBox(
                  key: const ValueKey<String>('voice.recordingFrame'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 86 * scale,
                        child: Opacity(
                          opacity: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _VoiceActionCircle(
                                key: _cancelCircleKey,
                                label: '取消',
                                size: 56 * scale,
                                highlighted: widget.hoverTarget ==
                                    VoiceHoverTarget.cancel,
                                highlightColor: const Color(0xFFFF5A5D),
                              ),
                              _VoiceActionCircle(
                                key: _sendCircleKey,
                                label: '发送',
                                size: 68 * scale,
                                highlighted:
                                    widget.hoverTarget == VoiceHoverTarget.send,
                                highlightColor: const Color(0xFF9F90FF),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 36 * scale,
                        top: 50 * scale,
                        width: 127 * scale,
                        height: 25 * scale,
                        child: Semantics(
                          label: _isCancelStage
                              ? '录音取消态'
                              : '录音中 ${formatVoiceRecordDuration(widget.duration)}',
                          child: _VoiceFigmaWaveform(
                            stage: widget.stage,
                            pulseTick: widget.pulseTick,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 42 * scale,
                        top: 92 * scale,
                        width: 116 * scale,
                        height: 33 * scale,
                        child: widget.stage == VoiceUiStage.recordingReadyToSend
                            ? _VoiceReadyToSendButton(label: bottomPrimary)
                            : Center(
                                child: Text(
                                  bottomPrimary,
                                  style: TextStyle(
                                    color: const Color(0xFF666666),
                                    fontSize: 18 * scale,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                      ),
                      if (sideHint != null)
                        Positioned(
                          left: 128 * scale,
                          top: 21 * scale,
                          width: 80 * scale,
                          child: Text(
                            sideHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF999999),
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VoiceFigmaWaveform extends StatelessWidget {
  const _VoiceFigmaWaveform({
    required this.stage,
    required this.pulseTick,
  });

  final VoiceUiStage stage;
  final int pulseTick;

  @override
  Widget build(BuildContext context) {
    final heights = stage == VoiceUiStage.recordingWillCancel
        ? const <double>[10, 14, 18, 12, 22, 16, 10, 18, 14, 10, 16, 12]
        : const <double>[
            8,
            13,
            18,
            12,
            24,
            17,
            10,
            29,
            20,
            12,
            24,
            15,
            9,
            18,
            12,
            8,
          ];
    final color = stage == VoiceUiStage.recordingWillCancel
        ? const Color(0xFFFF5A5D)
        : const Color(0xFF777777);

    return LayoutBuilder(
      key: const ValueKey<String>('voice.waveform'),
      builder: (context, constraints) {
        final scale = constraints.maxHeight / 25;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int index = 0; index < heights.length; index++) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                width: 2 * scale,
                height: heights[(index + pulseTick) % heights.length] * scale,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2 * scale),
                ),
              ),
              if (index != heights.length - 1) SizedBox(width: 5 * scale),
            ],
          ],
        );
      },
    );
  }
}

class _VoiceActionCircle extends StatelessWidget {
  const _VoiceActionCircle({
    super.key,
    required this.label,
    required this.size,
    this.highlighted = false,
    this.highlightColor,
  });

  final String label;
  final double size;
  final bool highlighted;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = highlightColor ?? Colors.white;
    return AnimatedScale(
      scale: highlighted ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: highlighted ? effectiveColor : Colors.white,
          shape: BoxShape.circle,
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: effectiveColor.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: highlighted
                ? Colors.white
                : label == '取消'
                    ? const Color(0xFF333333)
                    : const Color(0xFF666666),
            fontSize: 18,
            fontWeight: label == '取消' ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// 07节点：录音「说完了」渐变按钮
/// Figma: 宽116, 高33, 圆角18.5, 渐变 #7DDFFF→#DCA0FF
/// 文字: PingFang SC Medium, 14px, 白色
class _VoiceReadyToSendButton extends StatelessWidget {
  const _VoiceReadyToSendButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey<String>('voice.readyToSendButton'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.5),
        gradient: const LinearGradient(
          colors: [Color(0xFF7DDFFF), Color(0xFFDCA0FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
