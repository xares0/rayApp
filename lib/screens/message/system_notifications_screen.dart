import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/interaction_badge_provider.dart';
import '../../widgets/smart_avatar.dart';
import '../../widgets/smart_image.dart';

// ── Mock 数据模型 ───────────────────────────────────────────────────────────────

enum InteractionType { liked, iLiked, commented, replied }

class InteractionNotifyItem {
  const InteractionNotifyItem({
    required this.id,
    required this.type,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.timeLabel,
    required this.postId,
    this.thumbnailUrl,
    this.previewText,
    this.actionContent,
  });

  final String id;
  final InteractionType type;
  final String senderName;
  final String senderAvatarUrl;
  final String timeLabel;

  /// 对应动态 id（如 'p1'），点击通知行跳转到该动态详情
  final String postId;

  /// 右侧：图片缩略图（有图动态时显示）
  final String? thumbnailUrl;

  /// 右侧：纯文字预览（无缩略图时显示，经 [_buildPreviewText] 处理后渲染）
  final String? previewText;

  /// 评论/回复内容（被评论、被回复 tab 专用）
  final String? actionContent;
}

// ── 文字预览截断 helper ────────────────────────────────────────────────────────
/// 取前 10 个字符（超出加 …），然后每 4 字符插入换行，最多 3 行。
String _buildPreviewText(String raw) {
  final truncated = raw.length > 10 ? '${raw.substring(0, 10)}…' : raw;
  final buf = StringBuffer();
  int lineCount = 0;
  int charInLine = 0;
  for (final ch in truncated.characters) {
    if (lineCount >= 3) break;
    buf.write(ch);
    charInLine++;
    if (charInLine >= 4 && lineCount < 2) {
      buf.write('\n');
      charInLine = 0;
      lineCount++;
    }
  }
  return buf.toString();
}

// ── 四个 tab 的 mock 数据 ─────────────────────────────────────────────────────
final _mockData = <InteractionType, List<InteractionNotifyItem>>{
  InteractionType.liked: [
    const InteractionNotifyItem(
      id: 'l1',
      type: InteractionType.liked,
      senderName: '棠也',
      senderAvatarUrl: 'assets/images/avatars/male/male_03.jpg',
      timeLabel: '5分钟前',
      postId: 'p1',
      thumbnailUrl: 'assets/images/avatars/female/female_01.jpg',
    ),
    const InteractionNotifyItem(
      id: 'l2',
      type: InteractionType.liked,
      senderName: '棠也',
      senderAvatarUrl: 'assets/images/avatars/male/male_03.jpg',
      timeLabel: '5分钟前',
      postId: 'p3',
      thumbnailUrl: 'assets/images/avatars/female/female_01.jpg',
    ),
    const InteractionNotifyItem(
      id: 'l3',
      type: InteractionType.liked,
      senderName: '棠也',
      senderAvatarUrl: 'assets/images/avatars/male/male_03.jpg',
      timeLabel: '5分钟前',
      postId: 'p5',
      previewText: '把孤独酿成酒，敬路过...',
    ),
  ],
  // vv2 缺省页：无数据时展示 184x184 空态插画。
  InteractionType.iLiked: [],
  InteractionType.commented: [
    const InteractionNotifyItem(
      id: 'c1',
      type: InteractionType.commented,
      senderName: '棠也',
      senderAvatarUrl: 'assets/images/avatars/female/female_08.jpg',
      timeLabel: '5分钟前',
      postId: 'p1',
      actionContent: '好看！这是哪里拍的',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&q=80',
    ),
    const InteractionNotifyItem(
      id: 'c2',
      type: InteractionType.commented,
      senderName: '阿远',
      senderAvatarUrl: 'assets/images/avatars/male/male_06.jpg',
      timeLabel: '20分钟前',
      postId: 'p3',
      actionContent: '氛围感拉满了',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=200&q=80',
    ),
    const InteractionNotifyItem(
      id: 'c3',
      type: InteractionType.commented,
      senderName: '小鱼',
      senderAvatarUrl: 'assets/images/avatars/female/female_03.jpg',
      timeLabel: '1小时前',
      postId: 'p7',
      actionContent: '构图太棒了',
      previewText: '城市里的霓虹夜',
    ),
  ],
  InteractionType.replied: [
    const InteractionNotifyItem(
      id: 'r1',
      type: InteractionType.replied,
      senderName: '晴晴',
      senderAvatarUrl: 'assets/images/avatars/female/female_04.jpg',
      timeLabel: '8分钟前',
      postId: 'p2',
      actionContent: '同感，我也很喜欢这里',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=200&q=80',
    ),
    const InteractionNotifyItem(
      id: 'r2',
      type: InteractionType.replied,
      senderName: '木木',
      senderAvatarUrl: 'assets/images/avatars/male/male_05.jpg',
      timeLabel: '45分钟前',
      postId: 'p5',
      actionContent: '哈哈是的，当时拍了好久',
      previewText: '把孤独酿成美好的旅程',
    ),
    const InteractionNotifyItem(
      id: 'r3',
      type: InteractionType.replied,
      senderName: '叶子',
      senderAvatarUrl: 'assets/images/avatars/female/female_05.jpg',
      timeLabel: '3小时前',
      postId: 'p9',
      actionContent: '下次一起去吧！',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=200&q=80',
    ),
  ],
};

// ── Provider ───────────────────────────────────────────────────────────────────

final _selectedTabProvider = StateProvider<int>((ref) => 0);

// ── 常量 ──────────────────────────────────────────────────────────────────────

const _kTabs = ['被点赞', '我点赞的', '被评论', '被回复'];
const _kTabTypes = [
  InteractionType.liked,
  InteractionType.iLiked,
  InteractionType.commented,
  InteractionType.replied,
];

// Figma: 分段 tab 选中色 #7C67D0
const _kSelectedColor = Color(0xFF7C67D0);
const _kUnselectedColor = Color(0xFF333333);
const _kBgColor = Color(0xFFF6F7F9);

// ── Screen ────────────────────────────────────────────────────────────────────

class SystemNotificationsScreen extends ConsumerWidget {
  const SystemNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(_selectedTabProvider);

    // 进入页面即清除未读红点（PostFrameCallback 避免在 build 中直接修改状态）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interactionBadgeProvider.notifier).clear();
    });

    return Scaffold(
      backgroundColor: _kBgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _InteractionHeader(
              selectedIndex: selectedTab,
              onTap: (i) => ref.read(_selectedTabProvider.notifier).state = i,
            ),
            Expanded(child: _TabContent(selectedIndex: selectedTab)),
          ],
        ),
      ),
    );
  }
}

class _InteractionHeader extends StatelessWidget {
  const _InteractionHeader({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: Stack(
        children: [
          Positioned(
            key: const ValueKey<String>('interaction.backFrame'),
            left: 14,
            top: 18,
            width: 20,
            height: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF333333),
                size: 16,
              ),
            ),
          ),
          const Positioned(
            left: 128,
            top: 14,
            width: 120,
            height: 28,
            child: Center(
              child: Text(
                key: ValueKey<String>('interaction.title'),
                '互动通知',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'PingFang SC',
                  height: 28 / 20,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 53,
            child: _InteractionTabBar(
              selectedIndex: selectedIndex,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 分段 Tab 栏 ────────────────────────────────────────────────────────────────

class _InteractionTabBar extends StatelessWidget {
  const _InteractionTabBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Stack(
        children: List.generate(_kTabs.length, (i) {
          const centerXs = [38.0, 140.0, 242.0, 336.0];
          const widths = [56.0, 72.0, 56.0, 56.0];
          final isSelected = i == selectedIndex;
          return Positioned(
            left: centerXs[i] - widths[i] / 2,
            top: 0,
            width: widths[i],
            height: 22,
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Text(
                  key: ValueKey<String>('interaction.tab.$i'),
                  _kTabs[i],
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'PingFang SC',
                    color: isSelected ? _kSelectedColor : _kUnselectedColor,
                    height: 22 / 16,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Tab 内容区 ─────────────────────────────────────────────────────────────────

class _TabContent extends StatelessWidget {
  const _TabContent({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final type = _kTabTypes[selectedIndex];
    final items = _mockData[type] ?? [];

    if (items.isEmpty) {
      return const _EmptyView();
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _NotifyRow(
          index: index,
          item: items[index],
          showDivider: index < items.length - 1,
        );
      },
    );
  }
}

// ── 通知行 ─────────────────────────────────────────────────────────────────────

class _NotifyRow extends StatelessWidget {
  const _NotifyRow({
    required this.index,
    required this.item,
    required this.showDivider,
  });

  final int index;
  final InteractionNotifyItem item;
  final bool showDivider;

  Widget _buildActionBadge() {
    final bool isLikeTab = item.type == InteractionType.liked ||
        item.type == InteractionType.iLiked;

    if (!isLikeTab) {
      return Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 12,
            color: Color(0xFF999999),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${item.type == InteractionType.commented ? '评论' : '回复'}：${item.actionContent ?? ''}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'PingFang SC',
                color: Color(0xFF999999),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Container(
      width: 37,
      height: 15,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          SizedBox(width: 4),
          Icon(
            Icons.favorite,
            size: 12,
            color: Color(0xFF999999),
          ),
          SizedBox(width: 4),
          Text(
            '赞',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'PingFang SC',
              color: Color(0xFF999999),
              height: 17 / 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing() {
    if (item.thumbnailUrl != null) {
      return SmartImage(
        source: item.thumbnailUrl!,
        width: 47,
        height: 56,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(8),
      );
    }

    if (item.previewText != null) {
      return SizedBox(
        width: 48,
        height: 51,
        child: Text(
          _buildPreviewText(item.previewText!),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'PingFang SC',
            color: Color(0xFF666666),
            height: 17 / 12,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  double get _trailingTop {
    if (item.thumbnailUrl != null) return -7;
    if (item.previewText != null) return -4;
    return 0;
  }

  double get _trailingHeight {
    if (item.thumbnailUrl != null) return 56;
    if (item.previewText != null) return 51;
    return 0;
  }

  bool get _hasTrailing =>
      item.thumbnailUrl != null || item.previewText != null;

  double get _rowHeight {
    switch (item.type) {
      case InteractionType.liked:
      case InteractionType.iLiked:
        return 72;
      case InteractionType.commented:
      case InteractionType.replied:
        return 78;
    }
  }

  Widget _buildActionLine() {
    final bool isLikeTab = item.type == InteractionType.liked ||
        item.type == InteractionType.iLiked;
    if (isLikeTab) {
      return Row(
        children: [
          _buildActionBadge(),
          const SizedBox(width: 7),
          Text(
            item.timeLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'PingFang SC',
              color: Color(0xFF999999),
              height: 17 / 12,
            ),
          ),
        ],
      );
    }
    return _buildActionBadge();
  }

  Widget _buildTimeLine() {
    return Text(
      item.timeLabel,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'PingFang SC',
        color: Color(0xFF999999),
        height: 17 / 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/moment_detail/${item.postId}'),
      child: SizedBox(
        key: ValueKey<String>('interaction.row.$index'),
        height: _rowHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 11,
              top: 0,
              width: 42,
              height: 42,
              child: SizedBox(
                key: ValueKey<String>('interaction.avatar.$index'),
                width: 42,
                height: 42,
                child: SmartAvatar(
                  radius: 21,
                  source: item.senderAvatarUrl,
                  fallbackName: item.senderName,
                ),
              ),
            ),
            Positioned(
              left: 62,
              top: 0,
              right: _hasTrailing ? 70 : 14,
              child: Text(
                key: ValueKey<String>('interaction.name.$index'),
                item.senderName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'PingFang SC',
                  color: Color(0xFF333333),
                  height: 20 / 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 62,
              top: 25,
              right: _hasTrailing ? 70 : 14,
              child: KeyedSubtree(
                key: ValueKey<String>('interaction.action.$index'),
                child: _buildActionLine(),
              ),
            ),
            if (!item.type.name.contains('liked'))
              Positioned(
                left: 62,
                top: 45,
                child: _buildTimeLine(),
              ),
            if (_hasTrailing)
              Positioned(
                right: 15,
                top: _trailingTop,
                width: 48,
                height: _trailingHeight,
                child: KeyedSubtree(
                  key: ValueKey<String>('interaction.trailing.$index'),
                  child: _buildTrailing(),
                ),
              ),
            if (showDivider)
              Positioned(
                left: 59,
                right: 14.5,
                top: _rowHeight - 10,
                height: 0.5,
                child: DecoratedBox(
                  key: ValueKey<String>('interaction.divider.$index'),
                  decoration: const BoxDecoration(color: Color(0xFFE5E5E5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── 空态 ──────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 96,
          top: 175,
          width: 184,
          height: 184,
          child: Image.asset(
            'assets/images/message/interaction_empty.png',
            key: const ValueKey<String>('interaction_empty_illustration'),
            fit: BoxFit.contain,
          ),
        ),
        const Positioned(
          left: 146,
          top: 358,
          width: 84,
          child: Text(
            '页面啥也没有',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'PingFang SC',
              color: Color(0xFF999999),
              height: 20 / 14,
            ),
          ),
        ),
      ],
    );
  }
}
