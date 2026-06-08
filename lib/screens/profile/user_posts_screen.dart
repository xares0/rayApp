import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/user_profile_route.dart';
import '../../models/post.dart';
import '../../models/user.dart';
import '../../providers/profile_provider.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/smart_avatar.dart';
import '../../widgets/smart_image.dart';

class UserPostsScreen extends ConsumerWidget {
  const UserPostsScreen({super.key, required this.userId});

  final String userId;

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}个小时前';
    return '${diff.inDays}天前';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(profilePostsProvider(userId));
    final user = AppRepository.instance.getUser(userId);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                width: 209,
                height: 132,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.85, -0.25),
                    radius: 1.15,
                    colors: [
                      Color(0xFFEBD9FF),
                      Color(0x00FFFFFF),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        '近期投稿',
                        style: TextStyle(
                          color: Color(0xFF202020),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    key: const ValueKey('userPosts.list'),
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _UserPostCard(
                        post: posts[index],
                        user: user,
                        timeLabel: _formatTime(posts[index].createdAt),
                        onTap: () =>
                            context.push('/moment_detail/${posts[index].id}'),
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

class _UserPostCard extends StatelessWidget {
  const _UserPostCard({
    required this.post,
    required this.user,
    required this.timeLabel,
    required this.onTap,
  });

  final Post post;
  final User user;
  final String timeLabel;
  final VoidCallback onTap;

  List<String> _previewSources() {
    final sources = <String>[...post.images];
    for (final image in user.portfolioImages) {
      if (sources.length >= 3) break;
      sources.add(image);
    }
    while (sources.isNotEmpty && sources.length < 3) {
      sources.add(sources.last);
    }
    return sources.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final previews = _previewSources();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => openUserProfile(context, user.id),
                  child: SmartAvatar(
                    radius: 17.5,
                    source: user.avatarUrl,
                    fallbackName: user.name,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeLabel,
                        style: const TextStyle(
                          color: Color(0xFFD0D0D0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.more_horiz,
                  color: Color(0xFFC8CDD7),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.content,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 14,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (int index = 0; index < previews.length; index++) ...[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.723),
                      child: SizedBox(
                        height: 104,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            SmartImage(
                              source: previews[index],
                              fit: BoxFit.cover,
                            ),
                            if (index == 1 && post.videoUrl != null)
                              Center(
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 18,
                                    color: Color(0xFF7F7F7F),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (index != previews.length - 1) const SizedBox(width: 7),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.favorite_border_rounded,
                  size: 18,
                  color: Color(0xFFC4C4C4),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likesCount}',
                  style: const TextStyle(
                    color: Color(0xFFC0C0C0),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 18),
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 17,
                  color: Color(0xFFC4C4C4),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.commentsCount}',
                  style: const TextStyle(
                    color: Color(0xFFC0C0C0),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
