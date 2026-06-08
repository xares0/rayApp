import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/interaction_utils.dart';
import 'checkin_provider.dart';

const _kDesignW = 375.0;
const _kDesignH = 812.0;

const _kDayRewards = [
  '×1',
  '×2',
  '×3',
  '×4',
  '×5',
  '×6',
  '×7',
];

const _kDayLabels = [
  'Day 1',
  'Day 2',
  'Day 3',
  'Day 4',
  'Day 5',
  'Day 6',
  'Day 7',
];

// ---------- 公开入口 ----------
Future<void> showCheckinDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x8804010A),
    useSafeArea: false,
    builder: (_) => const _CheckinDialogWrapper(),
  );
}

// ---------- 弹窗外壳 ----------
class _CheckinDialogWrapper extends StatelessWidget {
  const _CheckinDialogWrapper();

  @override
  Widget build(BuildContext context) {
    return const Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: _CheckinDialogContent(),
    );
  }
}

// ---------- 弹窗内容（按 Figma 375×812 坐标系缩放）----------
class _CheckinDialogContent extends ConsumerWidget {
  const _CheckinDialogContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(checkinProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / _kDesignW)
            .clamp(0.0, constraints.maxHeight / _kDesignH);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Transform.scale(
                alignment: Alignment.topCenter,
                scale: scale,
                child: SizedBox(
                  width: _kDesignW,
                  height: _kDesignH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Positioned(
                        left: 26,
                        top: 171,
                        width: 323,
                        height: 479,
                        child: _CheckinPanelBackground(
                          key: ValueKey<String>('checkin.panel'),
                        ),
                      ),
                      const Positioned(
                        left: 104.65,
                        top: 146,
                        width: 156.98,
                        height: 89.74,
                        child: _TitleImage(
                          key: ValueKey<String>('checkin.titleImage'),
                        ),
                      ),
                      const Positioned(
                        left: 138,
                        top: 241,
                        width: 100,
                        height: 22,
                        child: FittedBox(
                          key: ValueKey<String>('checkin.resetText'),
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Reset Monday',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontFamily: 'PingFang SC',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 22 / 12,
                            ),
                          ),
                        ),
                      ),
                      stateAsync.when(
                        loading: () => const Positioned(
                          left: 53,
                          top: 287,
                          width: 269,
                          height: 166,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (state) => _RewardLayout(state: state),
                      ),
                      Positioned(
                        left: 118,
                        top: 571,
                        width: 141,
                        height: 42,
                        child: stateAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (state) => _buildCtaButton(
                            context,
                            ref,
                            state,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 323,
                        top: 156,
                        width: 20,
                        height: 20,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCtaButton(
      BuildContext context, WidgetRef ref, CheckinState state) {
    final canSign = state.canSignToday;
    return GestureDetector(
      onTap: canSign
          ? () async {
              await ref.read(checkinProvider.notifier).signIn();
              if (!context.mounted) return;
              // PRD：领取奖励同时关闭弹窗，关闭后 toast「签到成功」
              Navigator.of(context).pop();
              showAppToast(context, '签到成功');
            }
          : null,
      // 立即签到按钮背景切图（Figma 253:4659，橙色胶囊）；已签到态降透明度
      child: Opacity(
        opacity: canSign ? 1 : 0.5,
        child: SizedBox(
          key: const ValueKey<String>('checkin.ctaButton'),
          width: 141,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                top: 2,
                left: 2,
                right: 2,
                bottom: 2,
                child: Image.asset(
                  key: const ValueKey<String>('checkin.ctaImage'),
                  'assets/images/checkin/button.png',
                  fit: BoxFit.fill,
                ),
              ),
              Text(
                key: const ValueKey<String>('checkin.ctaText'),
                canSign ? '立即签到' : '已签到',
                style: const TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 22 / 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CellState { signed, available, future }

class _TitleImage extends StatelessWidget {
  const _TitleImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/checkin/title.png',
      fit: BoxFit.fill,
    );
  }
}

class _CheckinPanelBackground extends StatelessWidget {
  const _CheckinPanelBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/checkin/panel_bg.png',
      fit: BoxFit.fill,
    );
  }
}

class _RewardLayout extends StatelessWidget {
  const _RewardLayout({required this.state});

  final CheckinState state;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _rewardCell(day: 1, left: 52, top: 287, iconLeft: 62, iconTop: 291),
        _rewardCell(
          day: 2,
          left: 137.64,
          top: 288,
          iconLeft: 147,
          iconTop: 291,
        ),
        _rewardCell(
          day: 3,
          left: 222.64,
          top: 288,
          width: 102,
          iconLeft: 246,
          iconTop: 291,
          labelLeft: 246,
          labelTop: 350,
          labelWidth: 55,
        ),
        _rewardCell(
          day: 4,
          left: 52,
          top: 382,
          iconLeft: 62,
          iconTop: 386,
        ),
        _rewardCell(
          day: 5,
          left: 137.64,
          top: 382,
          iconLeft: 146,
          iconTop: 386,
        ),
        _rewardCell(
          day: 6,
          left: 222.64,
          top: 382,
          width: 102,
          iconLeft: 246,
          iconTop: 386,
          rewardLeft: 268,
          rewardTop: 428,
          labelLeft: 242,
          labelTop: 444,
          labelWidth: 64,
        ),
        _daySeven(),
      ],
    );
  }

  Widget _rewardCell({
    required int day,
    required double left,
    required double top,
    required double iconLeft,
    required double iconTop,
    double width = 72,
    double labelLeft = double.nan,
    double labelTop = double.nan,
    double labelWidth = 37,
    double rewardLeft = double.nan,
    double rewardTop = double.nan,
  }) {
    final stateForDay = _stateForDay(day);
    final stateName = stateForDay.name;
    final dim = stateForDay == _CellState.future;
    final resolvedLabelLeft = labelLeft.isNaN ? left + 17.64 : labelLeft;
    final resolvedLabelTop = labelTop.isNaN ? top + 61 : labelTop;
    final resolvedRewardLeft = rewardLeft.isNaN ? left + 29.64 : rewardLeft;
    final resolvedRewardTop = rewardTop.isNaN ? top + 45 : rewardTop;

    return Opacity(
      key: ValueKey<String>('checkin.dayState.$day.$stateName'),
      opacity: dim ? 0.82 : 1,
      child: Stack(
        children: [
          Positioned(
            key: ValueKey<String>('checkin.dayFrame.$day'),
            left: left,
            top: top,
            width: width,
            height: 71,
            child: Image.asset(
              'assets/images/checkin/cell_frame.png',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: iconLeft,
            top: iconTop,
            width: 52,
            height: 52,
            child: Image.asset(
              key: ValueKey<String>('checkin.dayIcon.$day'),
              'assets/images/checkin/camera.png',
            ),
          ),
          Positioned(
            left: resolvedRewardLeft,
            top: resolvedRewardTop,
            width: 18,
            height: 14,
            child: _RewardText(
              _kDayRewards[day - 1],
              key: ValueKey<String>('checkin.reward.$day'),
            ),
          ),
          Positioned(
            left: resolvedLabelLeft,
            top: resolvedLabelTop,
            width: labelWidth,
            height: 20,
            child: _DayLabel(
              _kDayLabels[day - 1],
              key: ValueKey<String>('checkin.dayLabel.$day'),
            ),
          ),
          if (stateForDay == _CellState.signed)
            Positioned(
              left: left + width - 20,
              top: top + 4,
              width: 16,
              height: 16,
              child: _SignedBadge(
                key: ValueKey<String>('checkin.signedBadge.$day'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _daySeven() {
    final stateForDay = _stateForDay(7);
    final stateName = stateForDay.name;
    final dim = stateForDay == _CellState.future;

    return Opacity(
      key: ValueKey<String>('checkin.dayState.7.$stateName'),
      opacity: dim ? 0.82 : 1,
      child: Stack(
        children: [
          Positioned(
            key: const ValueKey<String>('checkin.dayFrame.7'),
            left: 53,
            top: 475,
            width: 269,
            height: 71,
            child: Image.asset(
              'assets/images/checkin/profile_card.png',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: 101,
            top: 477,
            width: 52,
            height: 52,
            child: Image.asset(
              key: const ValueKey<String>('checkin.dayIcon.7'),
              'assets/images/checkin/camera.png',
            ),
          ),
          Positioned(
            left: 205,
            top: 483,
            width: 36,
            height: 36,
            child: Image.asset('assets/images/checkin/nickname_card.png'),
          ),
          const Positioned(
            left: 121,
            top: 520,
            width: 18,
            height: 14,
            child: _RewardText(
              '×7',
              key: ValueKey<String>('checkin.reward.7'),
            ),
          ),
          const Positioned(
            left: 193,
            top: 519,
            width: 66,
            height: 14,
            child: _RewardText('红色昵称一天'),
          ),
          const Positioned(
            left: 156,
            top: 537,
            width: 64,
            height: 20,
            child: _DayLabel(
              'Day 7',
              key: ValueKey<String>('checkin.dayLabel.7'),
            ),
          ),
          if (stateForDay == _CellState.signed)
            const Positioned(
              left: 302,
              top: 479,
              width: 16,
              height: 16,
              child: _SignedBadge(
                key: ValueKey<String>('checkin.signedBadge.7'),
              ),
            ),
        ],
      ),
    );
  }

  _CellState _stateForDay(int day) {
    if (state.signedDays.contains(day)) return _CellState.signed;
    if (state.todayDay == day && state.canSignToday) {
      return _CellState.available;
    }
    return _CellState.future;
  }
}

class _RewardText extends StatelessWidget {
  const _RewardText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      style: const TextStyle(
        fontFamily: 'PingFang SC',
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 14 / 10,
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFFE7A8)],
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: const TextStyle(
            fontFamily: 'PingFang SC',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1257CB),
            height: 14 / 10,
          ),
        ),
      ),
    );
  }
}

class _SignedBadge extends StatelessWidget {
  const _SignedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1257CB),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 12,
        color: Colors.white,
      ),
    );
  }
}
