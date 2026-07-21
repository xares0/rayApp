import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/user_profile_route.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blocked_users_provider.dart';
import '../../providers/style_view_mode_provider.dart';
import '../../repositories/app_repository.dart';
import '../../utils/user_format.dart';
import '../../widgets/category_tab_bar.dart';
import '../../widgets/hi_greet_button.dart';
import '../../widgets/smart_image.dart';

/// 拍友卡片「评论/招呼」入口进入会话时自动发送的预设招呼语。
const String _kStyleGreeting = '你的照片很好看，可以教教我怎么拍吗！';

class StyleScreen extends ConsumerStatefulWidget {
  const StyleScreen({super.key});

  @override
  ConsumerState<StyleScreen> createState() => _StyleScreenState();
}

class _StyleScreenState extends ConsumerState<StyleScreen> {
  static const List<String> _tabs = ['推荐', '关注', '风景', '人物', '写真'];
  late final PageController _pageController;
  int _selectedTabIndex = 0;

  /// 已点过「招呼」的拍友 id —— 招呼后图标由「Hi」变为聊天图标。
  final Set<String> _contactedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<User> _filterUsers({
    required List<User> users,
    required String? currentUserId,
    required Set<String> blockedUsers,
    required int tabIndex,
  }) {
    final baseUsers = users.where((user) {
      return user.id != AppRepository.officialSupportUserId &&
          !blockedUsers.contains(user.id);
    }).toList();

    final visibleUsers = currentUserId == null
        ? baseUsers
        : () {
            final withoutSelf =
                baseUsers.where((user) => user.id != currentUserId).toList();
            return withoutSelf.isNotEmpty ? withoutSelf : baseUsers;
          }();

    // 关注 tab(index 1) 只展示已关注用户;推荐/风景/人物/写真 暂无分类字段,mock 显示全部
    if (tabIndex != 1) return visibleUsers;
    if (currentUserId == null) return <User>[];
    final followingIds = AppRepository.instance
        .getFollowingUsers(currentUserId)
        .map((user) => user.id)
        .toSet();
    return visibleUsers
        .where((user) => followingIds.contains(user.id))
        .toList();
  }

  Future<void> _handleTabTap(int index) async {
    if (_selectedTabIndex != index) {
      setState(() {
        _selectedTabIndex = index;
      });
    }

    if (!_pageController.hasClients) return;
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _handlePageChanged(int index) {
    if (_selectedTabIndex == index) return;
    setState(() {
      _selectedTabIndex = index;
    });
  }

  /// 点击拍友卡片「招呼」入口：标记已招呼（图标变聊天），进入私聊并自动发送预设消息。
  void _contactUser(String userId) {
    setState(() => _contactedIds.add(userId));
    final uri = Uri(
      path: '/chat/$userId',
      queryParameters: <String, String>{'greeting': _kStyleGreeting},
    );
    context.push(uri.toString());
  }

  Widget _buildTabPage(List<User> users, int tabIndex, StyleViewMode viewMode) {
    if (tabIndex == 1 && users.isEmpty) {
      return const EmptyFollowingPlaceholder();
    }
    if (users.isEmpty) {
      return const Center(
        child: Text(
          '该分类暂无拍友',
          style: TextStyle(
            color: Color(0xFF999999),
            fontSize: 14,
          ),
        ),
      );
    }
    return SingleChildScrollView(
      key: PageStorageKey<String>('style-tab-$tabIndex-${viewMode.name}'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: viewMode == StyleViewMode.list
          ? _StyleUserList(
              users: users,
              contactedIds: _contactedIds,
              onContact: _contactUser,
            )
          : _StyleUserMasonry(
              users: users,
              contactedIds: _contactedIds,
              onContact: _contactUser,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final blockedUsers = ref.watch(blockedUsersProvider);
    final viewMode = ref.watch(styleViewModeProvider);
    final usersByTab = List<List<User>>.generate(
      _tabs.length,
      (index) => _filterUsers(
        users: AppRepository.instance.users,
        currentUserId: currentUser?.id,
        blockedUsers: blockedUsers,
        tabIndex: index,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: _StyleTopBackground(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 62,
            height: 32,
            child: _StyleTopTabs(
              tabs: _tabs,
              selectedIndex: _selectedTabIndex,
              onTap: _handleTabTap,
              viewMode: viewMode,
              onToggleView: () =>
                  ref.read(styleViewModeProvider.notifier).toggle(),
            ),
          ),
          Positioned.fill(
            top: 98,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                return _buildTabPage(usersByTab[index], index, viewMode);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleTopBackground extends StatelessWidget {
  const _StyleTopBackground();

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
              child: _StyleBlurBlob(
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
              child: _StyleBlurBlob(
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

class _StyleBlurBlob extends StatelessWidget {
  const _StyleBlurBlob({
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
          child: SizedBox(
            width: width,
            height: height,
          ),
        ),
      ),
    );
  }
}

// ── 顶部场景分段：欣赏美景 / 等待开拍 / 立即开拍 ──────────────────────────────
class _StyleSceneSegment extends StatefulWidget {
  const _StyleSceneSegment();

  @override
  State<_StyleSceneSegment> createState() => _StyleSceneSegmentState();
}

class _StyleSceneSegmentState extends State<_StyleSceneSegment> {
  static const List<String> _scenes = ['欣赏美景', '等待开拍', '立即开拍'];
  int _selected = 1; // 默认「等待开拍」（对照 Figma 选中态）

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 14,
          top: 0,
          width: 347,
          height: 35,
          child: DecoratedBox(
            key: const ValueKey<String>('style.sceneSegment'),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.5),
            ),
          ),
        ),
        Positioned(
          left: 14 + _selected * 116,
          top: 1,
          width: 116,
          height: 33,
          child: DecoratedBox(
            key: const ValueKey<String>('style.sceneSelected'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.5),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF7DDFFF), Color(0xFFDCA0FF)],
              ),
            ),
          ),
        ),
        for (int i = 0; i < _scenes.length; i++)
          Positioned(
            left: const [39.0, 155.0, 270.0][i],
            top: 8,
            width: 66,
            height: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _selected = i),
              child: Center(
                child: Text(
                  _scenes[i],
                  key: ValueKey<String>('style.sceneLabel.$i'),
                  style: TextStyle(
                    color:
                        i == _selected ? Colors.white : const Color(0xFF666666),
                    fontFamily: 'PingFang SC',
                    fontSize: 14,
                    fontWeight:
                        i == _selected ? FontWeight.w500 : FontWeight.w400,
                    height: 20 / 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StyleTopTabs extends StatelessWidget {
  const _StyleTopTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    required this.viewMode,
    required this.onToggleView,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final StyleViewMode viewMode;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) {
    const labelLefts = [14.0, 60.0, 102.0, 144.0, 186.0];
    const labelWidths = [38.0, 34.0, 34.0, 34.0, 34.0];

    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          for (int index = 0; index < tabs.length; index++)
            Positioned(
              left: labelLefts[index],
              top: index == selectedIndex ? 0 : 2,
              width: labelWidths[index],
              height: index == selectedIndex ? 22 : 20,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(index),
                child: Text(
                  key: ValueKey<String>('style.tab.$index'),
                  tabs[index],
                  style: TextStyle(
                    color: index == selectedIndex
                        ? const Color(0xFF333333)
                        : const Color(0xFF666666),
                    fontFamily: 'PingFang SC',
                    fontSize: index == selectedIndex ? 16 : 14,
                    fontWeight: index == selectedIndex
                        ? FontWeight.w500
                        : FontWeight.w400,
                    height: (index == selectedIndex ? 22 : 20) /
                        (index == selectedIndex ? 16 : 14),
                  ),
                ),
              ),
            ),
          Positioned(
            left: labelLefts[selectedIndex] + 12,
            top: 24,
            width: 8,
            height: 4,
            child: DecoratedBox(
              key: const ValueKey<String>('style.selectedIndicator'),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.5),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF7DDFFF),
                    Color(0xFFDCA0FF),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: -8,
            width: 44,
            height: 44,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggleView,
              child: Center(
                child: SizedBox(
                  key: const ValueKey<String>('style.viewToggle'),
                  width: 14,
                  height: 14,
                  child: SvgPicture.asset(
                    'assets/images/style/icon_view_toggle_figma.svg',
                    width: 14,
                    height: 14,
                    fit: BoxFit.contain,
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

// ── 瀑布流(双列) ──────────────────────────────────────────────────────────────

class _StyleUserMasonry extends StatelessWidget {
  const _StyleUserMasonry({
    required this.users,
    required this.contactedIds,
    required this.onContact,
  });

  final List<User> users;
  final Set<String> contactedIds;
  final ValueChanged<String> onContact;

  @override
  Widget build(BuildContext context) {
    final leftColumn = <Widget>[];
    final rightColumn = <Widget>[];

    for (int index = 0; index < users.length; index++) {
      final user = users[index];
      final compact = index.isOdd && ((index ~/ 2) % 2 == 0);
      final card = _StyleUserCard(
        user: user,
        compact: compact,
        imageSource: user.avatarUrl,
        displayName: user.name,
        displayAge: ageFromBirthday(user.birthday),
        isFemale: user.gender == 'female',
        contacted: contactedIds.contains(user.id),
        onContact: () => onContact(user.id),
      );

      final targetColumn = index.isEven ? leftColumn : rightColumn;
      if (targetColumn.isNotEmpty) {
        targetColumn.add(SizedBox(height: index.isEven ? 21 : 12));
      }
      targetColumn.add(card);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: leftColumn,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rightColumn,
          ),
        ),
      ],
    );
  }
}

class _StyleUserCard extends StatelessWidget {
  const _StyleUserCard({
    required this.user,
    required this.compact,
    required this.imageSource,
    required this.displayName,
    required this.displayAge,
    required this.isFemale,
    required this.contacted,
    required this.onContact,
  });

  final User user;
  final bool compact;
  final String imageSource;
  final String displayName;
  final int displayAge;
  final bool isFemale;
  final bool contacted;
  final VoidCallback onContact;

  void _openCard(BuildContext context) {
    openUserProfile(context, user.id);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey<String>('style_user_card_${user.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _openCard(context),
      child: SizedBox(
        height: compact ? 166 : 225,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(compact ? 12 : 14),
                  border: Border.all(
                    color: const Color(0xFF545252),
                    width: 0.8,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(compact ? 12 : 14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SmartImage(
                        source: imageSource,
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.78),
                              ],
                              stops: const [0, 0.55, 1],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 54,
              bottom: 44,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: '摄影师：',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: displayName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'PingFang SC',
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: _StyleUserBadge(
                age: displayAge,
                isFemale: isFemale,
                nationality: user.nationality,
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: GestureDetector(
                key: ValueKey<String>('style_chat_button_${user.id}'),
                behavior: HitTestBehavior.opaque,
                onTap: onContact,
                child: HiGreetButton(contacted: contacted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 列表视图(单列摄影师卡 + 3 张图) ───────────────────────────────────────────

class _StyleUserList extends StatelessWidget {
  const _StyleUserList({
    required this.users,
    required this.contactedIds,
    required this.onContact,
  });

  final List<User> users;
  final Set<String> contactedIds;
  final ValueChanged<String> onContact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final user in users) ...[
          _StyleUserListCard(
            user: user,
            contacted: contactedIds.contains(user.id),
            onContact: () => onContact(user.id),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _StyleUserListCard extends StatelessWidget {
  const _StyleUserListCard({
    required this.user,
    required this.contacted,
    required this.onContact,
  });

  final User user;
  final bool contacted;
  final VoidCallback onContact;

  static const List<String> _galleryPool = [
    'docs/v3/列表配图/1.png',
    'docs/v3/列表配图/2.png',
    'docs/v3/列表配图/3.png',
    'docs/v3/列表配图/4.png',
    'docs/v3/列表配图/5.png',
    'docs/v3/列表配图/6.png',
    'docs/v3/列表配图/7.png',
    'docs/v3/列表配图/8.png',
    'docs/v3/列表配图/9.png',
    'docs/v3/列表配图/10.png',
    'docs/v3/列表配图/11.png',
    'docs/v3/列表配图/12.png',
    'docs/v3/列表配图/13.png',
    'docs/v3/列表配图/14.png',
    'docs/v3/列表配图/15.png',
    'docs/v3/列表配图/16.png',
    'docs/v3/列表配图/17.png',
    'docs/v3/列表配图/18.png',
    'docs/v3/列表配图/19.png',
    'docs/v3/列表配图/20.png',
    'docs/v3/列表配图/21.png',
    'docs/v3/列表配图/22.png',
    'docs/v3/列表配图/23.png',
    'docs/v3/列表配图/24.png',
    'docs/v3/列表配图/25.png',
    'docs/v3/列表配图/26.png',
    'docs/v3/列表配图/27.png',
    'docs/v3/列表配图/28.png',
    'docs/v3/列表配图/29.png',
    'docs/v3/列表配图/30.png',
  ];

  bool get _isFemale => user.gender == 'female';

  int get _imageSeed {
    return user.id.codeUnits.fold<int>(
      0,
      (seed, codeUnit) => (seed * 31 + codeUnit) & 0x7fffffff,
    );
  }

  String _galleryImageAt(int index) {
    final imageIndex = (_imageSeed + index * 7) % _galleryPool.length;
    return _galleryPool[imageIndex];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey<String>('style_list_card_${user.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => openUserProfile(context, user.id),
      child: SizedBox(
        height: 138,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 6,
                top: 6,
                width: 116,
                height: 126,
                child: SmartImage(
                  source: user.avatarUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // 在线状态：vv2 需求——首页列表所有用户默认显示在线绿点（不再依赖 isOnline）
              Positioned(
                left: 104,
                top: 12,
                width: 12,
                height: 12,
                child: Container(
                  key: ValueKey<String>('style_list_online_${user.id}'),
                  decoration: BoxDecoration(
                    color: const Color(0xFF44D7B6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
              Positioned(
                left: 130,
                top: 6,
                right: 52,
                height: 20,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '摄影师：'),
                      TextSpan(
                        text: user.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontFamily: 'PingFang SC',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 6,
                child: GestureDetector(
                  key: ValueKey<String>('style_list_chat_button_${user.id}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onContact,
                  child: HiGreetButton(contacted: contacted),
                ),
              ),
              // vv2 列表信息行：性别+国籍 · 年龄 · 身高 · 体重（统一浅紫胶囊；身高/体重未返回不显示）
              Positioned(
                left: 130,
                top: 32,
                right: 8,
                height: 14,
                child: _StyleListInfoRow(user: user, isFemale: _isFemale),
              ),
              Positioned(
                left: 130,
                top: 52,
                right: 6,
                height: 17,
                child: Text(
                  user.bio.isNotEmpty ? user.bio : '社牛属性拉满！刷到就是缘分，快来…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontFamily: 'PingFang SC',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 17 / 12,
                  ),
                ),
              ),
              for (int i = 0; i < 3; i++)
                Positioned(
                  left: 130 + i * 63,
                  top: 75,
                  width: 57,
                  height: 57,
                  child: SmartImage(
                    source: _galleryImageAt(i),
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 列表卡用户信息行（vv2 推荐列表）：性别+国籍 · 年龄 · 身高 · 体重，统一浅紫胶囊。
/// 国籍/身高/体重未返回则该项不显示；性别图标始终随第一颗胶囊展示。
class _StyleListInfoRow extends StatelessWidget {
  const _StyleListInfoRow({required this.user, required this.isFemale});

  final User user;
  final bool isFemale;

  @override
  Widget build(BuildContext context) {
    // 国籍优先显示国旗 emoji，未命中映射时回退中文国名，均无则只显示性别。
    final flag = nationalityFlag(user.nationality);
    final nation = user.nationality?.trim();
    final nationText =
        flag ?? ((nation != null && nation.isNotEmpty) ? nation : null);

    final pills = <Widget>[];

    // 国籍独立胶囊（若有）
    if (nationText != null) {
      pills.add(_StyleInfoPill(text: nationText));
    }

    // 性别 + 年龄胶囊
    pills.add(_StyleInfoPill(
      // leadingIcon: isFemale ? Icons.female : Icons.male,
      // iconColor:
      //     isFemale ? const Color(0xFFFF68B4) : const Color(0xFF67A8FF),
      text: '${ageFromBirthday(user.birthday)}岁',
    ));

    // 极端窄屏/超长字段时整行等比缩小，避免溢出（正常数据下保持原始尺寸）。
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < pills.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            pills[i],
          ],
        ],
      ),
    );
  }
}

/// vv2 推荐列表统一信息胶囊：浅紫底 + 深灰文字，可带前置性别图标。
class _StyleInfoPill extends StatelessWidget {
  const _StyleInfoPill({
    // ignore: unused_element_parameter
    this.leadingIcon,
    // ignore: unused_element_parameter
    this.iconColor,
    this.text,
  });

  final IconData? leadingIcon;
  final Color? iconColor;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final hasIcon = leadingIcon != null;
    final hasText = text != null && text!.isNotEmpty;
    return Container(
      height: 14,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD6A4FF).withOpacity(0.2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIcon) Icon(leadingIcon, size: 10, color: iconColor),
          if (hasIcon && hasText) const SizedBox(width: 2),
          if (hasText)
            Text(
              text!,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontFamily: 'PingFang SC',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 14 / 10,
              ),
            ),
        ],
      ),
    );
  }
}

class _StyleUserBadge extends StatelessWidget {
  const _StyleUserBadge({
    required this.age,
    required this.isFemale,
    this.nationality,
  });

  final int age;
  final bool isFemale;
  final String? nationality; // 国籍（第四次迭代瀑布流新增，未返回不显示）

  @override
  Widget build(BuildContext context) {
    final nation = nationality?.trim();
    final hasNation = nation != null && nation.isNotEmpty;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 性别 & 年龄标签
        Container(
          height: 14,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF323232),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon(
              //   isFemale ? Icons.female : Icons.male,
              //   size: 10,
              //   color: isFemale
              //       ? const Color(0xFFFF7DBA)
              //       : const Color(0xFF6CB8FF),
              // ),
              // const SizedBox(width: 2),
              Text(
                '$age',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        if (hasNation) ...[
          const SizedBox(width: 4),
          // 国籍标签（按UI图：独立紫色背景）
          Container(
            height: 14,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD6A4FF),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text(
                nation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

