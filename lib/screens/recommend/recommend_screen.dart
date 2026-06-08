import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/user_profile_route.dart';
import '../../models/post.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/interaction_utils.dart';
import '../../widgets/smart_avatar.dart';
import '../../widgets/smart_image.dart';

class RecommendScreen extends ConsumerStatefulWidget {
  const RecommendScreen({super.key});

  @override
  ConsumerState<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends ConsumerState<RecommendScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(homeFeedProvider.notifier).refresh();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    final notifier = ref.read(homeFeedProvider.notifier);
    if (!notifier.hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });
    await notifier.loadMore();
    if (!mounted) return;
    setState(() {
      _isLoadingMore = false;
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 140) {
      _loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(homeFeedProvider);
    final currentUser = ref.watch(authProvider);
    final hasMore = ref.read(homeFeedProvider.notifier).hasMore;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          '推荐',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBE3FF),
              Color(0xFFF7F7F7),
              Color(0xFFF7F7F7),
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: posts.length + ((hasMore || _isLoadingMore) ? 1 : 0),
                separatorBuilder: (context, index) {
                  if (index >= posts.length - 1) {
                    return const SizedBox(height: 8);
                  }
                  return const SizedBox(height: 16);
                },
                itemBuilder: (context, index) {
                  if (index >= posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return _buildRecommendCard(
                    context,
                    ref,
                    posts[index],
                    currentUserId: currentUser?.id,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendCard(
    BuildContext context,
    WidgetRef ref,
    Post post, {
    String? currentUserId,
  }) {
    final canFollow = currentUserId != null && currentUserId != post.userId;
    final isFollowing = canFollow &&
        AppRepository.instance.isFollowing(currentUserId, post.userId);

    return GestureDetector(
      onTap: () {
        context.push('/moment_detail/${post.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => openUserProfile(
                    context,
                    post.userId,
                    currentUserId: currentUserId,
                  ),
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
                      Text(
                        post.author?.name ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.author?.bio ?? '',
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: !canFollow
                          ? null
                          : () {
                              AppRepository.instance.setFollowing(
                                currentUserId,
                                post.userId,
                                following: !isFollowing,
                              );
                              ref.invalidate(homeFeedProvider);
                            },
                      child: Text(
                        isFollowing ? '已关注' : '+ 关注',
                        style: TextStyle(
                          color: canFollow
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFFBBBBBB),
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => context.push('/chat/${post.userId}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '交流',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${post.author?.name ?? '作者'} 的精选投稿',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.content,
                    style:
                        const TextStyle(color: Color(0xFF666666), fontSize: 13),
                  ),
                  if (post.images.isNotEmpty || post.videoUrl != null) ...[
                    const SizedBox(height: 12),
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
                              height: 140,
                              width: double.infinity,
                            ),
                          ),
                          if (post.videoUrl != null) ...[
                            Container(
                              height: 140,
                              width: double.infinity,
                              color: Colors.black.withValues(alpha: 0.2),
                            ),
                            const Icon(Icons.play_circle_fill,
                                color: Colors.white, size: 40),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentsCount}',
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(post.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
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
