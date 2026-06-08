import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/user_profile_route.dart';
import '../../../providers/blocked_users_provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/interaction_utils.dart';
import '../../../widgets/smart_avatar.dart';

class BlacklistScreen extends ConsumerWidget {
  const BlacklistScreen({super.key});

  Future<void> _handleRemove(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            '温馨提示',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '确定要将对方移出黑名单？',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;
    ref.read(blockedUsersProvider.notifier).unblockUser(userId);
    showAppToast(context, '已移出黑名单');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUserIds = ref.watch(blockedUsersProvider).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '黑名单',
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
      body: blockedUserIds.isEmpty
          ? const Center(
              child: Text(
                '暂无黑名单用户',
                style: TextStyle(color: Color(0xFF999999), fontSize: 14),
              ),
            )
          : ListView.separated(
              itemCount: blockedUserIds.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final userId = blockedUserIds[index];
                final user = AppRepository.instance.getUser(userId);
                return SizedBox(
                  height: 76,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openUserProfile(context, user.id),
                        child: SmartAvatar(
                          radius: 22,
                          source: user.avatarUrl,
                          fallbackName: user.name,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            color: Color(0xFF222222),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _handleRemove(context, ref, userId),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFDDF1FF),
                          foregroundColor: const Color(0xFF63B5ED),
                          minimumSize: const Size(72, 34),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          '移出',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
