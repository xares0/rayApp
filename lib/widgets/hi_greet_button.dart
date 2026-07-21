import 'package:flutter/material.dart';

/// 「Hi」搭讪按钮 —— 拍友列表 / 动态卡片 / 视频叠层共用。
///
/// Figma v4：34×34 圆形，蓝→紫渐变，白色「Hi」字。
/// 招呼后（[contacted] = true）变浅紫底 + 聊天气泡图标。
class HiGreetButton extends StatelessWidget {
  const HiGreetButton({
    super.key,
    this.contacted = false,
    this.size = 34,
  });

  final bool contacted;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        // Figma v4：招呼前后均为蓝→紫渐变；招呼后把「Hi」换成白色聊天图标。
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF7DDFFF),
            Color(0xFFDCA0FF),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: contacted
          ? Icon(
              Icons.forum_rounded,
              size: size * 18 / 34,
              color: Colors.white,
            )
          : Text(
              'Hi',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PingFang SC',
                fontSize: size * 14 / 34,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
