import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/system_notification_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

const _kBgColor = Color(0xFFF6F7F9);
const _kTitleColor = Color(0xFF333333);
const _kContentColor = Color(0xFF666666);
const _kMetaColor = Color(0xFF999999);
const _kAccentColor = Color(0xFF7C67D0);

/// 系统通知列表页。与「互动通知」（SystemNotificationsScreen）是两个独立入口：
/// 消息列表的系统通知行进本页，发现页铃铛进互动通知页。
class SystemNoticeScreen extends ConsumerWidget {
  const SystemNoticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(systemNotificationsProvider);
    final currentUserId = ref.watch(authProvider)?.id ?? '';

    return Scaffold(
      backgroundColor: _kBgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _SystemNoticeHeader(),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无系统通知',
                        key: ValueKey<String>('systemNotice.empty'),
                        style: TextStyle(color: _kMetaColor, fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return _SystemNoticeTile(
                          key: ValueKey<String>('systemNotice.item.$index'),
                          itemIndex: index,
                          item: item,
                          isUnread: !item.isReadFor(currentUserId),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemNoticeHeader extends StatelessWidget {
  const _SystemNoticeHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 53,
      child: Stack(
        children: [
          Positioned(
            key: const ValueKey<String>('systemNotice.backFrame'),
            left: 14,
            top: 18,
            width: 20,
            height: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kTitleColor,
                size: 16,
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 14,
            child: Center(
              child: Text(
                key: ValueKey<String>('systemNotice.title'),
                '系统通知',
                style: TextStyle(
                  color: _kTitleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'PingFang SC',
                  height: 28 / 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemNoticeTile extends StatelessWidget {
  const _SystemNoticeTile({
    super.key,
    required this.itemIndex,
    required this.item,
    required this.isUnread,
  });

  final int itemIndex;
  final SystemNotificationItem item;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final route = item.actionRoute;
    final tile = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isUnread) ...[
                Container(
                  key: ValueKey<String>('systemNotice.unreadDot.$itemIndex'),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4D4D),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  item.title,
                  key: ValueKey<String>('systemNotice.title.$itemIndex'),
                  style: const TextStyle(
                    color: _kTitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'PingFang SC',
                  ),
                ),
              ),
              Text(
                _formatTime(item.createdAt),
                key: ValueKey<String>('systemNotice.time.$itemIndex'),
                style: const TextStyle(color: _kMetaColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.content,
            key: ValueKey<String>('systemNotice.content.$itemIndex'),
            style: const TextStyle(
              color: _kContentColor,
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
          if (item.actionLabel != null && item.actionLabel!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.actionLabel!,
              key: ValueKey<String>('systemNotice.action.$itemIndex'),
              style: const TextStyle(
                color: _kAccentColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );

    if (route == null || route.isEmpty) return tile;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push(route),
      child: tile,
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
