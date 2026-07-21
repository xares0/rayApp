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
import '../../widgets/hi_greet_button.dart';
import '../../widgets/interaction_utils.dart';
import '../../widgets/moment_text.dart';
import '../../widgets/smart_avatar.dart';
import '../../widgets/smart_image.dart';

// 每条一级评论最多折叠展示几条回复
const int _kCollapseThreshold = 3;

// 帖卡「Hi」搭讪预设招呼语（与拍友列表 / 动态卡片一致）。
const String _kDetailGreeting = '你的照片很好看，可以教教我怎么拍吗！';

// Figma 37:11576 设计 token
const Color _kPageBg = Color(0xFFF9F9F9);
const Color _kTitle = Color(0xFF202020);
const Color _kText = Color(0xFF333333);
const Color _kMeta = Color(0xFF999999);
const Color _kReply = Color(0xFF666666);
const Color _kCount = Color(0xFFC0C0C0);
const Color _kHint = Color(0xFF8D9298);

class MomentDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const MomentDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<MomentDetailScreen> createState() => _MomentDetailScreenState();
}

class _MomentDetailScreenState extends ConsumerState<MomentDetailScreen> {
  // 已展开全部回复的一级评论 id 集合
  final Set<String> _expandedComments = {};

  // 常驻底部输入栏状态
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool _showEmoji = false;

  // 当前回复目标（为空表示发表新评论）
  String? _replyParentId;
  String? _replyToUserId;
  String? _replyToUserName;

  // 长按评论弹出的深色气泡（Figma 删除/回复 tooltip）
  OverlayEntry? _actionBubble;

  static const List<String> _emojis = [
    '😀', '😄', '😁', '😆', '😊', '🥰', '😍', '😘',
    '😎', '🤗', '🤔', '😅', '😭', '😡', '👍', '👏',
    '🙏', '🎉', '❤️', '🔥', '✨', '💯', '🌟', '📷',
  ];

  bool get _canSend => _commentController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _removeActionBubble();
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
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

  /// 帖子视频点击：进入全屏视频查看（Figma v4 `37:624`），与动态列表一致。
  void _openVideoFeed(Post post) {
    final videoPosts = AppRepository.instance.posts
        .where((p) => (p.videoUrl ?? '').isNotEmpty)
        .toList();
    final idx = videoPosts.indexWhere((p) => p.id == post.id);
    // 走 go_router 声明式（与裸 Navigator.push 混用会触发 keyReservation 崩溃）
    context.push('/video_feed', extra: <String, dynamic>{
      'posts': videoPosts.isEmpty ? <Post>[post] : videoPosts,
      'initialIndex': idx < 0 ? 0 : idx,
    });
  }

  /// 帖卡右上角「Hi」搭讪：进入与作者私聊并自动发送预设招呼语。
  void _greetUser(String userId) {
    final uri = Uri(
      path: '/chat/$userId',
      queryParameters: <String, String>{'greeting': _kDetailGreeting},
    );
    context.push(uri.toString());
  }

  /// 切到回复模式：底部输入栏聚焦并展示「回复 xxx」提示
  void _startReply({
    required String parentId,
    required String replyToUserId,
    required String replyToUserName,
  }) {
    setState(() {
      _replyParentId = parentId;
      _replyToUserId = replyToUserId;
      _replyToUserName = replyToUserName;
      _showEmoji = false;
    });
    _commentFocus.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyParentId = null;
      _replyToUserId = null;
      _replyToUserName = null;
    });
  }

  void _refreshAfterMutation() {
    ref.invalidate(homeFeedProvider);
    ref.invalidate(momentsFeedProvider);
  }

  /// 发送评论 / 回复
  void _sendComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      showAppToast(context, '请先登录后评论');
      return;
    }

    final isReply = _replyParentId != null;
    AppRepository.instance.addComment(
      postId: widget.postId,
      userId: currentUser.id,
      content: content,
      parentId: _replyParentId,
      replyToUserId: _replyToUserId,
      replyToUserName: _replyToUserName,
    );
    _refreshAfterMutation();

    _commentController.clear();
    _commentFocus.unfocus();
    setState(() {
      _showEmoji = false;
      _replyParentId = null;
      _replyToUserId = null;
      _replyToUserName = null;
    });
    showAppToast(context, isReply ? '回复已发送' : '评论已发送');
  }

  void _insertEmoji(String emoji) {
    final sel = _commentController.selection;
    final text = _commentController.text;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final newText = text.replaceRange(start, end, emoji);
    _commentController.value = _commentController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  void _toggleEmoji() {
    setState(() => _showEmoji = !_showEmoji);
    if (_showEmoji) {
      _commentFocus.unfocus();
    } else {
      _commentFocus.requestFocus();
    }
  }

  void _removeActionBubble() {
    _actionBubble?.remove();
    _actionBubble = null;
  }

  /// 长按评论：弹出 Figma 深色气泡（本人评论→删除，他人评论→回复）
  void _showActionBubble({
    required Offset globalPos,
    required Comment comment,
    required bool isOwnComment,
    required String parentCommentId,
    required String replyToUserId,
    required String replyToUserName,
  }) {
    _removeActionBubble();
    HapticFeedback.lightImpact();

    final screen = MediaQuery.of(context).size;
    const double bubbleW = 56;
    const double bubbleH = 60; // 含底部三角
    final double left =
        (globalPos.dx - bubbleW / 2).clamp(8.0, screen.width - bubbleW - 8);
    double top = globalPos.dy - bubbleH - 8;
    if (top < MediaQuery.of(context).padding.top + 8) {
      top = globalPos.dy + 8; // 顶部空间不足则翻到下方
    }

    void onTap() {
      _removeActionBubble();
      if (isOwnComment) {
        _confirmDeleteComment(comment);
      } else {
        _startReply(
          parentId: parentCommentId,
          replyToUserId: replyToUserId,
          replyToUserName: replyToUserName,
        );
      }
    }

    _actionBubble = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeActionBubble,
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: _ActionBubble(isDelete: isOwnComment, onTap: onTap),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_actionBubble!);
  }

  Future<void> _confirmDeleteComment(Comment comment) async {
    final confirmed = await _showDeleteConfirm();
    if (!mounted) return;
    if (!confirmed) return;
    AppRepository.instance.deleteComment(comment.id);
    _refreshAfterMutation();
    setState(() {});
    showAppToast(context, '已删除');
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
        backgroundColor: _kPageBg,
        appBar: _buildAppBar(showMore: false, userId: ''),
        body: const Center(
          child: Text(
            '该用户内容已隐藏',
            style: TextStyle(color: _kMeta, fontSize: 14),
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
      backgroundColor: _kPageBg,
      appBar: _buildAppBar(showMore: true, userId: currentPost.userId),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostCard(currentPost),
                    const SizedBox(height: 16),
                    // ---- 全部评论标题 ----
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        '全部评论（${topComments.length}）',
                        style: const TextStyle(
                          color: _kText,
                          fontSize: 14,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ---- 评论列表 ----
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topComments.length,
                      itemBuilder: (context, index) => _buildCommentItem(
                        topComments[index],
                        blockedUsers,
                        currentUser?.id,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({
    required bool showMore,
    required String userId,
  }) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        '投稿详情',
        style: TextStyle(
          color: _kTitle,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
      backgroundColor: _kPageBg,
      elevation: 0,
      // Figma v4：举报/拉黑入口在导航栏右上角「⋯」，非帖卡内。
      actions: showMore
          ? [
              PopupMenuButton<_DetailMoreAction>(
                icon: const Icon(Icons.more_horiz, color: _kText),
                color: const Color(0xFF4A4A4A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (action) => _handleMoreAction(action, userId),
                itemBuilder: (_) => const [
                  PopupMenuItem<_DetailMoreAction>(
                    value: _DetailMoreAction.report,
                    child: Center(
                      child: Text('举报',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  PopupMenuItem<_DetailMoreAction>(
                    value: _DetailMoreAction.block,
                    child: Center(
                      child: Text('拉黑',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ]
          : null,
    );
  }

  /// 帖子白色圆角卡片
  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- 作者 ----
          Row(
            children: [
              GestureDetector(
                onTap: () => openUserProfile(context, post.userId),
                child: SmartAvatar(
                  radius: 17.5,
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
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: _kText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(post.createdAt),
                      style: const TextStyle(color: _kCount, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Figma v4：帖卡右上角为「Hi」搭讪钮（举报/拉黑见导航栏「⋯」）
              GestureDetector(
                onTap: () => _greetUser(post.userId),
                behavior: HitTestBehavior.opaque,
                child: const HiGreetButton(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ---- 正文 ----
          MomentText(
            translated: post.content,
            original: post.contentOriginal,
            style: const TextStyle(fontSize: 14, color: _kText, height: 1.5),
          ),
          // ---- 视频 / 图片 ----
          if (post.videoUrl != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _openVideoFeed(post),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (post.images.isNotEmpty)
                        SmartImage(source: post.images.first)
                      else
                        const SmartImage(
                            source: 'assets/images/posts/city_night.jpg'),
                      Container(color: Colors.black.withValues(alpha: 0.3)),
                      const Center(
                        child: Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 48),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(post.images.take(3).length, (i) {
                final url = post.images[i];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 7 : 0),
                    child: GestureDetector(
                      onTap: () => showImagePreview(context, url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: SmartImage(source: url),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 14),
          // ---- 点赞 / 评论（右下角）----
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () =>
                    ref.read(homeFeedProvider.notifier).toggleLike(post.id),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: post.isLiked ? Colors.red : _kCount,
                    ),
                    const SizedBox(width: 4),
                    Text('${post.likesCount}',
                        style: const TextStyle(color: _kCount, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  _cancelReply();
                  _commentFocus.requestFocus();
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        size: 16, color: _kCount),
                    const SizedBox(width: 4),
                    Text('${post.commentsCount}',
                        style: const TextStyle(color: _kCount, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 单条一级评论（含二级回复）
  Widget _buildCommentItem(
    Comment comment,
    Set<String> blockedUsers,
    String? currentUserId,
  ) {
    final author = AppRepository.instance.getUser(comment.userId);
    final isOwn = currentUserId == comment.userId;
    final replies = AppRepository.instance
        .getReplies(comment.id)
        .where((r) => !blockedUsers.contains(r.userId))
        .toList();
    final isExpanded = _expandedComments.contains(comment.id);
    final visibleReplies =
        isExpanded ? replies : replies.take(_kCollapseThreshold).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => openUserProfile(context, author.id),
            child: SmartAvatar(
              radius: 15,
              source: author.avatarUrl,
              fallbackName: author.name,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onLongPressStart: (d) => _showActionBubble(
                globalPos: d.globalPosition,
                comment: comment,
                isOwnComment: isOwn,
                parentCommentId: comment.id,
                replyToUserId: comment.userId,
                replyToUserName: author.name,
              ),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author.name,
                    style: const TextStyle(fontSize: 13, color: _kText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: const TextStyle(fontSize: 13, color: _kText),
                  ),
                  const SizedBox(height: 6),
                  _buildMetaRow(
                    time: comment.createdAt,
                    onReply: () => _startReply(
                      parentId: comment.id,
                      replyToUserId: comment.userId,
                      replyToUserName: author.name,
                    ),
                  ),
                  // ---- 二级回复 ----
                  if (visibleReplies.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...visibleReplies.map((reply) => _buildReplyItem(
                          reply,
                          comment,
                          currentUserId,
                        )),
                  ],
                  if (replies.length > _kCollapseThreshold)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedComments.remove(comment.id);
                          } else {
                            _expandedComments.add(comment.id);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          isExpanded
                              ? '收起'
                              : '查看更多 ${replies.length - _kCollapseThreshold} 条回复',
                          style: const TextStyle(color: _kHint, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 单条二级回复（小头像 + 昵称 + 正文 + 时间/回复）
  Widget _buildReplyItem(
    Comment reply,
    Comment parent,
    String? currentUserId,
  ) {
    final replyAuthor = AppRepository.instance.getUser(reply.userId);
    final isOwnReply = currentUserId == reply.userId;
    // 被回复者与一级评论作者相同时省略「回复 B」
    final showReplyTo = reply.replyToUserName != null &&
        reply.replyToUserId != parent.userId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onLongPressStart: (d) => _showActionBubble(
          globalPos: d.globalPosition,
          comment: reply,
          isOwnComment: isOwnReply,
          parentCommentId: parent.id,
          replyToUserId: reply.userId,
          replyToUserName: replyAuthor.name,
        ),
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmartAvatar(
              radius: 9.5,
              source: replyAuthor.avatarUrl,
              fallbackName: replyAuthor.name,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: _kReply),
                      children: [
                        TextSpan(text: replyAuthor.name),
                        if (showReplyTo) ...[
                          const TextSpan(text: ' 回复 '),
                          TextSpan(text: reply.replyToUserName),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reply.content,
                    style: const TextStyle(fontSize: 12, color: _kText),
                  ),
                  const SizedBox(height: 6),
                  _buildMetaRow(
                    time: reply.createdAt,
                    onReply: () => _startReply(
                      parentId: parent.id,
                      replyToUserId: reply.userId,
                      replyToUserName: replyAuthor.name,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 时间 + 回复 行（评论与回复共用）
  Widget _buildMetaRow({
    required DateTime time,
    required VoidCallback onReply,
  }) {
    return Row(
      children: [
        Text(
          _formatCommentTime(time),
          style: const TextStyle(fontSize: 11, color: _kMeta),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onReply,
          behavior: HitTestBehavior.opaque,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 13, color: _kReply),
              SizedBox(width: 3),
              Text('回复', style: TextStyle(fontSize: 11, color: _kReply)),
            ],
          ),
        ),
      ],
    );
  }

  /// 常驻底部输入栏（胶囊输入 + 表情 + 发送）
  Widget _buildInputBar() {
    final isReply = _replyParentId != null;
    return Container(
      color: _kPageBg,
      padding: const EdgeInsets.fromLTRB(13, 8, 13, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isReply)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 6),
              child: Row(
                children: [
                  Text(
                    '回复 ${_replyToUserName ?? ''}',
                    style: const TextStyle(fontSize: 12, color: _kMeta),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: const Icon(Icons.close, size: 14, color: _kMeta),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(41),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 24,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          focusNode: _commentFocus,
                          textInputAction: TextInputAction.send,
                          style: const TextStyle(fontSize: 14, color: _kText),
                          onTap: () {
                            if (_showEmoji) {
                              setState(() => _showEmoji = false);
                            }
                          },
                          onSubmitted: (_) => _sendComment(),
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: '留下您的心声，让交流多一份温暖',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: _kHint,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        key: const ValueKey<String>('comment.emojiToggle'),
                        onTap: _toggleEmoji,
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          _showEmoji
                              ? Icons.keyboard_outlined
                              : Icons.emoji_emotions_outlined,
                          size: 20,
                          color: _kMeta,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sendComment,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _canSend
                          ? const [Color(0xFFB18CFF), Color(0xFF9B6BF7)]
                          : const [Color(0xFFD8C8FF), Color(0xFFCBB6FB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          if (_showEmoji)
            Container(
              key: const ValueKey<String>('comment.emojiPanel'),
              height: 200,
              margin: const EdgeInsets.only(top: 8),
              child: GridView.count(
                crossAxisCount: 8,
                children: _emojis
                    .map((e) => GestureDetector(
                          onTap: () => _insertEmoji(e),
                          child: Center(
                            child:
                                Text(e, style: const TextStyle(fontSize: 22)),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}个小时前';
    return '${diff.inDays}天前';
  }

  /// 评论时间：当天显示「今天 HH:mm」，否则「MM-dd HH:mm」
  String _formatCommentTime(DateTime time) {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final hm = '${two(time.hour)}:${two(time.minute)}';
    final isToday =
        now.year == time.year && now.month == time.month && now.day == time.day;
    if (isToday) return '今天 $hm';
    return '${two(time.month)}-${two(time.day)} $hm';
  }
}

enum _DetailMoreAction { report, block }

/// Figma 长按评论弹出的深色气泡（图标 + 文案 + 底部三角）
class _ActionBubble extends StatelessWidget {
  const _ActionBubble({required this.isDelete, required this.onTap});

  final bool isDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const bubbleColor = Color(0xF2444444);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDelete ? Icons.delete_outline : Icons.reply,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(height: 2),
                Text(
                  isDelete ? '删除' : '回复',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
          const CustomPaint(
            size: Size(12, 6),
            painter: _BubbleArrowPainter(bubbleColor),
          ),
        ],
      ),
    );
  }
}

class _BubbleArrowPainter extends CustomPainter {
  const _BubbleArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
