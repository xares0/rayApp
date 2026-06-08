import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/profile_provider.dart';
import '../../widgets/smart_image.dart';

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

enum VoiceCallState { outgoing, incoming, active }

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class VoiceCallScreen extends ConsumerStatefulWidget {
  const VoiceCallScreen({
    super.key,
    required this.otherUserId,
    this.initialState = VoiceCallState.outgoing,
  });

  final String otherUserId;
  final VoiceCallState initialState;

  @override
  ConsumerState<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen> {
  static const double _designWidth = 375;
  static const double _designHeight = 812;

  late VoiceCallState _callState;
  int _elapsedSeconds = 23;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _callState = widget.initialState;
    if (_callState == VoiceCallState.active) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String get _timerLabel {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _hangUp() {
    _stopTimer();
    if (mounted) Navigator.of(context).maybePop();
  }

  void _answer() {
    _stopTimer();
    _elapsedSeconds = 0;
    setState(() => _callState = VoiceCallState.active);
    _startTimer();
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileUserProvider(widget.otherUserId));
    final size = MediaQuery.of(context).size;
    final sx = size.width / _designWidth;
    final sy = size.height / _designHeight;
    final textScale = sx.clamp(0.9, 1.08);

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(user.avatarUrl),
          Positioned(
            left: 112.5 * sx,
            top: 210 * sy,
            width: 150 * sx,
            height: 150 * sx,
            child: _buildLargeAvatar(user.avatarUrl, 150 * sx),
          ),
          Positioned(
            top: 372 * sy,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                key: const ValueKey<String>('voiceCall.displayName'),
                user.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w800,
                  fontSize: 24 * textScale,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          Positioned(
            top: (_callState == VoiceCallState.active ? 635 : 508) * sy,
            left: 0,
            right: 0,
            child: _buildStatusText(user.name, textScale),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 669 * sy,
            child: _buildButtonRow(sx),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Background
  // -------------------------------------------------------------------------

  Widget _buildBackground(String avatarUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SmartImage(
          source: avatarUrl,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 22.2, sigmaY: 22.2),
          child: const SizedBox.expand(),
        ),
        Container(
          color: const Color(0xB31B1B1B),
        ),
      ],
    );
  }

  Widget _buildLargeAvatar(String avatarUrl, double size) {
    return ClipRRect(
      key: const ValueKey<String>('voiceCall.largeAvatar'),
      borderRadius: BorderRadius.circular(17),
      child: SmartImage(
        source: avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Status text
  // -------------------------------------------------------------------------

  Widget _buildStatusText(String name, double textScale) {
    switch (_callState) {
      case VoiceCallState.outgoing:
        return Text(
          '等待接听...',
          key: const ValueKey<String>('voiceCall.statusText'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w500,
            fontSize: 18 * textScale,
            color: Colors.white,
            letterSpacing: 1,
          ),
        );
      case VoiceCallState.incoming:
        return Text(
          '$name正在邀请你语音通话...',
          key: const ValueKey<String>('voiceCall.statusText'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        );
      case VoiceCallState.active:
        return Text(
          _timerLabel,
          key: const ValueKey<String>('voiceCall.statusText'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        );
    }
  }

  // -------------------------------------------------------------------------
  // Button row
  // -------------------------------------------------------------------------

  Widget _buildButtonRow(double scale) {
    switch (_callState) {
      case VoiceCallState.outgoing:
      case VoiceCallState.active:
        return Center(
          child: _buildHangUpButton(scale),
        );
      case VoiceCallState.incoming:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHangUpButton(scale),
            SizedBox(width: 135 * scale),
            _buildAnswerButton(scale),
          ],
        );
    }
  }

  Widget _buildHangUpButton(double scale) {
    return GestureDetector(
      key: const ValueKey<String>('voiceCall.hangUpButton'),
      onTap: _hangUp,
      child: Container(
        width: 70 * scale,
        height: 70 * scale,
        decoration: const BoxDecoration(
          color: Color(0xFFF33B2E),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.call_end,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildAnswerButton(double scale) {
    return GestureDetector(
      key: const ValueKey<String>('voiceCall.answerButton'),
      onTap: _answer,
      child: Container(
        width: 70 * scale,
        height: 70 * scale,
        decoration: const BoxDecoration(
          color: Color(0xFF43D981),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.call,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
