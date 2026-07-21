import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 语音转文字 —— 内联态（Figma v4 `37:11783`）。
///
/// 点输入区「语音转文字」图标后，在图标行下方就地展开：
/// 一条紧凑灰色声纹波形 + 一颗小号紫色渐变「说完了」胶囊。
/// 点【说完了】通过 [onDone] 回传 mock 转写文本（不再弹全屏模态）。
class InlineVoiceToText extends StatefulWidget {
  const InlineVoiceToText({super.key, required this.onDone});

  /// 转写完成回调，参数为转写文本。
  final ValueChanged<String> onDone;

  @override
  State<InlineVoiceToText> createState() => _InlineVoiceToTextState();
}

class _InlineVoiceToTextState extends State<InlineVoiceToText> {
  Timer? _barTimer;

  static const int _barCount = 22;
  final List<double> _barHeights = List.filled(_barCount, 0.3);
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _barTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < _barCount; i++) {
          _barHeights[i] = 0.2 + _random.nextDouble() * 0.8;
        }
      });
    });
  }

  @override
  void dispose() {
    _barTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 紧凑灰色声纹波形
        SizedBox(
          height: 28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_barCount, (i) {
              return AnimatedContainer(
                key: ValueKey<String>('voiceInline.bar.$i'),
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeInOut,
                width: 3,
                height: 28 * _barHeights[i],
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFB6B6C2),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        // 小号紫色渐变「说完了」胶囊
        GestureDetector(
          key: const ValueKey<String>('voiceInline.done'),
          onTap: () => widget.onDone('你好，这是语音转写的文字内容'),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 104,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFA597DF), Color(0xFF8673D4)],
              ),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Text(
              '说完了',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
