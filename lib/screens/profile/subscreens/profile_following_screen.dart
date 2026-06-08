import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/user_profile_route.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/app_repository.dart';
import '../../../widgets/smart_avatar.dart';

class ProfileFollowingScreen extends ConsumerWidget {
  const ProfileFollowingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final List<User> following = currentUser == null
        ? <User>[]
        : AppRepository.instance.getFollowingUsers(currentUser.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '我的关注',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: following.isEmpty
          ? const Center(
              child: Text(
                '还没有关注任何人',
                style: TextStyle(color: Color(0xFF999999)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: following.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final user = following[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => openUserProfile(
                    context,
                    user.id,
                    currentUserId: currentUser?.id,
                  ),
                  child: Row(
                    children: [
                      SmartAvatar(
                        radius: 24,
                        source: user.avatarUrl,
                        fallbackName: user.name,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.bio,
                              style: const TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
