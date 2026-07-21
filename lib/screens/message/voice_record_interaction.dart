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

/// vv2「录音」：底部白条主文案。录音/可发送态显示「松开发送」，
/// 取消/悬停发送态退回「语音」（提示词改由圆按钮上方的标签承载）。
String buildVoiceBottomPrimaryText(VoiceUiStage stage) {
  switch (stage) {
    case VoiceUiStage.recording:
    case VoiceUiStage.recordingReadyToSend:
      return '松开发送';
    case VoiceUiStage.recordingWillCancel:
    case VoiceUiStage.recordingHoverSend:
    case VoiceUiStage.voiceIdle:
      return '语音';
  }
}

/// vv2「录音」：拖到取消/发送圆按钮上方时的提示标签（松手取消 / 松手发送）。
String? buildVoiceCircleHintText(VoiceUiStage stage) {
  switch (stage) {
    case VoiceUiStage.recordingWillCancel:
      return '松手取消';
    case VoiceUiStage.recordingHoverSend:
      return '松手发送';
    case VoiceUiStage.recording:
    case VoiceUiStage.recordingReadyToSend:
    case VoiceUiStage.voiceIdle:
      return null;
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

/// vv2「录音」浮层（node 37:375）。
///
/// 布局以 375×812 设计帧为基准、锚定屏幕底部：
/// - 取消圆 80，中心 (80.4, 630)；发送圆 92，中心 (289.4, 630)
/// - 波形气泡：常态 #9F90FF 居中 (98,486,179×60)，取消态 #FF5A5D 移到取消圆上方 (37,486,82×60)
/// - 气泡底部居中下三角尾巴 20×10
/// - 底部白条主文案（松开发送 / 语音）+ 圆按钮上方提示（松手取消 / 松手发送）
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

  bool get _willCancel => widget.stage == VoiceUiStage.recordingWillCancel;
  bool get _hoverSend => widget.stage == VoiceUiStage.recordingHoverSend;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportCirclePositions();
    });
  }

  @override
  void didUpdateWidget(covariant VoiceRecordingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    final bottomText = buildVoiceBottomPrimaryText(widget.stage);
    final circleHint = buildVoiceCircleHintText(widget.stage);
    return IgnorePointer(
      ignoring: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / 375;
          final inset = widget.bottomInset;
          // 设计帧 812 高，元素按"距底部"锚定到屏幕底部（安全区之上）。
          double bottomOf(double figmaTop, double height) =>
              (812 - (figmaTop + height)) * scale + inset;

          return Stack(
            key: const ValueKey<String>('voice.recordingFrame'),
            children: [
              // 半透明遮罩：录音态蒙住聊天背景
              const Positioned.fill(
                child: ColoredBox(color: Color(0x66000000)),
              ),
              // 底部凹形白条（Ellipse 2758，中间凸起的圆顶）+ 主文案贴圆顶下方
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 108 * scale + inset,
                child: CustomPaint(
                  painter: _NotchedBarPainter(domeRise: 40 * scale),
                  child: Padding(
                    // 排除底部 home indicator 区，文字在白条主体内居中偏上
                    padding: EdgeInsets.only(bottom: inset),
                    child: Align(
                      alignment: const Alignment(0, -0.1),
                      child: Text(
                        bottomText,
                        style: TextStyle(
                          color: const Color(0xFF666666),
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 取消圆 80
              Positioned(
                left: 40.38 * scale,
                bottom: bottomOf(590, 80),
                width: 80 * scale,
                height: 80 * scale,
                child: _VoiceActionCircle(
                  key: _cancelCircleKey,
                  label: '取消',
                  diameter: 80 * scale,
                  fontSize: 18 * scale,
                  highlighted: _willCancel,
                ),
              ),
              // 发送圆 92
              Positioned(
                left: 243.38 * scale,
                bottom: bottomOf(584, 92),
                width: 92 * scale,
                height: 92 * scale,
                child: _VoiceActionCircle(
                  key: _sendCircleKey,
                  label: '发送',
                  diameter: 92 * scale,
                  fontSize: 18 * scale,
                  highlighted: _hoverSend,
                ),
              ),
              // 波形气泡（取消态左移变窄变红）
              Positioned(
                left: (_willCancel ? 37.0 : 98.0) * scale,
                bottom: bottomOf(486, 70),
                width: (_willCancel ? 82.0 : 179.0) * scale,
                height: 70 * scale,
                child: _VoiceWaveBubble(
                  stage: widget.stage,
                  pulseTick: widget.pulseTick,
                  scale: scale,
                ),
              ),
              // 圆按钮上方提示（松手取消 / 松手发送）
              if (circleHint != null)
                Positioned(
                  left: (_willCancel ? 30.0 : 240.0) * scale,
                  bottom: bottomOf(_willCancel ? 567 : 561, 17),
                  width: 96 * scale,
                  child: Text(
                    circleHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF999999),
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w400,
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

/// 取消 / 发送 圆按钮。默认浅灰，拖到其上方高亮时变白 + 阴影 + 放大。
class _VoiceActionCircle extends StatelessWidget {
  const _VoiceActionCircle({
    super.key,
    required this.label,
    required this.diameter,
    required this.fontSize,
    this.highlighted = false,
  });

  final String label;
  final double diameter;
  final double fontSize;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: highlighted ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: diameter,
        height: diameter,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: highlighted ? Colors.white : const Color(0xFFD9D9D9),
          shape: BoxShape.circle,
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: highlighted
                ? const Color(0xFF333333)
                : const Color(0xFF666666),
            fontSize: fontSize,
            fontWeight: highlighted ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// 波形气泡：圆角矩形 + 底部居中下三角尾巴 + 内部波形条。
/// 常态紫 #9F90FF（白条）；取消态红 #FF5A5D（#666 深条）。
class _VoiceWaveBubble extends StatelessWidget {
  const _VoiceWaveBubble({
    required this.stage,
    required this.pulseTick,
    required this.scale,
  });

  final VoiceUiStage stage;
  final int pulseTick;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final cancel = stage == VoiceUiStage.recordingWillCancel;
    final bubbleColor =
        cancel ? const Color(0xFFFF5A5D) : const Color(0xFF9F90FF);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 60 * scale,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Center(
              child: _VoiceWaveform(
                cancel: cancel,
                pulseTick: pulseTick,
                scale: scale,
              ),
            ),
          ),
        ),
        CustomPaint(
          size: Size(20 * scale, 10 * scale),
          painter: _BubbleTailPainter(bubbleColor),
        ),
      ],
    );
  }
}

class _VoiceWaveform extends StatelessWidget {
  const _VoiceWaveform({
    required this.cancel,
    required this.pulseTick,
    required this.scale,
  });

  final bool cancel;
  final int pulseTick;
  final double scale;

  @override
  Widget build(BuildContext context) {
    // 取消态：#666 细条 (w2)；常态：白色条 (w4)。
    final heights = cancel
        ? const <double>[12, 8, 12, 8, 12, 12, 8, 12, 8]
        : const <double>[12, 16, 12, 16, 12, 16, 12, 16, 12];
    final color = cancel ? const Color(0xFF666666) : Colors.white;
    final barWidth = (cancel ? 2.0 : 4.0) * scale;
    final gap = (cancel ? 3.0 : 4.5) * scale;

    return Row(
      key: const ValueKey<String>('voice.waveform'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int index = 0; index < heights.length; index++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: barWidth,
            height: heights[(index + pulseTick) % heights.length] * scale,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4 * scale),
            ),
          ),
          if (index != heights.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// 底部白条：顶边中间凸起的圆顶（Ellipse 2758），盖住录音态的输入栏工具区。
class _NotchedBarPainter extends CustomPainter {
  _NotchedBarPainter({required this.domeRise});

  final double domeRise;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, domeRise)
      ..quadraticBezierTo(size.width / 2, 0, size.width, domeRise)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchedBarPainter oldDelegate) {
    return oldDelegate.domeRise != domeRise;
  }
}
