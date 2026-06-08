import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/user_profile_route.dart';
import '../../../providers/feed_provider.dart';
import '../../../widgets/interaction_utils.dart';
import '../../../widgets/smart_avatar.dart';
import '../../../widgets/smart_image.dart';

class MomentsScreen extends ConsumerWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(momentsFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              context.push('/messages');
            },
          )
        ],
      ),
      body: ListView.separated(
        itemCount: posts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final post = posts[index];
          return InkWell(
            onTap: () => context.push('/moment_detail/${post.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      openUserProfile(context, post.userId);
                    },
                    child: SmartAvatar(
                      radius: 20,
                      source: post.author?.avatarUrl,
                      fallbackName: post.author?.name,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(post.author?.name ?? '用户',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                              _formatTime(post.createdAt),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(post.content,
                            style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 12),
                        if (post.images.isNotEmpty || post.videoUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => showImagePreview(
                                      context,
                                      post.images.isNotEmpty
                                          ? post.images.first
                                          : ''),
                                  child: SmartImage(
                                    source: post.images.isNotEmpty
                                        ? post.images.first
                                        : 'assets/images/posts/city_night.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 180,
                                  ),
                                ),
                                if (post.videoUrl != null) ...[
                                  Container(
                                    width: double.infinity,
                                    height: 180,
                                    color: Colors.black.withValues(alpha: 0.2),
                                  ),
                                  const Icon(Icons.play_circle_fill,
                                      color: Colors.white, size: 40),
                                ],
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.share, size: 20, color: Colors.grey),
                                SizedBox(width: 4),
                                Text('分享',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline,
                                    size: 20, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('${post.commentsCount}',
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                    post.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 20,
                                    color: post.isLiked
                                        ? Colors.red
                                        : Colors.grey),
                                const SizedBox(width: 4),
                                Text('${post.likesCount}',
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}
