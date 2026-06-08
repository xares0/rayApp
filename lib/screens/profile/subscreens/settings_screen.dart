import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/log_utils.dart';
import '../../../widgets/interaction_utils.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleExitApp(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;
    context.go('/login');
    SystemNavigator.pop();
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('注销账号'),
          content: const Text('确定要注销账号吗？注销后相关数据将无法恢复。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('确定', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    '[delete_account] 账号注销 >>>{"action":"delete"}<<<'.jarLog();

    await ref.read(authProvider.notifier).deleteAccount();
    if (!context.mounted) return;
    context.go('/login');
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realNameState = ref.watch(realNameAuthProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '设置',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _SettingsItem(
            title: '实名认证',
            trailingText:
                realNameState.status == RealNameAuthStatus.pending ? '审核中' : '',
            onTap: () => context.push('/settings/real_name'),
          ),
          _SettingsItem(
            title: '注销账号',
            onTap: () => _handleDeleteAccount(context, ref),
          ),
          _SettingsItem(
            title: '黑名单',
            onTap: () => context.push('/settings/blacklist'),
          ),
          _SettingsItem(
            title: '意见与反馈',
            onTap: () => context.push('/settings/feedback'),
          ),
          _SettingsItem(
            title: '关于我们',
            onTap: () => context.push('/settings/about'),
          ),
          _SettingsItem(
            title: '检查更新',
            onTap: () => showAppToast(context, '当前已是最新版本'),
          ),
          const Spacer(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: () => _handleExitApp(context, ref),
                behavior: HitTestBehavior.opaque,
                child: const Text(
                  '退出登录',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
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

class _SettingsItem extends StatelessWidget {
  final String title;
  final String trailingText;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.title,
    this.trailingText = '',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF222222),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (trailingText.isNotEmpty)
              Text(
                trailingText,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFB8B8B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
