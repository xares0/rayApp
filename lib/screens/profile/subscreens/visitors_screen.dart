import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/user_profile_route.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/smart_avatar.dart';

/// 「我的-访客」：显示谁来看过我的主页
class VisitorsScreen extends ConsumerWidget {
  const VisitorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final visitors = currentUser == null
        ? <({User user, DateTime visitedAt})>[]
        : AppRepository.instance.getVisitors(currentUser.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _VisitorsNavBar(),
            Expanded(
              child: visitors.isEmpty
                  ? const Center(
                      child: Text(
                        '还没有访客记录',
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 21),
                      itemCount: visitors.length,
                      itemBuilder: (context, index) {
                        final item = visitors[index];
                        final isLast = index == visitors.length - 1;
                        return _VisitorListItem(
                          key: ValueKey<String>('visitors.item.$index'),
                          itemIndex: index,
                          visitor: item.user,
                          visitedAt: item.visitedAt,
                          showDivider: !isLast,
                          onTap: () => openUserProfile(
                            context,
                            item.user.id,
                            currentUserId: currentUser?.id,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitorsNavBar extends StatelessWidget {
  const _VisitorsNavBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 48,
              height: 44,
              child: Stack(
                children: [
                  Positioned(
                    key: ValueKey<String>('visitors.backFrame'),
                    left: 14,
                    top: 18,
                    width: 20,
                    height: 20,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF333333),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 128,
            top: 14,
            width: 120,
            height: 28,
            child: Container(
              key: const ValueKey<String>('visitors.titleFrame'),
              color: Colors.transparent,
              child: const Center(
                child: Text(
                  '我的访客',
                  key: ValueKey<String>('visitors.title'),
                  style: TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                    height: 28 / 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _VisitorListItem extends StatelessWidget {
  const _VisitorListItem({
    super.key,
    required this.itemIndex,
    required this.visitor,
    required this.visitedAt,
    required this.showDivider,
    required this.onTap,
  });

  final int itemIndex;
  final User visitor;
  final DateTime visitedAt;
  final bool showDivider;
  final VoidCallback onTap;

  /// 根据 birthday 计算年龄，birthday 格式 'yyyy-MM-dd'
  int? _calcAge(String? birthday) {
    if (birthday == null || birthday.isEmpty) return null;
    try {
      final parts = birthday.split('-');
      if (parts.length != 3) return null;
      final born = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final today = DateTime.now();
      int age = today.year - born.year;
      if (today.month < born.month ||
          (today.month == born.month && today.day < born.day)) {
        age -= 1;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  String _formatVisitTime(DateTime visitedAt) {
    final now = DateTime.now();
    final diff = now.difference(visitedAt);
    if (diff.inSeconds < 60) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }

  @override
  Widget build(BuildContext context) {
    final age = _calcAge(visitor.birthday);
    final isMale = visitor.gender == 'male';
    final timeText = _formatVisitTime(visitedAt);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.only(left: 11, right: 14),
          child: Stack(
            children: [
              SmartAvatar(
                key: ValueKey<String>('visitors.avatar.$itemIndex'),
                radius: 21,
                source: visitor.avatarUrl,
                fallbackName: visitor.name,
              ),
              Positioned(
                left: 51,
                top: -3,
                right: 0,
                child: Text(
                  visitor.name,
                  key: ValueKey<String>('visitors.name.$itemIndex'),
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                    height: 20 / 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (age != null)
                Positioned(
                  left: 51,
                  top: 18,
                  child: _GenderAgeBadge(
                    key: ValueKey<String>('visitors.badge.$itemIndex'),
                    itemIndex: itemIndex,
                    isMale: isMale,
                    age: age,
                  ),
                ),
              Positioned(
                left: 51,
                top: 34,
                child: Text(
                  timeText,
                  key: ValueKey<String>('visitors.time.$itemIndex'),
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                    height: 14 / 10,
                  ),
                ),
              ),
              if (showDivider)
                const Positioned(
                  left: 48,
                  right: 0.5,
                  top: 57,
                  child: ColoredBox(
                    key: ValueKey<String>('visitors.divider'),
                    color: Color(0xFFE8E8E8),
                    child: SizedBox(height: 0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 性别+年龄 badge：Figma #rgba(214,164,255,0.2) bg，H=14，W=36，radius=999
class _GenderAgeBadge extends StatelessWidget {
  const _GenderAgeBadge({
    super.key,
    required this.itemIndex,
    required this.isMale,
    required this.age,
  });

  final int itemIndex;
  final bool isMale;
  final int age;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0x33D6A4FF), // rgba(214,164,255,0.2)
        borderRadius: BorderRadius.circular(999),
      ),
      child: Stack(
        children: [
          // 性别图标 — 预留待确认：Material icon 近似替代 Figma 自定义男/女图标
          Positioned(
            left: 6,
            top: 2,
            width: 10,
            height: 10,
            child: Icon(
              key: ValueKey<String>('visitors.badgeIcon.$itemIndex'),
              isMale ? Icons.male : Icons.female,
              size: 10,
              color: isMale ? const Color(0xFF6BA3E0) : const Color(0xFFE06B8A),
            ),
          ),
          Positioned(
            left: 18,
            top: 0,
            width: 16,
            height: 14,
            child: Text(
              '$age',
              key: ValueKey<String>('visitors.badgeAge.$itemIndex'),
              style: const TextStyle(
                fontFamily: 'PingFang SC',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF333333),
                height: 14 / 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
