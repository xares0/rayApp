import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/user_profile_route.dart';
import '../../models/comment.dart';
import '../../models/post.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blocked_users_provider.dart';
import '../../providers/feed_provider.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/interaction_utils.dart';
import '../../widgets/smart_avatar.dart';
import '../../widgets/smart_image.dart';
import 'video_player_screen.dart';

// 每条一级评论最多折叠展示几条回复
const int _kCollapseThreshold = 3;

class MomentDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const MomentDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<MomentDetailScreen> createState() => _MomentDetailScreenState();
}

class _MomentDetailScreenState extends ConsumerState<MomentDetailScreen> {
  // 已展开全部回复的一级评论 id 集合
  final Set<String> _expandedComments = {};

  void _refreshComments() {
    setState(() {});
  }

  Future<void> _handleMoreAction(
      _DetailMoreAction action, String userId) async {
    if (action == _DetailMoreAction.report) {
      context.push('/report?targetType=post&targetId=${widget.postId}');
      return;
    }

    final confirmed = await showBlockConfirmDialog(context);
    if (!mounted) return;
    if (!confirmed) return;
    ref.read(blockedUsersProvider.notifier).blockUser(userId);
    showAppToast(context, '拉黑成功');
  }

  /// 打开评论输入框（可复用于新评论和回复）
  Future<void> _openCommentSheet(
    String postId, {
    String? parentId,
    String? replyToUserId,
    String? replyToUserName,
  }) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      showAppToast(context, '请先登录后评论');
      return;
    }

    final hintText =
        replyToUserName != null ? '回复 $replyToUserName...' : '写下你的评论...';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return _CommentInputSheet(
          hintText: hintText,
          onSend: (content) {
            AppRepository.instance.addComment(
              postId: postId,
              userId: currentUser.id,
              content: content,
              parentId: parentId,
              replyToUserId: replyToUserId,
              replyToUserName: replyToUserName,
            );
            ref.invalidate(homeFeedProvider);
            ref.invalidate(momentsFeedProvider);
            Navigator.of(sheetContext).pop();
            showAppToast(context, parentId != null ? '回复已发送' : '评论已发送');
            _refreshComments();
          },
        );
      },
    );
  }

  /// 长按评论弹操作菜单
  Future<void> _showCommentActions({
    required Comment comment,
    required bool isOwnComment,
    required String parentCommentId,
    required String replyToUserId,
    required String replyToUserName,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              if (!isOwnComment)
                ListTile(
                  leading: const Icon(Icons.reply, color: Colors.black87),
                  title: const Text('回复'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _openCommentSheet(
                      widget.postId,
                      parentId: parentCommentId,
                      replyToUserId: replyToUserId,
                      replyToUserName: replyToUserName,
                    );
                  },
                ),
              if (isOwnComment)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('删除', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final confirmed = await _showDeleteConfirm();
                    if (!mounted) return;
                    if (confirmed) {
                      AppRepository.instance.deleteComment(comment.id);
                      ref.invalidate(homeFeedProvider);
                      ref.invalidate(momentsFeedProvider);
                      _refreshComments();
                      showAppToast(context, '已删除');
                    }
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirm() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后不可恢复，确定要删除这条评论吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final homePosts = ref.watch(homeFeedProvider);
    final momentsPosts = ref.watch(momentsFeedProvider);
    final blockedUsers = ref.watch(blockedUsersProvider);
    final currentUser = ref.watch(authProvider);

    Post? post;
    for (final item in homePosts) {
      if (item.id == widget.postId) {
        post = item;
        break;
      }
    }
    if (post == null) {
      for (final item in momentsPosts) {
        if (item.id == widget.postId) {
          post = item;
          break;
        }
      }
    }

    final currentPost = post;
    if (currentPost == null || blockedUsers.contains(currentPost.userId)) {
      return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
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
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            '该用户内容已隐藏',
            style: TextStyle(color: Color(0xFF999999), fontSize: 14),
          ),
        ),
      );
    }

    // 取一级评论，过滤被拉黑用户
    final topComments = AppRepository.instance
        .getTopLevelComments(widget.postId)
        .where((c) => !blockedUsers.contains(c.userId))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- 帖子作者 ----
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      openUserProfile(context, currentPost.userId);
                    },
                    child: SmartAvatar(
                      radius: 18,
                      source: currentPost.author?.avatarUrl,
                      fallbackName: currentPost.author?.name,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentPost.author?.name ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(currentPost.createdAt),
                          style: const TextStyle(
                            color: Color(0x80111111),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_DetailMoreAction>(
                    icon:
                        const Icon(Icons.more_horiz, color: Color(0xFF666666)),
                    padding: EdgeInsets.zero,
                    color: const Color(0xFF4A4A4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (action) =>
                        _handleMoreAction(action, currentPost.userId),
                    itemBuilder: (_) => const [
                      PopupMenuItem<_DetailMoreAction>(
                        value: _DetailMoreAction.report,
                        child: Center(
                          child: Text(
                            '举报',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      PopupMenuItem<_DetailMoreAction>(
                        value: _DetailMoreAction.block,
                        child: Center(
                          child: Text(
                            '拉黑',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ---- 帖子内容 ----
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
              child: Text(
                currentPost.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
            ),
            if (currentPost.videoUrl != null)
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            VideoPlayerScreen(videoUrl: currentPost.videoUrl!),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (currentPost.images.isNotEmpty)
                            SmartImage(source: currentPost.images.first)
                          else
                            const SmartImage(
                                source: 'assets/images/posts/city_night.jpg'),
                          Container(
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                          const Center(
                            child: Icon(Icons.play_circle_fill,
                                color: Colors.white, size: 48),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (currentPost.images.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                child: Row(
                  children: currentPost.images.take(3).map<Widget>((url) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.0),
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
            // ---- 点赞 / 评论 按钮 ----
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => ref
                        .read(homeFeedProvider.notifier)
                        .toggleLike(currentPost.id),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Icon(
                          currentPost.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 22,
                          color: currentPost.isLiked
                              ? Colors.red
                              : const Color(0xFF666666),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${currentPost.likesCount}',
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
                    onTap: () => _openCommentSheet(currentPost.id),
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
                          '${currentPost.commentsCount}',
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
            // ---- 评论数 ----
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '共${currentPost.commentsCount}条评论',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // ---- 评论列表 ----
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topComments.length,
              itemBuilder: (context, index) {
                final comment = topComments[index];
                final author = AppRepository.instance.getUser(comment.userId);
                final isOwn = currentUser?.id == comment.userId;
                final replies = AppRepository.instance
                    .getReplies(comment.id)
                    .where((r) => !blockedUsers.contains(r.userId))
                    .toList();
                final isExpanded = _expandedComments.contains(comment.id);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
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
                        child: GestureDetector(
                          onLongPress: () => _showCommentActions(
                            comment: comment,
                            isOwnComment: isOwn,
                            parentCommentId: comment.id,
                            replyToUserId: comment.userId,
                            replyToUserName: author.name,
                          ),
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
                              // ---- 二级回复 ----
                              if (replies.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F6F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 展示前 3 条或全部
                                      ...() {
                                        final visible = isExpanded
                                            ? replies
                                            : replies
                                                .take(_kCollapseThreshold)
                                                .toList();
                                        return visible.map((reply) {
                                          final replyAuthor = AppRepository
                                              .instance
                                              .getUser(reply.userId);
                                          final isOwnReply =
                                              currentUser?.id == reply.userId;
                                          // 被回复者与一级评论作者相同时省略「回复 B」
                                          final showReplyTo =
                                              reply.replyToUserName != null &&
                                                  reply.replyToUserId !=
                                                      comment.userId;
                                          return GestureDetector(
                                            onLongPress: () =>
                                                _showCommentActions(
                                              comment: reply,
                                              isOwnComment: isOwnReply,
                                              // 回复的 parent 仍是一级评论
                                              parentCommentId: comment.id,
                                              replyToUserId: reply.userId,
                                              replyToUserName: replyAuthor.name,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 6),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black),
                                                  children: [
                                                    TextSpan(
                                                      text: replyAuthor.name,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    if (showReplyTo) ...[
                                                      const TextSpan(
                                                          text: ' 回复 '),
                                                      TextSpan(
                                                        text: reply
                                                            .replyToUserName,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                    TextSpan(
                                                        text:
                                                            '  ${reply.content}'),
                                                    TextSpan(
                                                      text:
                                                          '  ${_formatTime(reply.createdAt)}',
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xFF999999),
                                                          fontSize: 11),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList();
                                      }(),
                                      // 「查看更多」/ 收起
                                      if (replies.length > _kCollapseThreshold)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isExpanded) {
                                                _expandedComments
                                                    .remove(comment.id);
                                              } else {
                                                _expandedComments
                                                    .add(comment.id);
                                              }
                                            });
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              isExpanded
                                                  ? '收起'
                                                  : '查看更多 ${replies.length - _kCollapseThreshold} 条回复',
                                              style: const TextStyle(
                                                color: Color(0xFF1890FF),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
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

class _CommentInputSheet extends StatefulWidget {
  final ValueChanged<String> onSend;
  final String hintText;

  const _CommentInputSheet({
    required this.onSend,
    this.hintText = '写下你的评论...',
  });

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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
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

enum _DetailMoreAction { report, block }
