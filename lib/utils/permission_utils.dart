import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/interaction_utils.dart';

/// 请求麦克风权限。已授权返回 true；被拒绝时提示用户，
/// 永久拒绝时弹窗引导去系统设置开启。
///
/// 所有使用麦克风的入口（语音消息、语音转文字、语音/视频通话）
/// 都必须先调用本方法，确保系统权限弹窗被触发。
Future<bool> ensureMicrophonePermission(
  BuildContext context, {
  required String usage,
}) async {
  final status = await Permission.microphone.request();
  if (status.isGranted) return true;

  if (!context.mounted) return false;
  showAppToast(context, '请先允许麦克风权限');

  if (status.isPermanentlyDenied) {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('麦克风权限'),
        content: Text('需要麦克风权限才能$usage，请前往设置中开启。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }
  return false;
}
