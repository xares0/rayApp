import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/smart_avatar.dart';

/// 我的好友（互关用户）。列表显示头像、昵称、拍摄心得、聊天 ICON。
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  static const String _messageIconAsset =
      'assets/images/friends/icon_friend_message.svg';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final List<User> friends =
        user == null ? const [] : AppRepository.instance.getFriends(user.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: 300,
            child: _FriendsTopBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _FriendsNavBar(),
                Expanded(
                  child: friends.isEmpty
                      ? const Center(
                          child: Text(
                            '还没有好友',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            return _FriendCard(
                              key: ValueKey<String>('friends.item.$index'),
                              itemIndex: index,
                              friend: friend,
                              messageIconAsset: _messageIconAsset,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsTopBackground extends StatelessWidget {
  const _FriendsTopBackground();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _FriendsTopBackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class _FriendsTopBackgroundPainter extends CustomPainter {
  const _FriendsTopBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF7C9),
          Color(0xFFFCFCFC),
          Color(0xFFF7F7F7),
        ],
        stops: [0, 0.58, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, basePaint);

    final yellow = Paint()
      ..color = const Color(0xFFFFF1B3).withValues(alpha: 0.86)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 46);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(76, -8),
        width: 250,
        height: 180,
      ),
      yellow,
    );

    final pink = Paint()
      ..color = const Color(0xFFFAB3FF).withValues(alpha: 0.74)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 56);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width - 22, 4),
        width: 230,
        height: 160,
      ),
      pink,
    );

    final veil = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          const Color(0xFFF7F7F7).withValues(alpha: 0.92),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, veil);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FriendsNavBar extends StatelessWidget {
  const _FriendsNavBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 48,
              height: 55,
              child: Stack(
                children: [
                  Positioned(
                    key: ValueKey<String>('friends.backFrame'),
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
              key: const ValueKey<String>('friends.titleFrame'),
              color: Colors.transparent,
              child: const Center(
                child: Text(
                  '我的好友',
                  key: ValueKey<String>('friends.title'),
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
        ],
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({
    super.key,
    required this.itemIndex,
    required this.friend,
    required this.messageIconAsset,
  });

  final int itemIndex;
  final User friend;
  final String messageIconAsset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 14,
        right: 14,
        bottom: 8,
      ),
      child: SizedBox(
        key: ValueKey<String>('friends.card.$itemIndex'),
        height: 62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 10,
                top: 10,
                width: 42,
                height: 42,
                child: SmartAvatar(
                  key: ValueKey<String>('friends.avatar.$itemIndex'),
                  radius: 21,
                  source: friend.avatarUrl,
                  fallbackName: friend.name,
                ),
              ),
              Positioned(
                left: 61,
                top: 11,
                right: 68,
                child: Text(
                  friend.name,
                  key: ValueKey<String>('friends.name.$itemIndex'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                    height: 20 / 14,
                  ),
                ),
              ),
              Positioned(
                left: 61,
                top: 38,
                right: 68,
                child: Text(
                  friend.bio.isEmpty ? '社牛属性拉满！刷到就是缘分' : friend.bio,
                  key: ValueKey<String>('friends.bio.$itemIndex'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                    height: 14 / 10,
                  ),
                ),
              ),
              Positioned(
                right: 15,
                top: 18,
                width: 42,
                height: 27,
                child: GestureDetector(
                  key: ValueKey<String>('friends.messageButton.$itemIndex'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.push('/chat/${friend.id}'),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCA0FF),
                      borderRadius: BorderRadius.circular(13.5),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        messageIconAsset,
                        key: ValueKey<String>('friends.messageIcon.$itemIndex'),
                        width: 22,
                        height: 22,
                      ),
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
