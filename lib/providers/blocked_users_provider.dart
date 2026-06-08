import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockedUsersNotifier extends StateNotifier<Set<String>> {
  BlockedUsersNotifier() : super(<String>{});

  bool isBlocked(String userId) => state.contains(userId);

  void blockUser(String userId) {
    if (state.contains(userId)) return;
    state = <String>{...state, userId};
  }

  void unblockUser(String userId) {
    if (!state.contains(userId)) return;
    final next = <String>{...state};
    next.remove(userId);
    state = next;
  }
}

final blockedUsersProvider =
    StateNotifierProvider<BlockedUsersNotifier, Set<String>>(
  (ref) => BlockedUsersNotifier(),
);
