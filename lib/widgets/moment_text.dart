import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 动态文本组件（第四次迭代 3.1，Figma v4 `37:11344`）：
/// - 默认显示译文，结尾【翻译】图标（圆形「A」，灰色）。
/// - 点【翻译】图标 → 原文（灰色）显示在译文**下方**（双语同显），图标变紫色；
///   再点恢复仅译文显示。
/// - 折叠规则：译文默认最多 [collapsedMaxLines] 行（默认 2），超出时第二行结尾
///   显示【展开】（灰色），点击展开全文并显示【收起】。
///
/// 复用：动态列表、动态详情、动态视频全屏。视频等深色背景传 [maskColor]
/// 为对应底色以遮罩折叠处，并用浅色 [translateIdleColor] / [actionColor]。
class MomentText extends StatefulWidget {
  const MomentText({
    super.key,
    required this.translated,
    this.original,
    this.style,
    this.collapsedMaxLines = 2,
    this.actionColor = const Color(0xFF7C67D0),
    this.translateIdleColor = const Color(0xFF999999),
    this.maskColor = Colors.white,
  });

  final String translated;
  final String? original;
  final TextStyle? style;
  final int collapsedMaxLines;

  /// 【翻译】图标激活（显示原文）时的颜色（紫色）。
  final Color actionColor;

  /// 【翻译】图标默认（显示译文）色 + 【展开】【收起】文字链 + 原文正文颜色（灰色）。
  final Color translateIdleColor;

  /// 折叠态右下角遮罩底色（需与所在卡片背景一致）。
  final Color maskColor;

  @override
  State<MomentText> createState() => _MomentTextState();
}

class _MomentTextState extends State<MomentText> {
  /// 【翻译】图标尺寸（设计稿 18，行内与 14 号正文配合取 16）。
  static const double _translateIconSize = 16;

  bool _showOriginal = false;
  bool _expanded = false;

  bool get _canTranslate {
    final o = widget.original;
    return o != null && o.trim().isNotEmpty && o != widget.translated;
  }

  Widget _link(String text, VoidCallback onTap, String key, Color color,
      TextStyle style) {
    return GestureDetector(
      key: ValueKey<String>(key),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(text, style: style.copyWith(color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final translated = widget.translated;

    // 【翻译】图标（圆形「A」）：灰=默认显示译文，紫=显示原文，控制原文双语同显。
    Widget? translateIcon() {
      if (!_canTranslate) return null;
      final color =
          _showOriginal ? widget.actionColor : widget.translateIdleColor;
      return GestureDetector(
        key: const ValueKey<String>('momentText.translate'),
        onTap: () => setState(() => _showOriginal = !_showOriginal),
        behavior: HitTestBehavior.opaque,
        child: SvgPicture.asset(
          'assets/icons/moment_translate.svg',
          width: _translateIconSize,
          height: _translateIconSize,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: translated, style: style),
          maxLines: widget.collapsedMaxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final overflow = painter.didExceedMaxLines;
        final tIcon = translateIcon();

        // ① 译文主体（带 展开/收起 + 翻译 行尾链）
        late final Widget translatedBlock;
        if (!overflow) {
          translatedBlock = Text.rich(
            TextSpan(children: [
              TextSpan(text: translated),
              if (tIcon != null) ...[
                const WidgetSpan(child: SizedBox(width: 6)),
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle, child: tIcon),
              ],
            ]),
            style: style,
          );
        } else if (_expanded) {
          translatedBlock = Text.rich(
            TextSpan(children: [
              TextSpan(text: translated),
              const WidgetSpan(child: SizedBox(width: 6)),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _link('收起', () => setState(() => _expanded = false),
                    'momentText.collapse', widget.translateIdleColor, style),
              ),
              if (tIcon != null) ...[
                const WidgetSpan(child: SizedBox(width: 6)),
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle, child: tIcon),
              ],
            ]),
            style: style,
          );
        } else {
          translatedBlock = Stack(
            children: [
              Text(
                translated,
                maxLines: widget.collapsedMaxLines,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  color: widget.maskColor,
                  padding: const EdgeInsets.only(left: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _link('展开', () => setState(() => _expanded = true),
                          'momentText.expand', widget.translateIdleColor, style),
                      if (tIcon != null) ...[
                        const SizedBox(width: 6),
                        tIcon,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // ② 原文（双语同显，灰色，在译文下方）
        if (_showOriginal && _canTranslate) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              translatedBlock,
              const SizedBox(height: 4),
              Text(
                widget.original!,
                key: const ValueKey<String>('momentText.original'),
                style: style.copyWith(color: widget.translateIdleColor),
              ),
            ],
          );
        }
        return translatedBlock;
      },
    );
  }
}
