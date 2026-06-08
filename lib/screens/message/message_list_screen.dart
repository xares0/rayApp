import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../models/chat_conversation.dart';
import '../../models/message.dart';
import '../../models/system_notification_item.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/interaction_utils.dart';
import '../../widgets/smart_avatar.dart';

class MessageListScreen extends ConsumerStatefulWidget {
  const MessageListScreen({super.key});

  @override
  ConsumerState<MessageListScreen> createState() => _MessageListScreenState();
}

enum _ManageMenuAction { clearConversations, markAllRead }

class _MessageListScreenState extends ConsumerState<MessageListScreen> {
  static const _manageIconAsset = 'assets/icons/message_manage_figma.svg';
  static const double _messageActionWidth = 80;
  static const String _conversationSlidableGroup = 'message_conversation_group';
  static const Color _pinnedConversationBackground = Color(0x33A699FF);

  final LayerLink _manageMenuLink = LayerLink();
  bool _isManageMenuVisible = false;

  Future<void> _confirmDelete(String otherUserId) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;
    final confirmed = await showFigmaSplitConfirmDialog(
      context,
      message: '确定删除该聊天？',
      confirmText: '删除',
    );
    if (!confirmed) return;
    AppRepository.instance.hideConversation(
      userId: currentUser.id,
      otherUserId: otherUserId,
    );
    ref.invalidate(chatListProvider);
  }

  Future<void> _showManageActions() async {
    setState(() {
      _isManageMenuVisible = !_isManageMenuVisible;
    });
  }

  void _hideManageMenu() {
    if (!_isManageMenuVisible) return;
    setState(() {
      _isManageMenuVisible = false;
    });
  }

  Future<void> _togglePinnedConversation(ChatConversation conversation) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;
    if (conversation.isPinned) {
      AppRepository.instance.unpinConversation(
        userId: currentUser.id,
        otherUserId: conversation.user.id,
      );
    } else {
      AppRepository.instance.pinConversation(
        userId: currentUser.id,
        otherUserId: conversation.user.id,
      );
    }
    ref.invalidate(chatListProvider);
  }

  Future<void> _handleManageMenuAction(_ManageMenuAction action) async {
    _hideManageMenu();
    switch (action) {
      case _ManageMenuAction.clearConversations:
        await _confirmClearConversations();
        break;
      case _ManageMenuAction.markAllRead:
        await _confirmMarkAllRead();
        break;
    }
  }

  Future<void> _confirmClearConversations() async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;
    final confirmed = await showFigmaSplitConfirmDialog(
      context,
      message: '是否要清空聊天列表？',
      confirmText: '清空',
    );
    if (!confirmed) return;
    AppRepository.instance.clearConversationList(currentUser.id);
    ref.invalidate(chatListProvider);
  }

  Future<void> _confirmMarkAllRead() async {
    final confirmed = await showFigmaSplitConfirmDialog(
      context,
      message: '是否要一键已读所有消息？',
    );
    if (!confirmed) return;

    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;
    AppRepository.instance.markAllMessagesAsRead(currentUser.id);
    AppRepository.instance.markAllSystemNotificationsRead(currentUser.id);
    ref.invalidate(chatListProvider);
    ref.invalidate(systemNotificationsProvider);
  }

  String _formatMessagePreview(Message message) {
    switch (message.type) {
      case MessageType.image:
        return '[图片]';
      case MessageType.video:
        return '[视频]';
      case MessageType.voice:
        final duration = message.voiceDurationSeconds ?? 0;
        return "[语音]$duration'";
      case MessageType.emoji:
        return '[${message.emojiLabel ?? '表情'}]';
      case MessageType.recall:
        return '撤回了一条消息';
      case MessageType.system:
        return message.content;
      case MessageType.text:
        if (message.content.length <= 15) return message.content;
        return '${message.content.substring(0, 15)}...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final chatList = ref.watch(chatListProvider);
    final notifications = ref.watch(systemNotificationsProvider);
    final repository = AppRepository.instance;
    final latestNotification =
        notifications.isEmpty ? null : notifications.first;
    final systemUnreadCount = currentUser == null
        ? 0
        : repository.getSystemNotificationUnreadCount(currentUser.id);
    ChatConversation? officialSupportConversation;
    final normalConversations = <ChatConversation>[];
    for (final conversation in chatList) {
      if (repository.isOfficialSupportUser(conversation.user.id)) {
        officialSupportConversation ??= conversation;
      } else {
        normalConversations.add(conversation);
      }
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          Column(
            children: [
              _MessageHeaderBackground(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                        child: SizedBox(
                          height: 32,
                          child: Row(
                            children: [
                              const SizedBox(width: 32),
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    '炫技中心',
                                    style: TextStyle(
                                      color: Color(0xFF202020),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CompositedTransformTarget(
                                  link: _manageMenuLink,
                                  child: IconButton(
                                    key: const ValueKey<String>(
                                      'message_manage_button',
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 32,
                                      height: 32,
                                    ),
                                    splashRadius: 18,
                                    onPressed: _showManageActions,
                                    icon: SvgPicture.asset(
                                      _manageIconAsset,
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xFF999999),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SlidableAutoCloseBehavior(
                  child: NotificationListener<ScrollStartNotification>(
                    onNotification: (notification) {
                      _hideManageMenu();
                      return false;
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      children: [
                        _buildSystemNotificationTile(
                          latestNotification,
                          systemUnreadCount,
                        ),
                        if (officialSupportConversation != null)
                          _buildConversationTile(
                            officialSupportConversation,
                            repository,
                            highlighted: true,
                          ),
                        if (normalConversations.isEmpty &&
                            officialSupportConversation == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 64),
                            child: Center(
                              child: Text(
                                '暂无会话，先去发现页找人聊聊吧',
                                style: TextStyle(color: Color(0xFF999999)),
                              ),
                            ),
                          )
                        else
                          ...normalConversations.map(
                            (conversation) => _buildConversationTile(
                              conversation,
                              repository,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isManageMenuVisible)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _hideManageMenu,
                child: const SizedBox.expand(),
              ),
            ),
          if (_isManageMenuVisible)
            CompositedTransformFollower(
              link: _manageMenuLink,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 10),
              child: _MessageManageMenu(onSelected: _handleManageMenuAction),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemNotificationTile(
    SystemNotificationItem? latestNotification,
    int unreadCount,
  ) {
    return _ChatListTile(
      backgroundKey: const ValueKey<String>('message_system_background'),
      backgroundColor: _pinnedConversationBackground,
      title: '系统通知',
      preview:
          latestNotification?.content ?? AppRepository.systemWelcomeMessage,
      timeText: latestNotification == null
          ? '刚刚'
          : _formatTime(latestNotification.createdAt),
      unreadCount: unreadCount,
      leading: _SpecialAvatar(
        backgroundColor: const Color(0xFFD4A011),
        icon: Icons.notifications,
        badgeText: unreadCount > 99 ? '99+' : '$unreadCount',
        showBadge: unreadCount > 0,
      ),
      onTap: () {
        final currentUser = ref.read(authProvider);
        if (currentUser != null) {
          AppRepository.instance.markAllSystemNotificationsRead(currentUser.id);
          ref.invalidate(systemNotificationsProvider);
        }
        context.push('/system_notifications');
      },
    );
  }

  Widget _buildConversationTile(
      ChatConversation conversation, AppRepository repository,
      {bool highlighted = false}) {
    final tile = Builder(
      builder: (tileContext) => _ChatListTile(
        key: ValueKey<String>(
          'message_conversation_tile_${conversation.user.id}',
        ),
        backgroundKey: ValueKey<String>(
          'message_conversation_background_${conversation.user.id}',
        ),
        backgroundColor: highlighted || conversation.isPinned
            ? _pinnedConversationBackground
            : Colors.transparent,
        user: conversation.user,
        title: conversation.displayName,
        preview: _formatMessagePreview(conversation.latestMessage),
        timeText: _formatTime(conversation.latestMessage.createdAt),
        unreadCount: conversation.unreadCount,
        onTap: () async {
          _hideManageMenu();
          final slidable = Slidable.of(tileContext);
          if ((slidable?.ratio ?? 0).abs() > 0.001) {
            await slidable?.close();
            return;
          }
          if (!mounted) return;
          context.push('/chat/${conversation.user.id}');
        },
      ),
    );

    if (repository.isOfficialSupportUser(conversation.user.id)) {
      return tile;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final extentRatio =
            (_messageActionWidth * 2 / constraints.maxWidth).clamp(0.0, 1.0);
        return Slidable(
          key: ValueKey<String>('message_swipe_tile_${conversation.user.id}'),
          groupTag: _conversationSlidableGroup,
          endActionPane: ActionPane(
            extentRatio: extentRatio,
            motion: const ScrollMotion(),
            children: [
              CustomSlidableAction(
                key: ValueKey<String>(
                  'message_action_pin_${conversation.user.id}',
                ),
                backgroundColor: const Color(0xFF779BFF),
                onPressed: (_) => _togglePinnedConversation(conversation),
                child: Text(
                  conversation.isPinned ? '取消置顶' : '置顶',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              CustomSlidableAction(
                key: ValueKey<String>(
                  'message_action_delete_${conversation.user.id}',
                ),
                backgroundColor: const Color(0xFFFF4B4B),
                onPressed: (_) => _confirmDelete(conversation.user.id),
                child: const Text(
                  '删除',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          child: tile,
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

class _MessageHeaderBackground extends StatelessWidget {
  const _MessageHeaderBackground({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey<String>('message_header_background'),
      decoration: const BoxDecoration(color: Color(0x33A699FF)),
      child: child,
    );
  }
}

class _MessageManageMenu extends StatelessWidget {
  const _MessageManageMenu({
    required this.onSelected,
  });

  final ValueChanged<_ManageMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: SizedBox(
        width: 102,
        height: 76,
        child: CustomPaint(
          painter: const _MessageManageMenuPainter(),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                _MessageManageMenuItem(
                  key: const ValueKey<String>('message_manage_action_clear'),
                  title: '清空聊天列表',
                  onTap: () => onSelected(_ManageMenuAction.clearConversations),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                _MessageManageMenuItem(
                  key: const ValueKey<String>('message_manage_action_read'),
                  title: '一键已读',
                  onTap: () => onSelected(_ManageMenuAction.markAllRead),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageManageMenuPainter extends CustomPainter {
  const _MessageManageMenuPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 7, size.width, size.height - 7),
      const Radius.circular(4),
    );
    final path = Path()..addRRect(rect);
    path.moveTo(size.width - 23, 7);
    path.lineTo(size.width - 14, 0);
    path.lineTo(size.width - 8, 7);
    path.close();

    final paint = Paint()..color = const Color(0xFF444444);
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.12), 4, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MessageManageMenuItem extends StatelessWidget {
  const _MessageManageMenuItem({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 31,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  static const double _messageRowHeight = 59;
  static const double _horizontalPadding = 18;
  static const double _dividerLeftInset = 74;

  const _ChatListTile({
    super.key,
    this.backgroundKey,
    this.backgroundColor = Colors.transparent,
    this.user,
    this.title,
    required this.preview,
    required this.timeText,
    this.unreadCount = 0,
    this.leading,
    required this.onTap,
  }) : assert(user != null || title != null);

  final Key? backgroundKey;
  final Color backgroundColor;
  final User? user;
  final String? title;
  final String preview;
  final String timeText;
  final int unreadCount;
  final Widget? leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? user!.name;
    final leadingWidget = leading ?? _buildDefaultAvatar();

    return ColoredBox(
      key: backgroundKey,
      color: backgroundColor,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: _messageRowHeight,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _horizontalPadding,
                  ),
                  child: Row(
                    children: [
                      leadingWidget,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayTitle,
                              style: const TextStyle(
                                color: Color(0xFF202020),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        timeText,
                        style: const TextStyle(
                          color: Color(0xFFB9B9B9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  left: _dividerLeftInset,
                  right: _horizontalPadding,
                  bottom: 0,
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Color(0xFFE9E5F1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final currentUser = user!;
    if (currentUser.id == AppRepository.officialSupportUserId) {
      return const _SpecialAvatar(
        backgroundColor: Color(0xFF4A84C9),
        icon: Icons.headset_mic_rounded,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SmartAvatar(
          radius: 25,
          source: currentUser.avatarUrl,
          fallbackName: currentUser.name,
        ),
        if (unreadCount > 0)
          Positioned(
            top: -4,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFE04A4A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SpecialAvatar extends StatelessWidget {
  const _SpecialAvatar({
    required this.backgroundColor,
    required this.icon,
    this.badgeText,
    this.showBadge = false,
  });

  final Color backgroundColor;
  final IconData icon;
  final String? badgeText;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        if (showBadge && badgeText != null)
          Positioned(
            top: -3,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFE04A4A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
