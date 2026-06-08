import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/user_profile_route.dart';
import '../../../providers/feed_provider.dart';
import '../../../widgets/interaction_utils.dart';
import '../../../widgets/smart_avatar.dart';
import '../../../widgets/smart_image.dart';

class RecommendTab extends ConsumerWidget {
  const RecommendTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(homeFeedProvider);

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            context.push('/moment_detail/${post.id}');
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info header
                ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      openUserProfile(context, post.userId);
                    },
                    child: SmartAvatar(
                      radius: 20,
                      source: post.author?.avatarUrl,
                      fallbackName: post.author?.name,
                    ),
                  ),
                  title: Text(post.author?.name ?? '用户',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_formatTime(post.createdAt)),
                  trailing: IconButton(
                      icon: const Icon(Icons.more_horiz), onPressed: () {}),
                ),
                // Post Image
                if (post.images.isNotEmpty || post.videoUrl != null)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => showImagePreview(context,
                            post.images.isNotEmpty ? post.images.first : ''),
                        child: SmartImage(
                          source: post.images.isNotEmpty
                              ? post.images.first
                              : 'assets/images/posts/city_night.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 300,
                        ),
                      ),
                      if (post.videoUrl != null) ...[
                        Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                        const Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 48),
                      ],
                    ],
                  ),
                // Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: post.isLiked ? Colors.red : Colors.black,
                        ),
                        onPressed: () {
                          ref
                              .read(homeFeedProvider.notifier)
                              .toggleLike(post.id);
                        },
                      ),
                      Text('${post.likesCount}'),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () {},
                      ),
                      Text('${post.commentsCount}'),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.bookmark_border),
                          onPressed: () {}),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                            text: '${post.author?.name} ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: post.content),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
