import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../core/router/user_profile_route.dart';
import '../../../widgets/smart_avatar.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _pinnedUsersProvider = Provider.autoDispose<List<User>>((ref) {
  final currentUser = ref.watch(authProvider);
  if (currentUser == null) return [];
  return AppRepository.instance.getPinnedUsers(currentUser.id);
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class MyPinnedScreen extends ConsumerStatefulWidget {
  const MyPinnedScreen({super.key});

  @override
  ConsumerState<MyPinnedScreen> createState() => _MyPinnedScreenState();
}

class _MyPinnedScreenState extends ConsumerState<MyPinnedScreen> {
  @override
  Widget build(BuildContext context) {
    final pinnedUsers = ref.watch(_pinnedUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _MyPinnedNavBar(),
            Expanded(
              child: pinnedUsers.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 21),
                      itemCount: pinnedUsers.length,
                      itemBuilder: (context, index) {
                        final user = pinnedUsers[index];
                        return _PinnedUserItem(
                          key: ValueKey<String>('myPinned.item.$index'),
                          itemIndex: index,
                          user: user,
                          onTap: () => openUserProfile(context, user.id),
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

class _MyPinnedNavBar extends StatelessWidget {
  const _MyPinnedNavBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 48,
              height: 44,
              child: Stack(
                children: [
                  Positioned(
                    key: ValueKey<String>('myPinned.backFrame'),
                    left: 14,
                    top: 18,
                    width: 20,
                    height: 20,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Color(0xFF333333),
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
              key: const ValueKey<String>('myPinned.titleFrame'),
              color: Colors.transparent,
              child: const Center(
                child: Text(
                  '我的置顶',
                  key: ValueKey<String>('myPinned.title'),
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

// ---------------------------------------------------------------------------
// 置顶用户列表项
// ---------------------------------------------------------------------------

class _PinnedUserItem extends StatelessWidget {
  const _PinnedUserItem({
    super.key,
    required this.itemIndex,
    required this.user,
    required this.onTap,
  });

  final int itemIndex;
  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.only(left: 11, right: 14),
          child: Stack(
            children: [
              SmartAvatar(
                key: ValueKey<String>('myPinned.avatar.$itemIndex'),
                radius: 21,
                source: user.avatarUrl,
                fallbackName: user.name,
              ),
              Positioned(
                left: 51,
                top: 3,
                right: 0,
                child: Text(
                  user.remarkName ?? user.name,
                  key: ValueKey<String>('myPinned.name.$itemIndex'),
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
              Positioned(
                left: 51,
                top: 26,
                right: 0,
                child: Text(
                  user.bio,
                  key: ValueKey<String>('myPinned.bio.$itemIndex'),
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                    height: 14 / 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 48,
                right: 0.5,
                top: 57,
                child: ColoredBox(
                  key: ValueKey<String>('myPinned.divider.$itemIndex'),
                  color: const Color(0xFFE8E8E8),
                  child: const SizedBox(height: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 空状态
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '暂无置顶',
        style: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 14,
          color: Color(0xFF999999),
        ),
      ),
    );
  }
}
