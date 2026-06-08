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
  context.push(
    resolveUserProfileRoute(
      userId: userId,
      currentUserId: currentUserId,
    ),
  );
}
