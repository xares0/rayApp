import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/user_profile_route.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/feed_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/interaction_utils.dart';
import '../../../widgets/smart_avatar.dart';
import '../../../widgets/smart_image.dart';
import '../../../models/post.dart';

class MyPostDetailScreen extends ConsumerWidget {
  const MyPostDetailScreen({super.key, required this.postId});

  final String postId;

  Future<void> _deletePost(BuildContext context, WidgetRef ref) async {
    final confirmed = await showFigmaDeletePostDialog(context);
    if (!confirmed) return;

    final currentUser = ref.read(authProvider);
    AppRepository.instance.removePost(postId);
    ref.invalidate(homeFeedProvider);
    ref.invalidate(momentsFeedProvider);
    if (currentUser != null) {
      ref.invalidate(profilePostsProvider(currentUser.id));
    }

    if (!context.mounted) return;
    showAppToast(context, '投稿已删除');
    context.pop();
  }

  Future<void> _openCommentSheet(
    BuildContext context,
    WidgetRef ref,
    String targetPostId,
  ) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      showAppToast(context, '请先登录后评论');
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return _CommentInputSheet(
          onSend: (content) {
            AppRepository.instance.addComment(
              postId: targetPostId,
              userId: currentUser.id,
              content: content,
            );
            ref.invalidate(homeFeedProvider);
            ref.invalidate(momentsFeedProvider);
            ref.invalidate(profilePostsProvider(currentUser.id));
            Navigator.of(sheetContext).pop();
            showAppToast(context, '评论已发送');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    ref.watch(momentsFeedProvider);
    final currentPost = AppRepository.instance.getPostById(postId);

    if (currentPost == null) {
      return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            '投稿详情',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            '该投稿已不存在',
            style: TextStyle(color: Color(0xFF999999), fontSize: 14),
          ),
        ),
      );
    }

    final hydratedPost = currentPost.copyWith(
      author: AppRepository.instance.getUser(currentPost.userId),
    );
    final comments = AppRepository.instance.getCommentsForPost(postId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '投稿详情',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _deletePost(context, ref),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFB29AF9),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => openUserProfile(context, hydratedPost.userId),
                    child: SmartAvatar(
                      radius: 18,
                      source: hydratedPost.author?.avatarUrl,
                      fallbackName: hydratedPost.author?.name,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hydratedPost.author?.name ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(hydratedPost.createdAt),
                          style: const TextStyle(
                            color: Color(0x80111111),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                hydratedPost.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
            ),
            if (hydratedPost.videoUrl != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GestureDetector(
                  // Figma v4 `37:624`：帖子里的视频点击进**全屏视频查看**（非基础播放器）
                  onTap: () {
                    final videoPosts = AppRepository.instance.posts
                        .where((p) => (p.videoUrl ?? '').isNotEmpty)
                        .toList();
                    final idx = videoPosts
                        .indexWhere((p) => p.id == hydratedPost.id);
                    // 走 go_router 声明式（与裸 Navigator.push 混用会崩溃）
                    context.push('/video_feed', extra: <String, dynamic>{
                      'posts': videoPosts.isEmpty
                          ? <Post>[hydratedPost]
                          : videoPosts,
                      'initialIndex': idx < 0 ? 0 : idx,
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (hydratedPost.images.isNotEmpty)
                            SmartImage(source: hydratedPost.images.first)
                          else
                            const SmartImage(
                              source: 'assets/images/posts/city_night.jpg',
                            ),
                          Container(
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                          const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (hydratedPost.images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: hydratedPost.images.take(3).map<Widget>((url) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => showImagePreview(context, url),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: SmartImage(source: url),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => ref
                        .read(homeFeedProvider.notifier)
                        .toggleLike(hydratedPost.id),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Icon(
                          hydratedPost.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 22,
                          color: hydratedPost.isLiked
                              ? Colors.red
                              : const Color(0xFF666666),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${hydratedPost.likesCount}',
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () =>
                        _openCommentSheet(context, ref, hydratedPost.id),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 22,
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${comments.length}',
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '共${comments.length}条评论',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final author = AppRepository.instance.getUser(comment.userId);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => openUserProfile(context, author.id),
                        child: SmartAvatar(
                          radius: 18,
                          source: author.avatarUrl,
                          fallbackName: author.name,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTime(comment.createdAt),
                              style: const TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              comment.content,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(
              height: currentUser == null ? 24 : 32,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}

class _CommentInputSheet extends StatefulWidget {
  const _CommentInputSheet({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<_CommentInputSheet> createState() => _CommentInputSheetState();
}

class _CommentInputSheetState extends State<_CommentInputSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get _canSend => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!_canSend) return;
                  widget.onSend(_controller.text.trim());
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '写下你的评论...',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed:
                _canSend ? () => widget.onSend(_controller.text.trim()) : null,
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }
}
