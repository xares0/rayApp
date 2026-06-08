import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户拥有的礼物数量。来源：签到（checkin 领取后 +N）。
/// 消耗：私聊赠送礼物（-1）。=0 时入口隐藏。
const _kGiftBalanceKey = 'gift_balance';
const _kGiftBalanceDefault = 7; // 对照 vv2「我的礼物 ×7」初始 mock

class GiftBalanceNotifier extends Notifier<int> {
  @override
  int build() {
    _restore();
    return _kGiftBalanceDefault;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_kGiftBalanceKey)) {
      state = prefs.getInt(_kGiftBalanceKey) ?? _kGiftBalanceDefault;
    }
  }

  Future<void> _persist(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGiftBalanceKey, value);
  }

  /// 签到领取礼物
  Future<void> addGifts(int count) async {
    if (count <= 0) return;
    state = state + count;
    await _persist(state);
  }

  /// 赠送一个礼物（数量减 1，不低于 0）
  Future<bool> consumeOne() async {
    if (state <= 0) return false;
    state = state - 1;
    await _persist(state);
    return true;
  }
}

final giftBalanceProvider =
    NotifierProvider<GiftBalanceNotifier, int>(GiftBalanceNotifier.new);
