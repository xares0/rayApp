import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/gift_provider.dart';

// ---------- 持久化 key ----------
const _kCheckinDaysKey = 'checkin_signed_days'; // 已签天数 List<int>
const _kCheckinWeekKey = 'checkin_week_start'; // 本周起始日期字符串
const _kCheckinPopupShownKey = 'checkin_popup_shown_date'; // 今日是否已弹过签到弹窗

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 今天是否还需要自动弹出签到弹窗（每日首次进 App 弹一次）。
final shouldAutoShowCheckinProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final shown = prefs.getString(_kCheckinPopupShownKey);
  return shown != _dateKey(DateTime.now());
});

/// 标记今日已弹过（立即签到 / 关闭弹窗后调用），当日不再弹。
Future<void> markCheckinPopupShownToday() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kCheckinPopupShownKey, _dateKey(DateTime.now()));
}

// ---------- State ----------
class CheckinState {
  const CheckinState({
    required this.signedDays,
    required this.canSignToday,
    this.todayDay, // 1-7，今天是本周第几天（null=未到）
  });

  final Set<int> signedDays; // 已签的 day index（1-7）
  final bool canSignToday;
  final int? todayDay;

  CheckinState copyWith({
    Set<int>? signedDays,
    bool? canSignToday,
    int? todayDay,
  }) {
    return CheckinState(
      signedDays: signedDays ?? this.signedDays,
      canSignToday: canSignToday ?? this.canSignToday,
      todayDay: todayDay ?? this.todayDay,
    );
  }
}

// ---------- Notifier ----------
class CheckinNotifier extends AsyncNotifier<CheckinState> {
  @override
  Future<CheckinState> build() async {
    return _loadState();
  }

  Future<CheckinState> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    // 以本周一为起点
    final weekStart = _getWeekStart(today);
    final savedWeek = prefs.getString(_kCheckinWeekKey);
    final weekKey = _dateKey(weekStart);

    // 如果是新的一周，重置签到记录
    Set<int> signed = {};
    if (savedWeek == weekKey) {
      final rawList = prefs.getStringList(_kCheckinDaysKey) ?? [];
      signed = rawList.map((s) => int.tryParse(s) ?? 0).where((d) => d > 0).toSet();
    }

    // today 是本周第几天（1=周一 … 7=周日）
    final todayDay = today.weekday; // DateTime.weekday: Mon=1, Sun=7
    final alreadySigned = signed.contains(todayDay);

    return CheckinState(
      signedDays: signed,
      canSignToday: !alreadySigned,
      todayDay: todayDay,
    );
  }

  /// 执行签到（今天）
  Future<void> signIn() async {
    final current = state.valueOrNull;
    if (current == null || !current.canSignToday) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final weekStart = _getWeekStart(today);

    final newSigned = {...current.signedDays, today.weekday};
    await prefs.setString(_kCheckinWeekKey, _dateKey(weekStart));
    await prefs.setStringList(
      _kCheckinDaysKey,
      newSigned.map((d) => d.toString()).toList(),
    );

    // 第 N 天签到奖励礼物 *N（来源：签到）
    await ref.read(giftBalanceProvider.notifier).addGifts(today.weekday);

    state = AsyncValue.data(
      current.copyWith(
        signedDays: newSigned,
        canSignToday: false,
      ),
    );
  }

  /// 重置（仅 debug/演示用）
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCheckinDaysKey);
    await prefs.remove(_kCheckinWeekKey);
    state = AsyncValue.data(await _loadState());
  }

  // ---------- helpers ----------
  static DateTime _getWeekStart(DateTime d) {
    return d.subtract(Duration(days: d.weekday - 1));
  }
}

final checkinProvider =
    AsyncNotifierProvider<CheckinNotifier, CheckinState>(CheckinNotifier.new);
