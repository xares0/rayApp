import 'package:flutter/material.dart';

/// 可翻译文本组件：默认显示译文，文本结尾带【翻译】icon，
/// 点击切换显示原文，再次点击恢复译文。
///
/// 第四次迭代复用点：
/// - 02 个性签名翻译交互（用户主页摄影心得/个签）
/// - 04 动态文本交互（如需翻译态，可在折叠组件外层包裹）
/// - 08 私聊资料卡个签翻译
///
/// 若 [original] 为空或与 [translated] 相同，则不显示翻译 icon（无可切换原文）。
class TranslatableText extends StatefulWidget {
  const TranslatableText({
    super.key,
    required this.translated,
    this.original,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.iconSize = 14,
    this.iconColor = const Color(0xFF999999),
    this.iconActiveColor = const Color(0xFF7C67D0),
  });

  /// 译文（默认展示）。
  final String translated;

  /// 原文（点击翻译 icon 后展示）。为空表示无原文，不展示 icon。
  final String? original;

  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final double iconSize;

  /// 译文态 icon 颜色。
  final Color iconColor;

  /// 原文态（已点开）icon 颜色。
  final Color iconActiveColor;

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText> {
  bool _showOriginal = false;

  bool get _canTranslate {
    final original = widget.original;
    return original != null &&
        original.trim().isNotEmpty &&
        original != widget.translated;
  }

  void _toggle() => setState(() => _showOriginal = !_showOriginal);

  @override
  Widget build(BuildContext context) {
    final content = _showOriginal ? widget.original! : widget.translated;

    if (!_canTranslate) {
      return Text(
        content,
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: content),
          const WidgetSpan(child: SizedBox(width: 4)),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              key: const ValueKey<String>('translatableText.toggle'),
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: Icon(
                Icons.translate,
                size: widget.iconSize,
                color: _showOriginal ? widget.iconActiveColor : widget.iconColor,
              ),
            ),
          ),
        ],
      ),
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
