import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/post.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/interaction_utils.dart';
import '../../widgets/smart_avatar.dart';
import '../../widgets/smart_image.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  static const _pageBackground = Color(0xFFF9F9F9);
  static const _panelBackground = Color(0xFFF6F7F9);
  static const _heroExpandedHeight = 334.0;
  static const _contentOverlap = 22.0;
  static const _followGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7DDFFF), Color(0xFFDCA0FF)],
  );
  static const _chatGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFDA99FF), Color(0xFFA575FF)],
  );

  final ScrollController _scrollController = ScrollController();
  int _selectedImageIndex = 0;
  bool _isFollowing = false;
  bool _showMoreMenu = false;
  bool _showUnfollowDialog = false;
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authProvider);
    if (currentUser != null) {
      _isFollowing =
          AppRepository.instance.isFollowing(currentUser.id, widget.userId);
    }
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldCollapse = _scrollController.hasClients &&
        _scrollController.offset > (_heroExpandedHeight - kToolbarHeight - 54);
    if (shouldCollapse == _isHeaderCollapsed) {
      return;
    }
    setState(() {
      _isHeaderCollapsed = shouldCollapse;
    });
  }

  void _toggleMoreMenu() {
    setState(() {
      _showMoreMenu = !_showMoreMenu;
    });
  }

  Future<void> _handleFollowTap() async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    if (_isFollowing) {
      setState(() {
        _showMoreMenu = false;
        _showUnfollowDialog = true;
      });
      return;
    }

    AppRepository.instance.setFollowing(
      currentUser.id,
      widget.userId,
      following: true,
    );
    setState(() {
      _isFollowing = true;
    });
  }

  void _cancelUnfollow() {
    setState(() {
      _showUnfollowDialog = false;
    });
  }

  void _confirmUnfollow() {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    AppRepository.instance.setFollowing(
      currentUser.id,
      widget.userId,
      following: false,
    );
    setState(() {
      _isFollowing = false;
      _showUnfollowDialog = false;
    });
  }

  Future<void> _handleBlock() async {
    setState(() {
      _showMoreMenu = false;
    });
    final confirmed = await showBlockConfirmDialog(context);
    if (confirmed && mounted) {
      showAppToast(context, '拉黑成功');
      Navigator.of(context).pop();
    }
  }

  void _handleReport() {
    setState(() {
      _showMoreMenu = false;
    });
    // 跳转独立举报页（路由待主程序注册后生效）
    context.push('/report?targetType=user&targetId=${widget.userId}');
  }

  List<String> _heroImages(User user) {
    if (user.portfolioImages.isNotEmpty) {
      return user.portfolioImages;
    }
    return [user.avatarUrl];
  }

  List<Post> _recentPosts(List<Post> posts) {
    return posts.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(profileUserProvider(widget.userId));
    final posts = ref.watch(profilePostsProvider(widget.userId));
    final heroImages = _heroImages(user);
    final selectedImage =
        heroImages[_selectedImageIndex.clamp(0, heroImages.length - 1)];
    final recentPosts = _recentPosts(posts);
    final topInset = MediaQuery.of(context).padding.top;
    final actionColor =
        _isHeaderCollapsed ? const Color(0xFF202020) : Colors.white;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: _pageBackground)),
          CustomScrollView(
            key: const ValueKey('userProfile.scrollView'),
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                expandedHeight: _heroExpandedHeight,
                backgroundColor: Colors.white
                    .withValues(alpha: _isHeaderCollapsed ? 1 : 0.02),
                surfaceTintColor: Colors.transparent,
                shadowColor: const Color(0x12000000),
                elevation: _isHeaderCollapsed ? 0.6 : 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: _HeroIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    color: actionColor,
                    shadow: !_isHeaderCollapsed,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                title: AnimatedOpacity(
                  opacity: _isHeaderCollapsed ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    user.name,
                    style: const TextStyle(
                      color: Color(0xFF202020),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                centerTitle: true,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      key: const ValueKey('userProfile.moreButton'),
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleMoreMenu,
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.more_horiz,
                          color: actionColor,
                          size: 22,
                          shadows: !_isHeaderCollapsed
                              ? const [
                                  Shadow(
                                    color: Color(0x4D000000),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      SizedBox.expand(
                        key: const ValueKey('userProfile.hero'),
                        child: SmartImage(
                          source: selectedImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x12000000),
                              Color(0x00000000),
                              Color(0x12000000),
                            ],
                            stops: [0, 0.58, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          key: const ValueKey('userProfile.heroBlurBand'),
                          height: 92,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x00000000),
                                Color(0x24101010),
                                Color(0x5C101010),
                              ],
                              stops: [0, 0.45, 1],
                            ),
                          ),
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: Container(
                                color: const Color(0x1F101010),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(top: topInset > 24 ? 8 : 0),
                                child: _ProfileThumbnailStrip(
                                  key: const ValueKey('userProfile.thumbnailStrip'),
                                  images: heroImages,
                                  selectedIndex: _selectedImageIndex,
                                  onTap: (index) {
                                    setState(() {
                                      _selectedImageIndex = index;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -_contentOverlap),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Container(
                      key: const ValueKey('userProfile.contentPanel'),
                      decoration: const BoxDecoration(
                        color: _panelBackground,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 26, 14, 20),
                        child: Column(
                          children: [
                            _ProfileIdentityRow(user: user),
                            const SizedBox(height: 14),
                            _ProfileInsightCard(
                              key: const ValueKey('userProfile.insightCard'),
                              bio: user.bio,
                            ),
                            const SizedBox(height: 10),
                            _RecentPostsCard(
                              key: const ValueKey('userProfile.recentPostsCard'),
                              posts: recentPosts,
                              owner: user,
                              onOpenList: () =>
                                  context.push('/user_posts/${widget.userId}'),
                              onOpenPost: (post) =>
                                  context.push('/moment_detail/${post.id}'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showMoreMenu)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _showMoreMenu = false),
              ),
            ),
          Positioned(
            left: 15,
            right: 15,
            bottom: 30 + MediaQuery.of(context).padding.bottom,
            child: Row(
              children: [
                Expanded(
                  child: _FollowActionButton(
                    key: const ValueKey('userProfile.followButton'),
                    isFollowing: _isFollowing,
                    onTap: _handleFollowTap,
                  ),
                ),
                const SizedBox(width: 19),
                Expanded(
                  child: _GradientActionButton(
                    key: const ValueKey('userProfile.chatButton'),
                    label: '技术交流',
                    icon: Icons.forum_outlined,
                    gradient: _chatGradient,
                    onTap: () => context.push('/chat/${widget.userId}'),
                  ),
                ),
              ],
            ),
          ),
          if (_showMoreMenu)
            Positioned(
              top: MediaQuery.of(context).padding.top + 52,
              right: 18,
              child: _ProfileMoreMenu(
                key: const ValueKey('userProfile.moreMenu'),
                onReport: _handleReport,
                onBlock: _handleBlock,
              ),
            ),
          if (_showUnfollowDialog)
            Positioned.fill(
              child: _UnfollowConfirmOverlay(
                key: const ValueKey('userProfile.unfollowDialog'),
                onCancel: _cancelUnfollow,
                onConfirm: _confirmUnfollow,
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.shadow = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Icon(
          icon,
          color: color,
          size: 18,
          shadows: shadow
              ? const [
                  Shadow(
                    color: Color(0x4D000000),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

class _ProfileThumbnailStrip extends StatelessWidget {
  const _ProfileThumbnailStrip({
    super.key,
    required this.images,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              width: selected ? 46 : 43,
              height: selected ? 46 : 43,
              padding: EdgeInsets.all(selected ? 1.2 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: selected
                    ? Border.all(color: const Color(0xFFFFC6A0))
                    : null,
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x80FFFFFF),
                          blurRadius: 4.4,
                          offset: Offset(2, 4),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SmartImage(source: images[index], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileIdentityRow extends StatelessWidget {
  const _ProfileIdentityRow({
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SmartAvatar(
          radius: 17.5,
          source: user.avatarUrl,
          fallbackName: user.name,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            user.name,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ProfileInsightCard extends StatelessWidget {
  const _ProfileInsightCard({
    super.key,
    required this.bio,
  });

  final String bio;

  @override
  Widget build(BuildContext context) {
    final content = bio.trim().isEmpty ? '这个摄影师很懒，还没有填写过心得~' : bio;
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7F0FF),
            Color(0xFFFFFFFF),
          ],
        ),
        border: Border.all(color: const Color(0xFFEADCFD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '摄影心得',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: '：',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPostsCard extends StatelessWidget {
  const _RecentPostsCard({
    super.key,
    required this.posts,
    required this.owner,
    required this.onOpenList,
    required this.onOpenPost,
  });

  final List<Post> posts;
  final User owner;
  final VoidCallback onOpenList;
  final ValueChanged<Post> onOpenPost;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpenList,
      child: Container(
        width: double.infinity,
        height: 214,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '近期投稿',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.375,
                    ),
                  ),
                ),
                GestureDetector(
                  key: const ValueKey('userProfile.recentPostsArrow'),
                  onTap: onOpenList,
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF848484),
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (posts.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    '暂时还没有投稿',
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 158,
                child: Row(
                  children: [
                    for (int index = 0; index < posts.length; index++) ...[
                      Expanded(
                        child: _RecentPostPreview(
                          post: posts[index],
                          owner: owner,
                          onTap: () => onOpenPost(posts[index]),
                        ),
                      ),
                      if (index != posts.length - 1) const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentPostPreview extends StatelessWidget {
  const _RecentPostPreview({
    required this.post,
    required this.owner,
    required this.onTap,
  });

  final Post post;
  final User owner;
  final VoidCallback onTap;

  List<String> _previewSources() {
    final sources = <String>[...post.images];
    for (final image in owner.portfolioImages) {
      if (sources.length >= 3) break;
      sources.add(image);
    }
    while (sources.isNotEmpty && sources.length < 3) {
      sources.add(sources.last);
    }
    return sources.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sources = _previewSources();
    if (sources.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SmartImage(source: sources.first, fit: BoxFit.cover),
            if (post.videoUrl != null)
              Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 18,
                    color: Color(0xFF7F7F7F),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FollowActionButton extends StatelessWidget {
  const _FollowActionButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
  });

  final bool isFollowing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isFollowing) {
      return SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF7C67D0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
          ),
          child: const Text(
            '已关注',
            style: TextStyle(
              color: Color(0xFF7C67D0),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return _GradientActionButton(
      label: '关注',
      icon: Icons.star_border_rounded,
      gradient: _UserProfileScreenState._followGradient,
      onTap: onTap,
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.375,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMoreMenu extends StatelessWidget {
  const _ProfileMoreMenu({
    super.key,
    required this.onReport,
    required this.onBlock,
  });

  final VoidCallback onReport;
  final VoidCallback onBlock;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: 92,
          decoration: BoxDecoration(
            color: const Color(0xB21F1F1F),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MoreMenuItem(label: '举报', onTap: onReport),
              const Divider(height: 1, color: Color(0x4DFFFFFF)),
              _MoreMenuItem(label: '拉黑', onTap: onBlock),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  const _MoreMenuItem({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _UnfollowConfirmOverlay extends StatelessWidget {
  const _UnfollowConfirmOverlay({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x8004010A),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 280,
              height: 164,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF7EEFF),
                    Color(0xFFFFFFFF),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 26,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 22,
                    child: Text(
                      '温馨提示',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 58,
                    child: Text(
                      '是否取关此用户？',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 19,
                    top: 106,
                    width: 110,
                    height: 34,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7C67D0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(54),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        '取消',
                        style: TextStyle(
                          color: Color(0xFF7C67D0),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 152,
                    top: 106,
                    width: 110,
                    height: 34,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(54),
                        gradient: _UserProfileScreenState._chatGradient,
                      ),
                      child: TextButton(
                        onPressed: onConfirm,
                        child: const Text(
                          '确认',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              top: -18,
              child: Transform.rotate(
                angle: 0.42,
                child: Image.asset(
                  'assets/images/dialogs/follow_bell_figma.png',
                  width: 74,
                  height: 74,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
