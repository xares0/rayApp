import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 互动通知未读红点状态。
/// 默认 true（有未读）；进入广场互动页后调用 [InteractionBadgeNotifier.clear] 清除。
class InteractionBadgeNotifier extends Notifier<bool> {
  @override
  bool build() => true; // 默认有未读

  /// 进入广场互动页时调用，清除红点。
  void clear() => state = false;

  /// 重置为有未读（如收到新互动时调用）。
  void markUnread() => state = true;
}

final interactionBadgeProvider =
    NotifierProvider<InteractionBadgeNotifier, bool>(
  InteractionBadgeNotifier.new,
);
