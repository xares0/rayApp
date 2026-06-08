import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../checkin/checkin_dialog.dart';
import '../checkin/checkin_provider.dart';

enum CheckInStatus { claimed, pending, locked }

class CheckInDay {
  const CheckInDay({
    required this.day,
    required this.rewardCount,
    required this.status,
  });

  final int day;
  final int rewardCount;
  final CheckInStatus status;
}

const List<CheckInDay> _mockCheckInDays = [
  CheckInDay(day: 1, rewardCount: 1, status: CheckInStatus.claimed),
  CheckInDay(day: 2, rewardCount: 2, status: CheckInStatus.pending),
  CheckInDay(day: 3, rewardCount: 3, status: CheckInStatus.pending),
  CheckInDay(day: 4, rewardCount: 4, status: CheckInStatus.pending),
  CheckInDay(day: 5, rewardCount: 5, status: CheckInStatus.pending),
  CheckInDay(day: 6, rewardCount: 6, status: CheckInStatus.pending),
  CheckInDay(day: 7, rewardCount: 7, status: CheckInStatus.pending),
];

const _kDesignW = 375.0;
const _kDesignH = 812.0;
const _kBgColor = Color(0xFFF9F9F9);
const _kText333 = Color(0xFF333333);
const _kText999 = Color(0xFF999999);
const _kPurpleHighlight = Color(0xFF7C67D0);
const _kCheckInBtnTextColor = Color(0xFF065684);
const _kCtaPendingStart = Color(0xFFDA99FF);
const _kCtaPendingEnd = Color(0xFFA575FF);

class TaskCenterScreen extends ConsumerWidget {
  const TaskCenterScreen({
    super.key,
    this.checkedInToday,
  });

  final bool? checkedInToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isCheckedIn = checkedInToday ??
        ref.watch(checkinProvider).maybeWhen(
              data: (state) => !state.canSignToday,
              orElse: () => false,
            );

    return Scaffold(
      backgroundColor: _kBgColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = (constraints.maxWidth / _kDesignW)
              .clamp(0.0, constraints.maxHeight / _kDesignH);

          return Align(
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
                    const Positioned.fill(child: ColoredBox(color: _kBgColor)),
                    const Positioned(
                      left: 0,
                      top: 0,
                      width: _kDesignW,
                      height: 300,
                      child: _TopBackground(),
                    ),
                    _SignInBanner(checkedIn: isCheckedIn),
                    const _TaskHeader(),
                    const _SectionTitle(title: '领取权益', top: 242),
                    const Positioned(
                      left: 14,
                      top: 273,
                      width: 347,
                      height: 256,
                      child: _BenefitPanel(
                        key: ValueKey<String>('taskCenter.benefitPanel'),
                      ),
                    ),
                    const _SectionTitle(title: '签到规则', top: 629),
                    const Positioned(
                      left: 32,
                      top: 659,
                      width: 311,
                      height: 56,
                      child: Text(
                        '1、每7天为一个签到周期，每天签到一次\n'
                        '2、签到后可领取当天的签到奖励，连续签7天可获得丰厚大奖。\n'
                        '3、以上礼物永久有效，消耗后数量减1\n'
                        '4、若签到期间出现断签情况，签到进度将重新累计，请注意！',
                        style: TextStyle(
                          fontFamily: 'PingFang SC',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: _kText999,
                          height: 14 / 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopBackground extends StatelessWidget {
  const _TopBackground();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _TaskTopBackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class _TaskTopBackgroundPainter extends CustomPainter {
  const _TaskTopBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF7C9),
          Color(0xFFFCFCFC),
          Color(0xFFF9F9F9),
        ],
        stops: [0, 0.5, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, basePaint);

    final yellow = Paint()
      ..color = const Color(0xFFFFF1B3).withValues(alpha: 0.84)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 46);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(76, -8),
        width: 250,
        height: 180,
      ),
      yellow,
    );

    final pink = Paint()
      ..color = const Color(0xFFFAB3FF).withValues(alpha: 0.72)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 56);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width - 22, 4),
        width: 230,
        height: 160,
      ),
      pink,
    );

    final veil = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.16),
          const Color(0xFFF9F9F9).withValues(alpha: 0.94),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, veil);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TaskHeader extends StatelessWidget {
  const _TaskHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 14,
          top: 62,
          width: 20,
          height: 20,
          child: GestureDetector(
            key: const ValueKey<String>('taskCenter.backButton'),
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _kText333,
              size: 18,
            ),
          ),
        ),
        const Positioned(
          left: 138,
          top: 58,
          width: 100,
          height: 28,
          child: FittedBox(
            key: ValueKey<String>('taskCenter.titleFrame'),
            fit: BoxFit.scaleDown,
            child: Text(
              key: ValueKey<String>('taskCenter.title'),
              '签到有礼',
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontFamily: 'PingFang SC',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: _kText333,
                height: 28 / 20,
              ),
            ),
          ),
        ),
        const Positioned(
          left: 219,
          top: 47,
          width: 132,
          height: 132,
          child: _GiftDecoration(
            key: ValueKey<String>('taskCenter.giftDecoration'),
          ),
        ),
      ],
    );
  }
}

class _SignInBanner extends StatelessWidget {
  const _SignInBanner({required this.checkedIn});

  final bool checkedIn;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      key: const ValueKey<String>('taskCenter.banner'),
      left: 14,
      top: 96,
      width: 347,
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 3,
            top: 0,
            width: 340,
            height: 124,
            child: _BannerBackground(),
          ),
          const Positioned(
            left: 29,
            top: 25,
            width: 150,
            height: 28,
            child: _TodayRewardText(),
          ),
          const Positioned(
            left: 29,
            top: 66,
            width: 110,
            height: 17,
            child: _AccumulatedText(),
          ),
          Positioned(
            left: 230,
            top: 74,
            width: 80,
            height: 25,
            child: _SignInButton(
              key: const ValueKey<String>('taskCenter.signInButton'),
              checkedIn: checkedIn,
              onTap: checkedIn ? null : () => showCheckinDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerBackground extends StatelessWidget {
  const _BannerBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SvgPicture.asset(
          'assets/images/task_center_banner_rect.svg',
          fit: BoxFit.fill,
        ),
        SvgPicture.asset(
          'assets/images/task_center_banner_mask.svg',
          fit: BoxFit.fill,
        ),
      ],
    );
  }
}

class _TodayRewardText extends StatelessWidget {
  const _TodayRewardText();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: '今日签到得 ',
            style: TextStyle(
              fontFamily: 'PingFang SC',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 28 / 14,
            ),
          ),
          TextSpan(
            text: '礼物×1',
            style: TextStyle(
              fontFamily: 'PingFang SC',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _kPurpleHighlight,
              height: 28 / 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccumulatedText extends StatelessWidget {
  const _AccumulatedText();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: '累计获得礼物 ×',
            style: TextStyle(
              fontFamily: 'PingFang SC',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 17 / 12,
            ),
          ),
          TextSpan(
            text: '50',
            style: TextStyle(
              fontFamily: 'PingFang SC',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: _kPurpleHighlight,
              height: 17 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    super.key,
    required this.checkedIn,
    this.onTap,
  });

  final bool checkedIn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      key: const ValueKey<String>('taskCenter.signInButtonBackground'),
      width: 80,
      height: 25,
      decoration: BoxDecoration(
        color: checkedIn ? const Color(0xFFEDEDED) : null,
        borderRadius: BorderRadius.circular(53),
        gradient: checkedIn
            ? null
            : const LinearGradient(
                colors: [Color(0xFF7DDFFF), Color(0xFFDCA0FF)],
              ),
      ),
      alignment: Alignment.center,
      child: Text(
        key: const ValueKey<String>('taskCenter.signInButtonText'),
        checkedIn ? '已签到' : '立即签到',
        style: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: checkedIn ? _kText999 : _kCheckInBtnTextColor,
          height: 22 / 12,
        ),
      ),
    );

    if (checkedIn || onTap == null) return button;
    return GestureDetector(onTap: onTap, child: button);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.top,
  });

  final String title;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 27,
      top: top,
      width: 320.5,
      height: 17,
      child: Row(
        key: ValueKey<String>('taskCenter.section.$title'),
        children: [
          Expanded(
            child: Container(
              height: 0.5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xFFCC73FF)],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF26C9FF), Color(0xFFCC73FF)],
            ).createShader(bounds),
            child: Text(
              key: ValueKey<String>('taskCenter.sectionText.$title'),
              title,
              style: const TextStyle(
                fontFamily: 'PingFang SC',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 17 / 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 0.5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF26C9FF), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitPanel extends StatelessWidget {
  const _BenefitPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8FF),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 17,
            top: 8,
            width: 28,
            height: 20,
            child: _ArrowDecoration(),
          ),
          _dayCard(_mockCheckInDays[0], 17, 43),
          _dayCard(_mockCheckInDays[1], 100, 43),
          _dayCard(_mockCheckInDays[2], 183, 43),
          _dayCard(_mockCheckInDays[3], 266, 43),
          _dayCard(_mockCheckInDays[4], 61, 141),
          _dayCard(_mockCheckInDays[5], 144, 141),
          _dayCard(_mockCheckInDays[6], 227, 141, day7: true),
        ],
      ),
    );
  }

  static Widget _dayCard(
    CheckInDay day,
    double left,
    double top, {
    bool day7 = false,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: 70,
      height: 80,
      child: _CheckInDayCard(
        key: ValueKey<String>('taskCenter.day.${day.day}'),
        day: day,
        day7: day7,
      ),
    );
  }
}

class _CheckInDayCard extends StatelessWidget {
  const _CheckInDayCard({
    super.key,
    required this.day,
    required this.day7,
  });

  final CheckInDay day;
  final bool day7;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 70,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF7DDFFF), Color(0xFFDCA0FF)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 10,
                top: 4,
                width: 52,
                height: 52,
                child: Image.asset('assets/images/checkin/camera.png'),
              ),
              Positioned(
                left: 0,
                top: 35,
                width: 70,
                height: 14,
                child: Text(
                  key: ValueKey<String>('taskCenter.dayReward.${day.day}'),
                  'x${day.rewardCount}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 14 / 10,
                  ),
                ),
              ),
              if (day7)
                const Positioned(
                  right: 4,
                  top: 28,
                  width: 22,
                  height: 30,
                  child: Text(
                    '红色\n昵称\nx1',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PingFang SC',
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFF4141),
                      height: 10 / 8,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          left: -5,
          top: -11,
          width: 24,
          height: 24,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFC7A8FF),
            ),
            child: Center(
              child: Text(
                key: ValueKey<String>('taskCenter.dayLabel.${day.day}'),
                'Day${day.day}',
                style: const TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 10 / 7,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 8,
          top: 53,
          width: 53,
          height: 20,
          child: _CheckInCta(
            key: ValueKey<String>('taskCenter.dayCta.${day.day}'),
            status: day.status,
          ),
        ),
      ],
    );
  }
}

class _CheckInCta extends StatelessWidget {
  const _CheckInCta({super.key, required this.status});

  final CheckInStatus status;

  @override
  Widget build(BuildContext context) {
    final claimed = status == CheckInStatus.claimed;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(53),
        color: claimed ? const Color(0xFFEDEDED) : null,
        gradient: claimed
            ? null
            : const LinearGradient(
                colors: [_kCtaPendingStart, _kCtaPendingEnd]),
      ),
      child: Center(
        child: Text(
          key: ValueKey<String>('taskCenter.dayCtaText.${status.name}'),
          claimed ? '已领取' : '待领取',
          style: TextStyle(
            fontFamily: 'PingFang SC',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: claimed ? _kText999 : Colors.white,
            height: 14 / 10,
          ),
        ),
      ),
    );
  }
}

class _GiftDecoration extends StatelessWidget {
  const _GiftDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/task_center_gift_figma.png',
      width: 132,
      height: 132,
      fit: BoxFit.fill,
    );
  }
}

class _ArrowDecoration extends StatelessWidget {
  const _ArrowDecoration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ArrowPainter());
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;
    for (var i = 0; i < 5; i++) {
      final x = i * 5.0;
      final path = Path()
        ..moveTo(x, 5)
        ..lineTo(x + 4, 10)
        ..lineTo(x, 15);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
