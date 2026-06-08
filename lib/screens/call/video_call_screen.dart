import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/app_repository.dart';
import '../../widgets/smart_avatar.dart';
import '../../widgets/smart_image.dart';

// ---------------------------------------------------------------------------
// 通话状态枚举
// ---------------------------------------------------------------------------
enum VideoCallState {
  /// 被邀请方（接听+挂断 双按钮）
  outgoingA,

  /// 主动发起等待接听（仅挂断 单按钮）
  outgoingB,

  /// 通话中（全屏对方画面 + 自己小窗 + 浮层 UI）
  active,

  /// 清屏态（隐藏全部 UI，点击恢复）
  clearScreen,
}

// ---------------------------------------------------------------------------
// 主屏幕入口
// ---------------------------------------------------------------------------
class VideoCallScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final VideoCallState initialState;

  const VideoCallScreen({
    super.key,
    required this.otherUserId,
    this.initialState = VideoCallState.outgoingA,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  late VideoCallState _callState;
  int _durationSeconds = 69;
  Timer? _timer;

  // unsplash 占位图——对方全屏 & 自己小窗
  static const String _remoteVideoUrl =
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=750&q=80';
  static const String _selfVideoUrl =
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&q=80';

  @override
  void initState() {
    super.initState();
    _callState = widget.initialState;
    if (_callState == VideoCallState.active ||
        _callState == VideoCallState.clearScreen) {
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
      setState(() => _durationSeconds++);
    });
  }

  String get _formattedDuration {
    final m = (_durationSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_durationSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onTapBackground() {
    if (_callState == VideoCallState.clearScreen) {
      setState(() => _callState = VideoCallState.active);
    } else if (_callState == VideoCallState.active) {
      setState(() => _callState = VideoCallState.clearScreen);
    }
  }

  void _onHangUp() {
    Navigator.of(context).maybePop();
  }

  void _onAnswer() {
    setState(() {
      _callState = VideoCallState.active;
      _durationSeconds = 0;
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 强制全屏，隐藏系统状态栏文字遮挡
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final otherUser = AppRepository.instance.users
        .where((u) => u.id == widget.otherUserId)
        .firstOrNull;
    final otherName = otherUser?.name ?? 'ki';
    final otherAvatar = otherUser?.avatarUrl ?? '';

    final remoteVideoSource =
        otherAvatar.isNotEmpty ? otherAvatar : _remoteVideoUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      body: switch (_callState) {
        VideoCallState.outgoingA => _OutgoingScreen(
            otherName: otherName,
            otherAvatar: otherAvatar,
            remoteVideoUrl: remoteVideoSource,
            showAnswerButton: true,
            onHangUp: _onHangUp,
            onAnswer: _onAnswer,
          ),
        VideoCallState.outgoingB => _OutgoingScreen(
            otherName: otherName,
            otherAvatar: otherAvatar,
            remoteVideoUrl: remoteVideoSource,
            showAnswerButton: false,
            onHangUp: _onHangUp,
            onAnswer: _onAnswer,
          ),
        VideoCallState.active => _ActiveScreen(
            otherName: otherName,
            otherAvatar: otherAvatar,
            remoteVideoUrl: remoteVideoSource,
            selfVideoUrl: _selfVideoUrl,
            duration: _formattedDuration,
            onTap: _onTapBackground,
            onHangUp: _onHangUp,
          ),
        VideoCallState.clearScreen => _ClearScreenOverlay(
            remoteVideoUrl: remoteVideoSource,
            selfVideoUrl: _selfVideoUrl,
            onTap: _onTapBackground,
          ),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 发起态（outgoingA / outgoingB）
// ---------------------------------------------------------------------------
class _OutgoingScreen extends StatelessWidget {
  const _OutgoingScreen({
    required this.otherName,
    required this.otherAvatar,
    required this.remoteVideoUrl,
    required this.showAnswerButton,
    required this.onHangUp,
    required this.onAnswer,
  });

  final String otherName;
  final String otherAvatar;
  final String remoteVideoUrl;
  final bool showAnswerButton;
  final VoidCallback onHangUp;
  final VoidCallback onAnswer;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sx = size.width / 375;
    final sy = size.height / 812;
    final textScale = sx.clamp(0.9, 1.08);

    return Stack(
      fit: StackFit.expand,
      children: [
        // 全屏对方视频占位
        SmartImage(
          source: remoteVideoUrl,
          fit: BoxFit.cover,
        ),

        // 顶部毛玻璃渐变遮罩
        // h=119, blur=22.2, from rgba(27,27,27,0.42) → 透明
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 119 * sy,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x6B1B1B1B), // rgba(27,27,27,0.42)
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 对方名字：PingFang SC Heavy 24px, top=623, center
        Positioned(
          top: 623 * sy,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              otherName,
              key: const ValueKey<String>('videoCall.outgoingName'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w900,
                fontSize: 24 * textScale,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        // 底部按钮区，top=669
        _buildButtons(sx, sy),
      ],
    );
  }

  Widget _buildButtons(double sx, double sy) {
    if (showAnswerButton) {
      // outgoingA：接听(绿)+挂断(红) 双按钮，left=50~right=325，各70×70
      return Positioned(
        top: 669 * sy,
        left: 50 * sx,
        width: 275 * sx,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CallButton(
              key: const ValueKey<String>('videoCall.answerButton'),
              color: const Color(0xFF34C759), // 接听绿
              icon: Icons.call,
              scale: sx,
              onTap: onAnswer,
            ),
            _CallButton(
              key: const ValueKey<String>('videoCall.hangUpButton'),
              color: const Color(0xFFE83F2B), // 挂断红
              icon: Icons.call_end,
              scale: sx,
              onTap: onHangUp,
            ),
          ],
        ),
      );
    } else {
      // outgoingB：仅挂断，居中
      return Positioned(
        top: 669 * sy,
        left: 0,
        right: 0,
        child: Center(
          child: _CallButton(
            key: const ValueKey<String>('videoCall.hangUpButton'),
            color: const Color(0xFFE83F2B),
            icon: Icons.call_end,
            scale: sx,
            onTap: onHangUp,
          ),
        ),
      );
    }
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    super.key,
    required this.color,
    required this.icon,
    required this.scale,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Figma size=70
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70 * scale,
        height: 70 * scale,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30 * scale,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 通话中（active）
// ---------------------------------------------------------------------------
class _ActiveScreen extends StatelessWidget {
  const _ActiveScreen({
    required this.otherName,
    required this.otherAvatar,
    required this.remoteVideoUrl,
    required this.selfVideoUrl,
    required this.duration,
    required this.onTap,
    required this.onHangUp,
  });

  final String otherName;
  final String otherAvatar;
  final String remoteVideoUrl;
  final String selfVideoUrl;
  final String duration;
  final VoidCallback onTap;
  final VoidCallback onHangUp;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // 基准屏幕宽度 375
    final scale = size.width / 375;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // --- 全屏对方画面 ---
          SmartImage(source: remoteVideoUrl, fit: BoxFit.cover),

          // --- 顶部信息栏背景 ---
          // Figma: bg rgba(26,26,26,0.4), h=49, left=4, radius=25.5, top=47, w=182
          Positioned(
            top: 47 * scale,
            left: 4 * scale,
            width: 182 * scale,
            height: 49 * scale,
            child: Container(
              key: const ValueKey<String>('videoCall.topInfoBar'),
              decoration: BoxDecoration(
                color: const Color(0x661A1A1A),
                borderRadius: BorderRadius.circular(25.5 * scale),
              ),
            ),
          ),

          // --- 对方头像，left=28.5(center-156.5+128≈) 实际 figma left=calc(50%-156.5px)=30.75, size=40, top=52 ---
          Positioned(
            top: 52 * scale,
            left: 11 * scale,
            child: SmartAvatar(
              key: const ValueKey<String>('videoCall.activeAvatar'),
              radius: 20 * scale,
              source: otherAvatar,
              fallbackName: otherName,
            ),
          ),

          // --- 对方名字: PingFang SC Medium 18px, top=50, left=calc(50%-108px)=79.5 ---
          Positioned(
            top: 50 * scale,
            left: 61 * scale,
            child: Text(
              otherName,
              key: const ValueKey<String>('videoCall.activeName'),
              style: TextStyle(
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w500,
                fontSize: 18 * scale,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),

          // --- 红色加号胶囊：bg #e83f2b, h=20, left=139, top=62, w=38 ---
          Positioned(
            top: 62 * scale,
            left: 139 * scale,
            child: Container(
              key: const ValueKey<String>('videoCall.followButton'),
              width: 38 * scale,
              height: 20 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFE83F2B),
                borderRadius: BorderRadius.circular(25.5 * scale),
              ),
              alignment: Alignment.center,
              child: Text(
                '+',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PingFang SC',
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),
          ),

          // --- 时长：PingFang SC Medium 12px, top=75 ---
          Positioned(
            top: 75 * scale,
            left: 61 * scale,
            child: Text(
              '时长：$duration',
              key: const ValueKey<String>('videoCall.durationText'),
              style: TextStyle(
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w500,
                fontSize: 12 * scale,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),

          // --- 关闭按钮，right=14 top=64 size=18 ---
          Positioned(
            top: 64 * scale,
            right: 14 * scale,
            child: GestureDetector(
              key: const ValueKey<String>('videoCall.closeButton'),
              onTap: onHangUp,
              child: Icon(Icons.close, color: Colors.white, size: 18 * scale),
            ),
          ),

          // --- 自己小窗：w=98 h=137 left=12 top=111 radius=11 ---
          Positioned(
            top: 111 * scale,
            left: 12 * scale,
            width: 98 * scale,
            height: 137 * scale,
            child: SizedBox(
              key: const ValueKey<String>('videoCall.selfWindow'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11 * scale),
                child: SmartImage(source: selfVideoUrl, fit: BoxFit.cover),
              ),
            ),
          ),

          // --- 右侧工具栏（表情/相机/录像/麦克风）---
          // Figma: left=87.2%(327px), top=127 起，每格 23×23，radius=9.27，间距约 46
          // 「预留待确认」：图标用 Material 近似
          Positioned(
            top: 127 * scale,
            right: 14 * scale,
            child: Column(
              children: [
                _SideToolButton(
                  key: const ValueKey<String>('videoCall.sideTool.emoji'),
                  icon: Icons.emoji_emotions_outlined,
                  scale: scale,
                ),
                SizedBox(height: 12 * scale),
                _SideToolButton(
                  key: const ValueKey<String>('videoCall.sideTool.camera'),
                  icon: Icons.camera_alt_outlined,
                  scale: scale,
                ),
                SizedBox(height: 12 * scale),
                _SideToolButton(
                  key: const ValueKey<String>('videoCall.sideTool.video'),
                  icon: Icons.videocam_outlined,
                  scale: scale,
                ),
                SizedBox(height: 12 * scale),
                _SideToolButton(
                  key: const ValueKey<String>('videoCall.sideTool.mic'),
                  icon: Icons.mic_none,
                  scale: scale,
                ),
              ],
            ),
          ),

          // --- 赠送礼物气泡背景：rgba(26,26,26,0.4), h=41 left=14 top=531 w=144 radius=26 ---
          Positioned(
            top: 531 * scale,
            left: 14 * scale,
            width: 144 * scale,
            height: 41 * scale,
            child: Container(
              key: const ValueKey<String>('videoCall.giftBubble'),
              decoration: BoxDecoration(
                color: const Color(0x661A1A1A),
                borderRadius: BorderRadius.circular(26 * scale),
              ),
            ),
          ),

          // --- 赠送文字 + 表情 + x1 ---
          Positioned(
            top: 540 * scale,
            left: 30 * scale,
            child: Row(
              children: [
                Text(
                  '赠送',
                  style: TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    fontSize: 18 * scale,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(width: 4 * scale),
                // 「预留待确认」：礼物表情图，用 emoji 近似
                Text('🎉', style: TextStyle(fontSize: 16 * scale)),
                SizedBox(width: 4 * scale),
                Text(
                  'x1',
                  style: TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    fontSize: 18 * scale,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // --- 消息区域背景：rgba(26,26,26,0.4), h=144, left=14, top=580, w=246, radius=17 ---
          Positioned(
            top: 580 * scale,
            left: 14 * scale,
            width: 246 * scale,
            height: 144 * scale,
            child: Container(
              key: const ValueKey<String>('videoCall.messagePanel'),
              decoration: BoxDecoration(
                color: const Color(0x661A1A1A),
                borderRadius: BorderRadius.circular(17 * scale),
              ),
            ),
          ),

          // --- 消息文本 ---
          Positioned(
            top: 589 * scale,
            left: 30 * scale,
            width: 215 * scale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '系统通知：平台文明交友，\n文明交友，文明交友！',
                  style: TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    fontSize: 18 * scale,
                    color: Colors.white,
                    letterSpacing: 1,
                    height: 1.22,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '我：你好啊！',
                  style: TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    fontSize: 18 * scale,
                    color: const Color(0xFFB8A6FF),
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  'ki：HAL！',
                  style: TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    fontSize: 18 * scale,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // --- 礼物快捷按钮（右下浮标）：left=319, top=665, size=52, radius=25.5 ---
          // 「预留待确认」：内部图标用 card_giftcard 近似
          Positioned(
            top: 665 * scale,
            right: 4 * scale,
            child: Container(
              key: const ValueKey<String>('videoCall.giftButton'),
              width: 52 * scale,
              height: 52 * scale,
              decoration: BoxDecoration(
                color: const Color(0x661A1A1A),
                borderRadius: BorderRadius.circular(25.5 * scale),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard, // 「预留待确认」
                    color: Colors.white,
                    size: 20 * scale,
                  ),
                  Text(
                    '鼓掌',
                    style: TextStyle(
                      fontFamily: 'PingFang SC',
                      fontSize: 9 * scale,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 底部输入框：rgba(26,26,26,0.6), h=40, left=14, w=305, radius=41, top=738 ---
          Positioned(
            bottom: 34 * scale,
            left: 14 * scale,
            width: 305 * scale,
            height: 40 * scale,
            child: Container(
              key: const ValueKey<String>('videoCall.inputBar'),
              decoration: BoxDecoration(
                color: const Color(0x991A1A1A),
                borderRadius: BorderRadius.circular(41 * scale),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              alignment: Alignment.centerLeft,
              child: Text(
                '聊点刺激的事情...',
                style: TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 14 * scale,
                  color: Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // --- 底部视频快捷按钮：rgba(26,26,26,0.6), left=328, top=741, size=33, radius=62.6 ---
          // 「预留待确认」：用 videocam 近似
          Positioned(
            top: 741 * scale,
            right: 14 * scale,
            child: Container(
              key: const ValueKey<String>('videoCall.videoButton'),
              width: 33 * scale,
              height: 33 * scale,
              decoration: BoxDecoration(
                color: const Color(0x991A1A1A),
                borderRadius: BorderRadius.circular(62.6 * scale),
              ),
              child: Icon(
                Icons.videocam, // 「预留待确认」
                color: Colors.white,
                size: 18 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 右侧工具栏小按钮，23×23，radius=9.27，bg rgba(26,26,26,0.4)
class _SideToolButton extends StatelessWidget {
  const _SideToolButton({
    super.key,
    required this.icon,
    required this.scale,
  });
  final IconData icon;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34 * scale,
      height: 34 * scale,
      decoration: BoxDecoration(
        color: const Color(0x661A1A1A),
        borderRadius: BorderRadius.circular(17 * scale),
      ),
      child: Icon(icon, color: Colors.white, size: 24 * scale),
    );
  }
}

// ---------------------------------------------------------------------------
// 清屏态（clearScreen）
// ---------------------------------------------------------------------------
class _ClearScreenOverlay extends StatelessWidget {
  const _ClearScreenOverlay({
    required this.remoteVideoUrl,
    required this.selfVideoUrl,
    required this.onTap,
  });

  final String remoteVideoUrl;
  final String selfVideoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = size.width / 375;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 全屏对方画面（清屏态 UI 全隐，仅留画面）
          SmartImage(source: remoteVideoUrl, fit: BoxFit.cover),

          // 自己小窗依然保留（Figma 清屏截图中小窗仍可见）
          // w=98, h=137, left=12, top=111, radius=11
          Positioned(
            top: 111 * scale,
            left: 12 * scale,
            width: 98 * scale,
            height: 137 * scale,
            child: SizedBox(
              key: const ValueKey<String>('videoCall.selfWindow'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11 * scale),
                child: SmartImage(source: selfVideoUrl, fit: BoxFit.cover),
              ),
            ),
          ),

          // 关闭按钮（Figma 清屏截图中右上角 × 仍可见，left=343, top=64, size=18）
          Positioned(
            top: 64 * scale,
            right: 14 * scale,
            child: Icon(
              Icons.close,
              key: const ValueKey<String>('videoCall.closeButton'),
              color: Colors.white,
              size: 18 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
