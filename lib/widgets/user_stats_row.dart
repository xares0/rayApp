import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/user_format.dart';

/// 用户信息 stats 行（第四次迭代「用户信息字段显示」）。
///
/// 统一在首页列表、个人主页等处展示用户基础信息。每一项数据为 null/空时
/// **不显示**（接口未返回不占位）。各屏按需传入字段，不需要的传 null。
///
/// 展示顺序：在线状态 · 性别+年龄 · 身高 · 体重 · 国籍 · ID
class UserStatsRow extends StatelessWidget {
  const UserStatsRow({
    super.key,
    this.isOnline,
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    this.nationality,
    this.displayId,
    this.textStyle = const TextStyle(fontSize: 11, color: Color(0xFF666666)),
    this.iconSize = 12,
    this.spacing = 6,
    this.runSpacing = 4,
  });

  final bool? isOnline;
  final String? gender; // 'male' / 'female'
  final int? age;
  final int? heightCm;
  final int? weightKg;
  final String? nationality;
  final String? displayId;

  final TextStyle textStyle;
  final double iconSize;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (isOnline == true) {
      items.add(_OnlineDot(textStyle: textStyle));
    }

    if (nationality != null && nationality!.trim().isNotEmpty) {
      final flag = nationalityFlag(nationality);
      items.add(_StatsCapsule(
        backgroundColor: const Color(0xFFFFECEF),
        child: Text(
          flag == null ? nationality! : '$flag ${nationality!}',
          style: textStyle.copyWith(fontSize: 10),
        ),
      ));
    }

    if (age != null) { // only check age since gender is hidden
      // final isFemale = gender == 'female';
      items.add(_StatsCapsule(
        backgroundColor: const Color(0xFFF2F2F7), // Neutral color
        child: _GenderAge(gender: gender, age: age, textStyle: textStyle.copyWith(fontSize: 10), iconSize: iconSize),
      ));
    }

    final h = formatHeight(heightCm);
    if (h != null) {
      items.add(_StatsCapsule(
        backgroundColor: const Color(0xFFF2F2F7),
        child: Text(h, style: textStyle.copyWith(fontSize: 10)),
      ));
    }

    final w = formatWeight(weightKg);
    if (w != null) {
      items.add(_StatsCapsule(
        backgroundColor: const Color(0xFFF2F2F7),
        child: Text(w, style: textStyle.copyWith(fontSize: 10)),
      ));
    }

    if (displayId != null && displayId!.trim().isNotEmpty) {
      items.add(_StatsCapsule(
        backgroundColor: const Color(0xFFF2F2F7),
        onTap: () {
          Clipboard.setData(ClipboardData(text: displayId!));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID已复制到剪贴板'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ID:${displayId!}', style: textStyle.copyWith(fontSize: 10)),
            const SizedBox(width: 4),
            Icon(
              Icons.copy_rounded,
              size: iconSize,
              color: const Color(0xFF666666),
            ),
          ],
        ),
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: items,
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot({required this.textStyle});

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF44D7B6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text('在线', style: textStyle.copyWith(color: const Color(0xFF44D7B6))),
      ],
    );
  }
}

class _GenderAge extends StatelessWidget {
  const _GenderAge({
    required this.gender,
    required this.age,
    required this.textStyle,
    required this.iconSize,
  });

  final String? gender;
  final int? age;
  final TextStyle textStyle;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    // final isFemale = gender == 'female';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // if (gender != null && gender!.isNotEmpty) ...[
        //   Icon(
        //     isFemale ? Icons.female : Icons.male,
        //     size: iconSize,
        //     color: isFemale ? const Color(0xFFFF6B9D) : const Color(0xFF5B9BFF),
        //   ),
        //   const SizedBox(width: 2),
        // ],
        if (age != null) Text('$age岁', style: textStyle),
      ],
    );
  }
}

class _StatsCapsule extends StatelessWidget {
  const _StatsCapsule({
    required this.backgroundColor,
    required this.child,
    this.onTap,
  });

  final Color backgroundColor;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

