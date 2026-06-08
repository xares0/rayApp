import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 语音转文字弹窗。
/// 显示声纹动效（AnimatedBuilder + 随机高度竖条），底部有【说完了】按钮。
/// 点击【说完了】返回 mock 转写文本；关闭弹窗时正确停止 Timer/Animation。
class VoiceToTextDialog extends StatefulWidget {
  const VoiceToTextDialog({super.key});

  @override
  State<VoiceToTextDialog> createState() => _VoiceToTextDialogState();
}

class _VoiceToTextDialogState extends State<VoiceToTextDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _barTimer;

  static const int _barCount = 18;
  final List<double> _barHeights = List.filled(_barCount, 0.3);
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    // 每 120ms 随机更新各竖条高度，模拟声纹
    _barTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < _barCount; i++) {
          _barHeights[i] = 0.15 + _random.nextDouble() * 0.85;
        }
      });
    });
  }

  @override
  void dispose() {
    _barTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onDone() {
    Navigator.of(context).pop('你好，这是语音转写的文字内容');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '语音转文字',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF999999),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 录音中提示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE15D5D).withValues(
                      alpha: 0.4 + 0.6 * _controller.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '录音中…',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 声纹动效区域
          SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_barCount, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 110),
                  curve: Curves.easeInOut,
                  width: 4,
                  height: 64 * _barHeights[i],
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      const Color(0xFF8B5CF6),
                      const Color(0xFFD946EF),
                      _barHeights[i],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 32),

          // 【说完了】按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                '说完了',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
