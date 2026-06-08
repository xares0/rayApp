import 'package:flutter/services.dart';

const widgetChannel = MethodChannel('jarvis_log_channel');

extension LogExtension on String {
  /// jarLog 扩展方法用于统一记录日志
  Future<void> jarLog() async {
    try {
      await widgetChannel.invokeMethod('logjarvis_flutter', this);
    } catch (_) {
      // no-op
    }
  }
}
