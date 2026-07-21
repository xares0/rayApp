import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../repositories/app_repository.dart';

String resolveUserProfileRoute({
  required String userId,
  String? currentUserId,
}) {
  final effectiveCurrentUserId =
      (currentUserId ?? AppRepository.instance.currentUserId).trim();
  if (effectiveCurrentUserId.isNotEmpty && effectiveCurrentUserId == userId) {
    return '/profile';
  }
  return '/user_profile/$userId';
}

void openUserProfile(
  BuildContext context,
  String userId, {
  String? currentUserId,
}) {
  final route = resolveUserProfileRoute(
    userId: userId,
    currentUserId: currentUserId,
  );
  // 自己 → '/profile' 是 ShellRoute 分支。用 push 压入 shell 分支会重复挂载
  // MainSkeleton，触发 Navigator keyReservation 断言崩溃（尤其从全屏视频等
  // shell 外的路由进入时）。故自己走 go（切 Tab，声明式重建），别人走 push。
  if (route == '/profile') {
    context.go(route);
  } else {
    context.push(route);
  }
}
