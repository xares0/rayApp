import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/user_profile_route.dart';
import '../../models/post.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/interaction_badge_provider.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/category_tab_bar.dart';
import '../../widgets/hi_greet_button.dart';
import '../../widgets/interaction_utils.dart';
import '../../widgets/moment_text.dart';
import '../../widgets/smart_avatar.dart';
import '../../widgets/smart_image.dart';

// Figma 249:140 取样参数
// 卡片：bg #FFF, 圆角18px, 左右margin 14px, 宽347px
// 头像：35x35, 圆角53px, 距左28px
// 用户名：PingFang SC Medium, 14px, #333
// 时间：12px, #C0C0C0
// 内容：14px, #333
// 三图：102x104px, 圆角5.72px, 间距约9px
// 点赞/评论数字：14px, #C0C0C0; 图标16px
// Tab 激活：16px #333 w600; 非激活：14px #666 w400
// 指示器：8x4px, 圆角2.5px, 渐变 #7DDFFF→#DCA0FF
// Banner：高166px, 圆角14px, top 41px
// 拍一拍 logo：78x30px, left 13px, 渐变 #60FCFF→#CC6EFF

/// 动态卡片「Hi」搭讪预设招呼语（与拍友列表一致）。
const String _kDiscoverGreeting = '你的照片很好看，可以教教我怎么拍吗！';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  static const _tabs = ['推荐', '关注', '风景', '人物', '写真'];
  static const _heroBannerAsset =
      'assets/images/style_top/hero_banner_figma.png';
  static const _paipaiTextAsset =
      'assets/images/style_top/paipai_text_figma.png';

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _selectedTabIndex = 0;

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
    setState(() => _isLoadingMore = true);
    await notifier.loadMore();
    if (!mounted) return;
    setState(() => _isLoadingMore = false);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (_selectedTabIndex != 0) return false;
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 140) {
      _loadMore();
    }
    return false;
  }

  /// 点击动态卡片「Hi」搭讪：进入与作者的私聊并自动发送预设招呼语。
  /// 举报/拉黑已迁移至动态详情页（卡片点击进入）。
  void _greetUser(String userId) {
    final uri = Uri(
      path: '/chat/$userId',
      queryParameters: <String, String>{'greeting': _kDiscoverGreeting},
    );
    context.push(uri.toString());
  }

  bool _isFollowingTab() => _selectedTabIndex == 1;

  bool _hasFollowing() {
    final user = ref.read(authProvider);
    if (user == null) return false;
    return AppRepository.instance.getFollowingUsers(user.id).isNotEmpty;
  }

  List<Post> _filterPosts(List<Post> posts) {
    final tab = _tabs[_selectedTabIndex];
    if (tab == '推荐') return posts;
    if (tab == '关注') {
      final user = ref.read(authProvider);
      if (user == null) return [];
      final followingIds = AppRepository.instance
          .getFollowingUsers(user.id)
          .map((u) => u.id)
          .toSet();
      return posts.where((p) => followingIds.contains(p.userId)).toList();
    }
    return posts.where((p) => p.category == tab).toList();
  }

  void _handleHorizontalSwipe(double primaryVelocity) {
    if (primaryVelocity.abs() < 250) return;
    if (primaryVelocity < 0 && _selectedTabIndex < _tabs.length - 1) {
      setState(() => _selectedTabIndex += 1);
      return;
    }
    if (primaryVelocity > 0 && _selectedTabIndex > 0) {
      setState(() => _selectedTabIndex -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagedPosts = ref.watch(homeFeedProvider);
    final allPosts = ref.watch(momentsFeedProvider);
    final usePagedFeed = _selectedTabIndex == 0;
    final posts = _filterPosts(usePagedFeed ? pagedPosts : allPosts);
    final hasMore = usePagedFeed && ref.read(homeFeedProvider.notifier).hasMore;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          // 顶部渐变背景 300px
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: _DiscoverTopBackground(),
          ),
          Positioned(
            left: 0,
            top: 41,
            right: 0,
            height: 166,
            child: _DiscoverHeroBanner(
              key: const ValueKey<String>('discover.heroBanner'),
              assetPath: _heroBannerAsset,
              onTap: () => context.push('/add'),
            ),
          ),
          const Positioned(
            left: 13,
            top: 46,
            width: 78,
            height: 30,
            child: _DiscoverPaipaiLogo(
              key: ValueKey<String>('discover.paipaiLogo'),
              assetPath: _paipaiTextAsset,
            ),
          ),
          Positioned(
            left: 0,
            top: 219.5,
            right: 0,
            height: 32,
            child: _DiscoverTopTabs(
              tabs: _tabs,
              selectedIndex: _selectedTabIndex,
              onTap: (index) {
                setState(() => _selectedTabIndex = index);
              },
            ),
          ),
          Positioned(
            left: 322,
            top: 225,
            width: 16,
            height: 16,
            child: _DiscoverTabNotifyIcon(
              key: const ValueKey<String>('discover.notifyPrimary'),
              assetPath: 'assets/images/discover/icon_notify_primary_figma.svg',
              hasUnread: ref.watch(interactionBadgeProvider),
              onTap: () => context.push('/interaction_notifications'),
            ),
          ),
          Positioned.fill(
            top: 259,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                _handleHorizontalSwipe(details.primaryVelocity ?? 0);
              },
              child: ColoredBox(
                color: const Color(0xFFF7F7F7),
                child: _isFollowingTab() && !_hasFollowing()
                    ? const EmptyFollowingPlaceholder()
                    : posts.isEmpty
                        ? RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 160),
                                Center(
                                  child: Text(
                                    '暂无投稿，去发布第一条吧',
                                    style: TextStyle(
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: _onScrollNotification,
                              child: ListView.separated(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(14, 0, 14, 16),
                                itemCount: posts.length +
                                    ((hasMore || _isLoadingMore) ? 1 : 0),
                                separatorBuilder: (context, index) {
                                  if (index >= posts.length - 1) {
                                    return const SizedBox(height: 8);
                                  }
                                  return const SizedBox(height: 12);
                                },
                                itemBuilder: (context, index) {
                                  if (index >= posts.length) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }
                                  return _buildDiscoverPost(
                                    context,
                                    posts[index],
                                    index,
                                  );
                                },
                              ),
                            ),
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 顶部渐变背景 ──────────────────────────────────────────────
class _DiscoverTopBackground extends StatelessWidget {
  const _DiscoverTopBackground();

  @override
  Widget build(BuildContext context) {
    return const ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.35, -1),
            end: Alignment(0.15, 1),
            colors: [
              Color(0xFFD8CEFF),
              Color(0xFFF9F9F9),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -34,
              top: -62,
              child: _DiscoverBlurBlob(
                width: 218,
                height: 161,
                color: Color(0xFFFFF1B3),
                sigma: 30,
                rotation: -0.16,
              ),
            ),
            Positioned(
              right: -95,
              top: -82,
              child: _DiscoverBlurBlob(
                width: 252,
                height: 142,
                color: Color(0xFFFAB3FF),
                sigma: 41,
                rotation: 0.28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 拍一拍 Logo ───────────────────────────────────────────────
class _DiscoverPaipaiLogo extends StatelessWidget {
  const _DiscoverPaipaiLogo({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 30,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF60FCFF), // Figma #60FCFF
              Color(0xFFCC6EFF), // Figma #CC6EFF
            ],
          ).createShader(bounds);
        },
        child: Image.asset(
          assetPath,
          width: 78,
          height: 30,
          fit: BoxFit.contain,
          alignment: Alignment.topLeft,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────
// Figma: height=166, 圆角14px, "发布动态"按钮在 left=63, top=133, 87x29, 圆角14.5
class _DiscoverHeroBanner extends StatelessWidget {
  const _DiscoverHeroBanner({
    super.key,
    required this.assetPath,
    required this.onTap,
  });

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 166,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Positioned(
              left: 63,
              top: 133,
              width: 87,
              height: 29,
              child: Stack(
                key: const ValueKey<String>('discover.publishButton'),
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/style_top/publish_pill_figma.png',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                  const Center(
                    child: Text(
                      key: ValueKey<String>('discover.publishButtonText'),
                      '发布动态',
                      style: TextStyle(
                        fontFamily: 'PingFang SC',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF524ADD),
                        height: 17 / 12,
                      ),
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
}

// ── 分类 Tab ──────────────────────────────────────────────────
// Figma: 推荐(16px #333 w600), 其余(14px #666 w400)
// 指示器: 8x4px, 圆角2.5, 渐变#7DDFFF→#DCA0FF
// tab 间距约 14px, 左边距 18px（对齐推荐左=26px 减去 padding-left=8 = 18）
class _DiscoverTopTabs extends StatelessWidget {
  const _DiscoverTopTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const tabLefts = [14.0, 60.0, 102.0, 144.0, 186.0];
    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Positioned(
              left: tabLefts[i],
              top: i == selectedIndex ? 1.5 : 3.5,
              width: 40,
              height: 28,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Text(
                  key: ValueKey<String>('discover.tab.$i'),
                  tabs[i],
                  style: TextStyle(
                    color: i == selectedIndex
                        ? const Color(0xFF333333)
                        : const Color(0xFF666666),
                    fontFamily: 'PingFang SC',
                    fontSize: i == selectedIndex ? 16 : 14,
                    fontWeight:
                        i == selectedIndex ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          for (int i = 0; i < tabs.length; i++)
            Positioned(
              left: tabLefts[i] + 12,
              top: 25.5,
              width: 8,
              height: 4,
              child: DecoratedBox(
                key: ValueKey<String>('discover.tabIndicator.$i'),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.5),
                  gradient: i == selectedIndex
                      ? const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF7DDFFF),
                            Color(0xFFDCA0FF),
                          ],
                        )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Blur Blob ─────────────────────────────────────────────────
class _DiscoverBlurBlob extends StatelessWidget {
  const _DiscoverBlurBlob({
    required this.width,
    required this.height,
    required this.color,
    required this.sigma,
    required this.rotation,
  });

  final double width;
  final double height;
  final Color color;
  final double sigma;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
          child: SizedBox(width: width, height: height),
        ),
      ),
    );
  }
}

// ── Post Card 扩展 ────────────────────────────────────────────
extension _DiscoverScreenUi on _DiscoverScreenState {
  Widget _buildDiscoverPost(BuildContext context, Post post, int index) {
    // 示例卡与普通卡的差异仅在版式，内容一律取自真实 post，
    // 保证列表与详情页展示一致。
    final useFigmaSample = _usesFigmaDynamicSample(post);
    final showImages = post.images.take(3).toList();
    final authorName = post.author?.name ?? '未知用户';
    final avatarSource = post.author?.avatarUrl;
    final content = post.content;
    final contentOriginal = post.contentOriginal;
    final timeText = _formatTime(post.createdAt);
    final likesCount = post.likesCount;
    final commentsCount = post.commentsCount;
    final isLiked = post.isLiked;

    if (useFigmaSample) {
      return GestureDetector(
        onTap: () => context.push('/moment_detail/${post.id}'),
        behavior: HitTestBehavior.opaque,
        child: _buildFigmaSamplePostCard(
          context: context,
          post: post,
          index: index,
          authorName: authorName,
          avatarSource: avatarSource,
          content: content,
          contentOriginal: contentOriginal,
          timeText: timeText,
          likesCount: likesCount,
          commentsCount: commentsCount,
          isLiked: isLiked,
          showImages: showImages,
          onLikeTap: () =>
              ref.read(homeFeedProvider.notifier).toggleLike(post.id),
        ),
      );
    }

    return GestureDetector(
      onTap: () => context.push('/moment_detail/${post.id}'),
      behavior: HitTestBehavior.opaque,
      // Figma 卡片: bg #FFF, 圆角 18px
      child: DecoratedBox(
        key: ValueKey<String>('discover.postCard.$index'),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          // Figma 卡片内容: 头像 left=28, top=275 vs 卡片top=259 → 内边距 top=16, left=14
          // 底部留白: top 456-259-229 ≈ bottom 14
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 用户信息行 ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => openUserProfile(context, post.userId),
                    child: SmartAvatar(
                      key: ValueKey<String>('discover.postAvatar.$index'),
                      // Figma 头像: 35x35, 圆角53px
                      radius: 17.5,
                      source: avatarSource,
                      fallbackName: authorName,
                    ),
                  ),
                  const SizedBox(width: 10), // Figma: 69-35-28=6 → ~10px
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 用户名: PingFang SC Medium, 14px, #333
                        Text(
                          key: ValueKey<String>('discover.postName.$index'),
                          authorName,
                          style: const TextStyle(
                            fontFamily: 'PingFang SC',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // 时间: 12px, #C0C0C0
                        Text(
                          key: ValueKey<String>('discover.postTime.$index'),
                          timeText,
                          style: const TextStyle(
                            fontFamily: 'PingFang SC',
                            color: Color(0xFFC0C0C0),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Figma v4：右上角「Hi」搭讪钮（举报/拉黑见动态详情页）
                  GestureDetector(
                    onTap: () => _greetUser(post.userId),
                    behavior: HitTestBehavior.opaque,
                    child: const HiGreetButton(),
                  ),
                ],
              ),

              const SizedBox(height: 10), // Figma: 318-296-12=10

              // ── 内容文字: 14px, #333（译文/原文翻译 + 2 行展开收起）──
              MomentText(
                key: ValueKey<String>('discover.postContent.$index'),
                translated: content,
                original: post.contentOriginal,
                style: const TextStyle(
                  fontFamily: 'PingFang SC',
                  color: Color(0xFF333333),
                  fontSize: 14,
                ),
              ),

              // ── 图片区 ──
              if (showImages.isNotEmpty || post.videoUrl != null) ...[
                const SizedBox(height: 10), // Figma: 344-318-14≈12 → 10
                _buildImageRow(context, post, showImages, index),
              ],

              const SizedBox(height: 12),

              // ── 互动行: 点赞 + 评论, 右对齐 ──
              // Figma: 图标16px, 数字14px #C0C0C0
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
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isLiked
                              ? const Color(0xFFFF4D6A)
                              : const Color(0xFFC0C0C0),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$likesCount',
                          style: const TextStyle(
                            fontFamily: 'PingFang SC',
                            color: Color(0xFFC0C0C0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      // 预留待确认: 评论图标用 chat_bubble_outline 近似 Figma 消息图标
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: Color(0xFFC0C0C0),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$commentsCount',
                        style: const TextStyle(
                          fontFamily: 'PingFang SC',
                          color: Color(0xFFC0C0C0),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _usesFigmaDynamicSample(Post post) {
    return _selectedTabIndex == 0 && (post.id == 'p1' || post.id == 'p2');
  }

  Widget _buildFigmaSamplePostCard({
    required BuildContext context,
    required Post post,
    required int index,
    required String authorName,
    required String? avatarSource,
    required String content,
    required String contentOriginal,
    required String timeText,
    required int likesCount,
    required int commentsCount,
    required bool isLiked,
    required List<String> showImages,
    required VoidCallback onLikeTap,
  }) {
    // vv2 示例卡：与普通动态卡一致采用弹性布局，正文走 MomentText
    // （翻译图标 + 展开/收起 + 双语同显），避免固定高度无法容纳原文。
    return DecoratedBox(
      key: ValueKey<String>('discover.postCard.$index'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 用户信息行（头像 35 + 间距 6 + 昵称/时间 + Hi 搭讪钮）──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => openUserProfile(context, post.userId),
                  child: SmartAvatar(
                    key: ValueKey<String>('discover.postAvatar.$index'),
                    radius: 17.5,
                    source: avatarSource,
                    fallbackName: authorName,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key: ValueKey<String>('discover.postName.$index'),
                        authorName,
                        style: const TextStyle(
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF333333),
                          height: 20 / 14,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        key: ValueKey<String>('discover.postTime.$index'),
                        timeText,
                        style: const TextStyle(
                          fontFamily: 'PingFang SC',
                          color: Color(0xFFC0C0C0),
                          fontSize: 12,
                          height: 17 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Figma v4：卡片右上角为「Hi」搭讪钮（34×34，蓝→紫渐变），非 more 菜单。
                GestureDetector(
                  onTap: () => _greetUser(post.userId),
                  behavior: HitTestBehavior.opaque,
                  child: HiGreetButton(
                    key: ValueKey<String>('discover.postHi.$index'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── 内容文字: 译文/原文翻译 + 2 行展开收起 ──
            MomentText(
              key: ValueKey<String>('discover.postContent.$index'),
              translated: content,
              original: contentOriginal,
              style: const TextStyle(
                fontFamily: 'PingFang SC',
                color: Color(0xFF333333),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            _buildImageRow(context, post, showImages, index),
            const SizedBox(height: 12),
            // ── 互动行: 点赞 + 评论, 右对齐 ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onLikeTap,
                  child: Row(
                    key: ValueKey<String>('discover.postLikeGroup.$index'),
                    children: [
                      if (isLiked)
                        SvgPicture.asset(
                          'assets/images/discover/icon_like_on_figma.svg',
                          width: 16,
                          height: 16,
                          fit: BoxFit.fill,
                        )
                      else
                        const Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: Color(0xFFC0C0C0),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        '$likesCount',
                        style: const TextStyle(
                          fontFamily: 'PingFang SC',
                          color: Color(0xFFC0C0C0),
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Row(
                  key: ValueKey<String>('discover.postCommentGroup.$index'),
                  children: [
                    SvgPicture.asset(
                      'assets/images/discover/icon_comment_figma.svg',
                      width: 16,
                      height: 16,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$commentsCount',
                      style: const TextStyle(
                        fontFamily: 'PingFang SC',
                        color: Color(0xFFC0C0C0),
                        fontSize: 14,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openVideoFeed(BuildContext context, Post post) {
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

  Widget _buildImageRow(
    BuildContext context,
    Post post,
    List<String> showImages,
    int postIndex,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 14) / 3;
        return Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              SizedBox(
                key: ValueKey<String>('discover.postImage.$postIndex.$i'),
                width: itemWidth,
                height: 104,
                child: i < showImages.length ||
                        (i == 0 && post.videoUrl != null)
                    ? GestureDetector(
                        onTap: (i == 0 && post.videoUrl != null)
                            ? () => _openVideoFeed(context, post)
                            : (i < showImages.length
                                ? () => showImagePreview(context, showImages[i])
                                : null),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.72),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              SmartImage(
                                source: i < showImages.length
                                    ? showImages[i]
                                    : 'assets/images/posts/city_night.jpg',
                                fit: BoxFit.cover,
                              ),
                              if (i == 0 && post.videoUrl != null)
                                Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    size: 32,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (i != 2) const SizedBox(width: 7),
            ],
          ],
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

// ── 分类栏右侧通知入口（带红点）──────────────────────────────────
class _DiscoverTabNotifyIcon extends StatelessWidget {
  const _DiscoverTabNotifyIcon({
    super.key,
    required this.assetPath,
    required this.hasUnread,
    required this.onTap,
  });

  final String assetPath;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 16,
        height: 16,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: SvgPicture.asset(
                assetPath,
                width: 16,
                height: 16,
                fit: BoxFit.fill,
              ),
            ),
            if (hasUnread)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4D6A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
