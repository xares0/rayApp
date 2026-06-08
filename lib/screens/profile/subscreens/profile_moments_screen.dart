import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/user_profile_route.dart';
import '../../../models/post.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/feed_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/interaction_utils.dart';
import '../../../widgets/smart_avatar.dart';
import '../../../widgets/smart_image.dart';

class ProfileMomentsScreen extends ConsumerStatefulWidget {
  const ProfileMomentsScreen({super.key});

  @override
  ConsumerState<ProfileMomentsScreen> createState() =>
      _ProfileMomentsScreenState();
}

class _ProfileMomentsScreenState extends ConsumerState<ProfileMomentsScreen> {
  Future<void> _deletePost(String postId) async {
    final confirmed = await showFigmaDeletePostDialog(context);
    if (!confirmed) return;

    AppRepository.instance.removePost(postId);
    final user = ref.read(authProvider);
    if (user != null) {
      ref.invalidate(profilePostsProvider(user.id));
    }
    ref.invalidate(homeFeedProvider);
    ref.invalidate(momentsFeedProvider);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final List<Post> posts = currentUser == null
        ? <Post>[]
        : ref.watch(profilePostsProvider(currentUser.id)).map((p) {
            return p.copyWith(author: AppRepository.instance.getUser(p.userId));
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          const Positioned(
            top: -18,
            right: -34,
            child: _MomentsHeaderGlow(),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
                  child: SizedBox(
                    height: 32,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Color(0xFF202020),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              '投稿',
                              style: TextStyle(
                                color: Color(0xFF202020),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: posts.isEmpty
                      ? const Center(
                          child: Text(
                            '还没有发布投稿',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                          itemCount: posts.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return GestureDetector(
                              onTap: () =>
                                  context.push('/my_post_detail/${post.id}'),
                              behavior: HitTestBehavior.opaque,
                              child: _MomentCard(
                                post: post,
                                onDelete: () => _deletePost(post.id),
                              ),
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

class _MomentsHeaderGlow extends StatelessWidget {
  const _MomentsHeaderGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 209,
      height: 132,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.35,
          colors: [
            Color(0x40DCCEFF),
            Color(0x14F1EBFF),
            Color(0x00FFFFFF),
          ],
          stops: [0, 0.58, 1],
        ),
      ),
    );
  }
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({
    required this.post,
    required this.onDelete,
  });

  final Post post;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final images = post.images.take(3).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 13, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
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
                onTap: () => openUserProfile(context, post.userId),
                child: SmartAvatar(
                  radius: 17.5,
                  source: post.author?.avatarUrl,
                  fallbackName: post.author?.name,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author?.name ?? '',
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _formatTime(post.createdAt),
                        style: const TextStyle(
                          color: Color(0xFFC0C0C0),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 24,
                  height: 24,
                ),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 21,
                  color: Color(0xFFB29AF9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post.content,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (images.isNotEmpty || post.videoUrl != null) ...[
            const SizedBox(height: 12),
            if (images.length <= 1)
              SizedBox(
                width: 185,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SmartImage(
                        source: images.isNotEmpty
                            ? images.first
                            : 'assets/images/posts/city_night.jpg',
                        fit: BoxFit.cover,
                      ),
                      if (post.videoUrl != null)
                        Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            size: 34,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              Row(
                children: [
                  for (int index = 0; index < images.length; index++) ...[
                    if (index != 0) const SizedBox(width: 7),
                    Expanded(
                      child: SizedBox(
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              SmartImage(
                                source: images[index],
                                fit: BoxFit.cover,
                              ),
                              if (index == 0 && post.videoUrl != null)
                                Center(
                                  child: Icon(
                                    Icons.play_circle_fill_rounded,
                                    size: 34,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ],
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
