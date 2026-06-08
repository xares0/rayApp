import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 拍友首页视图样式：瀑布流(双列) / 列表(单列摄影师卡)。
/// 重启 App 不重置 —— 持久化到 SharedPreferences。
enum StyleViewMode { waterfall, list }

const _kStyleViewModeKey = 'style_view_mode';

class StyleViewModeNotifier extends Notifier<StyleViewMode> {
  @override
  StyleViewMode build() {
    // 同步默认瀑布流，异步加载持久化值后再覆盖
    _restore();
    return StyleViewMode.waterfall;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStyleViewModeKey);
    if (raw == StyleViewMode.list.name) {
      state = StyleViewMode.list;
    }
  }

  Future<void> toggle() async {
    final next = state == StyleViewMode.waterfall
        ? StyleViewMode.list
        : StyleViewMode.waterfall;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStyleViewModeKey, next.name);
  }
}

final styleViewModeProvider =
    NotifierProvider<StyleViewModeNotifier, StyleViewMode>(
  StyleViewModeNotifier.new,
);
