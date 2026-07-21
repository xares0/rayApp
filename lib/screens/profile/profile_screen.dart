import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/gift_provider.dart';
import '../../providers/profile_provider.dart';
import '../../repositories/app_repository.dart';
import '../../utils/user_format.dart';
import '../../widgets/smart_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('未登录')),
      );
    }

    // postsCount 预留待确认：我的投稿入口 badge
    ref.watch(profilePostsProvider(user.id));
    final followingCount = AppRepository.instance.getFollowingCount(user.id);
    final followersCount = AppRepository.instance.getFollowerCount(user.id);

    final friendsCount = AppRepository.instance.getFriendCount(user.id);
    final visitorsCount = AppRepository.instance.getVisitorCount(user.id);
    final giftCount = ref.watch(giftBalanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 7),
              // ── 顶部导航栏 ──
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 22),
                child: Row(
                  children: [
                    GestureDetector(
                      key: const ValueKey<String>('profile.backButton'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go('/style'),
                      child: const SizedBox(
                        width: 24,
                        height: 32,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // ── 资料卡区域 ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头像 57x57 圆角 48
                    SmartAvatar(
                      key: const ValueKey<String>('profile.avatar'),
                      radius: 28.5, // diameter=57
                      source: user.avatarUrl,
                      fallbackName: user.name,
                    ),
                    const SizedBox(width: 10),
                    // 昵称 + 编辑按钮 + 性别年龄 + bio
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Transform.translate(
                                  offset: const Offset(0, 7),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user.name,
                                          key: const ValueKey<String>(
                                            'profile.name',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'PingFang SC',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF333333),
                                            height: 22 / 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        key: const ValueKey<String>(
                                          'profile.editButton',
                                        ),
                                        onTap: () =>
                                            context.push('/edit_profile'),
                                        child: const Icon(
                                          Icons.edit_outlined,
                                          size: 13,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 签到有礼按钮
                              GestureDetector(
                                onTap: () => context.push('/task_center'),
                                child: Transform.translate(
                                  offset: const Offset(10, 15),
                                  child: Container(
                                    key: const ValueKey<String>(
                                      'profile.checkinButton',
                                    ),
                                    width: 85,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF7DDFFF),
                                          Color(0xFFDCA0FF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(33),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '签到有礼',
                                          style: TextStyle(
                                            fontFamily: 'PingFang SC',
                                            fontSize: 10,
                                            color: Colors.white,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 性别 + 年龄 badge 区域
                          Row(
                            children: [
                              Container(
                                key: const ValueKey<String>(
                                  'profile.ageBadge',
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x33D6A4FF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 性别图标预留（根据 user.gender）
                                    // Icon(
                                    //   (user.gender == 'female')
                                    //       ? Icons.female
                                    //       : Icons.male,
                                    //   key: const ValueKey<String>(
                                    //     'profile.genderIcon',
                                    //   ),
                                    //   size: 10,
                                    //   color: const Color(0xFF7C67D0),
                                    // ),
                                    // const SizedBox(width: 2),
                                    Text(
                                      '${ageFromBirthday(user.birthday)}',
                                      key: const ValueKey<String>(
                                        'profile.ageText',
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'PingFang SC',
                                        fontSize: 10,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Bio
                          Text(
                            user.bio.isEmpty ? '摄影心得...' : user.bio,
                            key: const ValueKey<String>('profile.bio'),
                            style: const TextStyle(
                              fontFamily: 'PingFang SC',
                              fontSize: 10,
                              color: Color(0xFF666666),
                              height: 14 / 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              // ── 统计行：粉丝 / 好友 / 关注 / 访客 ──
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      key: const ValueKey<String>('profile.stat.followers'),
                      count: '$followersCount',
                      label: '粉丝',
                      onTap: () => context.push('/profile_followers'),
                    ),
                    _StatItem(
                      key: const ValueKey<String>('profile.stat.friends'),
                      count: '$friendsCount',
                      label: '好友',
                      onTap: () => context.push('/friends'),
                    ),
                    _StatItem(
                      key: const ValueKey<String>('profile.stat.following'),
                      count: '$followingCount',
                      label: '关注',
                      onTap: () => context.push('/profile_following'),
                    ),
                    _StatItem(
                      key: const ValueKey<String>('profile.stat.visitors'),
                      count: '$visitorsCount',
                      label: '访客',
                      onTap: () => context.push('/visitors'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // ── Banner（>1 张自动轮播，=1 张不轮播；当前仅占位不跳转）──
              const _ProfileBanner(),
              const SizedBox(height: 14),
              // ── 功能列表白卡 ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  width: double.infinity,
                  height: 293,
                  key: const ValueKey<String>('profile.menuCard'),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Column(
                    children: [
                      _MenuRow(
                        key: const ValueKey<String>('profile.menu.post'),
                        icon: Icons.upload_file_outlined, // 预留待确认：我的投稿 icon
                        label: '我的投稿',
                        onTap: () => context.push('/profile_moments'),
                      ),
                      _MenuRow(
                        key: const ValueKey<String>('profile.menu.gift'),
                        icon: Icons.card_giftcard_outlined,
                        label: '我的礼物',
                        trailing:
                            giftCount > 0 ? _BadgeText('$giftCount') : null,
                        onTap: () {},
                      ),
                      _MenuRow(
                        key: const ValueKey<String>('profile.menu.support'),
                        icon: Icons.headset_mic_outlined,
                        label: '客服中心',
                        onTap: () {
                          AppRepository.instance
                              .ensureOfficialSupportConversation(user.id);
                          ref.invalidate(chatListProvider);
                          context.push(
                              '/chat/${AppRepository.officialSupportUserId}');
                        },
                      ),
                      _MenuRow(
                        key: const ValueKey<String>('profile.menu.pinned'),
                        icon: Icons
                            .vertical_align_top_outlined, // 预留待确认：我的置顶 icon
                        label: '我的置顶',
                        onTap: () => context.push('/my_pinned'),
                      ),
                      _MenuRow(
                        key: const ValueKey<String>('profile.menu.settings'),
                        icon: Icons.settings_outlined,
                        label: '设置',
                        onTap: () => context.push('/settings'),
                      ),
                      _MenuRow(
                        key: const ValueKey<String>('profile.menu.calls'),
                        icon: Icons.call_outlined, // 预留待确认：通话记录 icon
                        label: '通话记录',
                        onTap: () => context.push('/call_records'),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner();

  static const String _bannerAsset = 'assets/images/profile/profile_banner.png';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        child: SizedBox(
          key: const ValueKey<String>('profile.banner'),
          height: 123,
          child: Image.asset(
            _bannerAsset,
            width: double.infinity,
            height: 123,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// ── 统计项 ──
class _StatItem extends StatelessWidget {
  final Key? frameKey;
  final String count;
  final String label;
  final VoidCallback onTap;

  const _StatItem({
    Key? key,
    required this.count,
    required this.label,
    required this.onTap,
  })  : frameKey = key,
        super();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: frameKey,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 32),
        child: SizedBox(
          height: 46,
          child: Column(
            children: [
              SizedBox(
                height: 20,
                child: Center(
                  child: Text(
                    count,
                    style: const TextStyle(
                      fontFamily: 'PingFang SC',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                      height: 20 / 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 22,
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'PingFang SC',
                      fontSize: 12,
                      color: Color(0xFF999999),
                      height: 22 / 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 功能列表行 ──
class _MenuRow extends StatelessWidget {
  final Key? frameKey;
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;

  const _MenuRow({
    Key? key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.isLast = false,
  })  : frameKey = key,
        super();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: frameKey,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: isLast ? 24 : 49,
        child: Stack(
          children: [
            Positioned(
              left: 15,
              right: 15,
              top: 0,
              height: 24,
              child: Row(
                children: [
                  Icon(icon, size: 24, color: const Color(0xFF7C67D0)),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'PingFang SC',
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 22 / 14,
                    ),
                  ),
                  const Spacer(),
                  if (trailing != null) ...[
                    trailing!,
                    const SizedBox(width: 4),
                  ],
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Color(0xFF333333),
                  ),
                ],
              ),
            ),
            if (!isLast)
              const Positioned(
                left: 0,
                right: 0,
                top: 36,
                height: 1,
                child: ColoredBox(color: Color(0xFFF0F0F0)),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Badge 数字 ──
class _BadgeText extends StatelessWidget {
  final String text;

  const _BadgeText(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.card_giftcard_outlined, // 预留待确认：礼物 badge 图标
          size: 16,
          color: Color(0xFF7C67D0),
        ),
        const SizedBox(width: 2),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'PingFang SC',
            fontSize: 14,
            color: Color(0xFF333333),
            height: 22 / 14,
          ),
        ),
      ],
    );
  }
}
