import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../checkin/checkin_dialog.dart';
import '../checkin/checkin_provider.dart';

class MainSkeleton extends ConsumerStatefulWidget {
  const MainSkeleton({super.key, required this.child});

  final Widget child;
  static const Color _tabSelectedColor = Color(0xFF333333);
  static const Color _tabUnselectedColor = Color(0xFF8D8D8D);
  static const double _tabBarHeight = 71;

  static const List<_TabItemConfig> _tabItems = <_TabItemConfig>[
    _TabItemConfig(
      label: '拍友',
      route: '/style',
      selectedAsset: 'assets/icons/tab_selected/tab_moments_figma.svg',
      unselectedAsset: 'assets/icons/tab_unselected/tab_moments_figma.svg',
    ),
    _TabItemConfig(
      label: '发现',
      route: '/discover',
      selectedAsset: 'assets/icons/tab_selected/tab_home_figma.svg',
      unselectedAsset: 'assets/icons/tab_unselected/tab_home_figma.svg',
    ),
    _TabItemConfig(
      label: '炫技中心',
      route: '/messages',
      selectedAsset: 'assets/icons/tab_selected/tab_msg_figma.svg',
      unselectedAsset: 'assets/icons/tab_unselected/tab_msg_figma.svg',
    ),
    _TabItemConfig(
      label: '我的',
      route: '/profile',
      selectedAsset: '',
      unselectedAsset: '',
      isProfile: true,
    ),
  ];

  @override
  ConsumerState<MainSkeleton> createState() => _MainSkeletonState();
}

class _MainSkeletonState extends ConsumerState<MainSkeleton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowCheckin());
  }

  /// 每日首次进入 App 自动弹签到弹窗；点立即签到/关闭后当日不再弹。
  Future<void> _maybeShowCheckin() async {
    if (!mounted) return;
    if (ref.read(authProvider) == null) return; // 未登录不弹
    final shouldShow = await ref.read(shouldAutoShowCheckinProvider.future);
    if (!shouldShow || !mounted) return;
    await markCheckinPopupShownToday();
    ref.invalidate(shouldAutoShowCheckinProvider);
    if (!mounted) return;
    await showCheckinDialog(context);
  }

  Widget _tabIcon(String assetPath) {
    return SvgPicture.asset(assetPath, width: 24, height: 24);
  }

  Widget _tabProfileIcon({required bool selected}) {
    final String stateDir = selected ? 'tab_selected' : 'tab_unselected';
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 3.25,
            top: 2.1,
            child: SvgPicture.asset(
              'assets/icons/$stateDir/tab_profile_main_figma.svg',
              width: 17.227,
              height: 20.649,
            ),
          ),
          Positioned(
            left: 4.53,
            top: -0.83,
            child: Transform.rotate(
              angle: 18.78 * math.pi / 180,
              child: SvgPicture.asset(
                'assets/icons/$stateDir/tab_profile_accent_figma.svg',
                width: 13.129,
                height: 15.651,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/style')) return 0;
    if (location.startsWith('/discover')) return 1;
    if (location.startsWith('/messages')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // Default to style
  }

  void _onItemTapped(int index, BuildContext context) {
    context.go(MainSkeleton._tabItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: MainSkeleton._tabBarHeight,
            child: Row(
              children: [
                for (int index = 0;
                    index < MainSkeleton._tabItems.length;
                    index++)
                  Expanded(
                    child: SizedBox(
                      height: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 8),
                        child: _TabBarItem(
                          key: ValueKey<String>(
                            'bottom_tab_${MainSkeleton._tabItems[index].route}',
                          ),
                          label: MainSkeleton._tabItems[index].label,
                          selected: index == selectedIndex,
                          icon: MainSkeleton._tabItems[index].isProfile
                              ? _tabProfileIcon(
                                  selected: index == selectedIndex,
                                )
                              : _tabIcon(
                                  index == selectedIndex
                                      ? MainSkeleton._tabItems[index].selectedAsset
                                      : MainSkeleton._tabItems[index].unselectedAsset,
                                ),
                          onTap: () => _onItemTapped(index, context),
                        ),
                      ),
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

class _TabBarItem extends StatelessWidget {
  const _TabBarItem({
    super.key,
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 24, height: 24, child: Center(child: icon)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: selected
                    ? MainSkeleton._tabSelectedColor
                    : MainSkeleton._tabUnselectedColor,
                fontFamily: 'PingFang SC',
                fontSize: 12,
                height: 17 / 12,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItemConfig {
  const _TabItemConfig({
    required this.label,
    required this.route,
    required this.selectedAsset,
    required this.unselectedAsset,
    this.isProfile = false,
  });

  final String label;
  final String route;
  final String selectedAsset;
  final String unselectedAsset;
  final bool isProfile;
}
