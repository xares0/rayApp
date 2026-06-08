import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/chat_conversation.dart';
import '../models/message.dart';
import '../models/system_notification_item.dart';
import 'auth_provider.dart';
import 'blocked_users_provider.dart';
import '../repositories/app_repository.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatList extends _$ChatList {
  @override
  List<ChatConversation> build() {
    final currentUser = ref.watch(authProvider);
    final blockedUsers = ref.watch(blockedUsersProvider);
    if (currentUser == null) return [];

    final repo = AppRepository.instance;
    final messages = repo.messages.where((message) {
      final participates = message.senderId == currentUser.id ||
          message.receiverId == currentUser.id;
      if (!participates) return false;
      final otherId = message.senderId == currentUser.id
          ? message.receiverId
          : message.senderId;
      if (blockedUsers.contains(otherId)) return false;
      if (repo.isConversationHidden(currentUser.id, otherId)) return false;
      return !message.hiddenForUserIds.contains(currentUser.id);
    }).toList();

    final Map<String, List<Message>> groupedMessages = {};
    for (final message in messages) {
      final otherId = message.senderId == currentUser.id
          ? message.receiverId
          : message.senderId;
      groupedMessages.putIfAbsent(otherId, () => <Message>[]).add(message);
    }

    final conversations = groupedMessages.entries.map((entry) {
      final otherId = entry.key;
      final items = entry.value
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final latestMessage =
          items.last.copyWith(otherUser: repo.getUser(otherId));
      final unreadCount = items.where((message) {
        return message.senderId == otherId &&
            message.receiverId == currentUser.id &&
            !message.isRead;
      }).length;
      return ChatConversation(
        user: repo.getUser(otherId),
        latestMessage: latestMessage,
        unreadCount: unreadCount,
        pinUpdatedAt: repo.getConversationPinUpdatedAt(currentUser.id, otherId),
      );
    }).toList();

    conversations.sort((a, b) {
      final aIsOfficial = repo.isOfficialSupportUser(a.user.id);
      final bIsOfficial = repo.isOfficialSupportUser(b.user.id);
      if (aIsOfficial && !bIsOfficial) {
        return -1;
      }
      if (!aIsOfficial && bIsOfficial) {
        return 1;
      }
      if (a.isPinned && b.isPinned) {
        final pinCompare = b.pinUpdatedAt!.compareTo(a.pinUpdatedAt!);
        if (pinCompare != 0) return pinCompare;
      } else if (a.isPinned && !b.isPinned) {
        return -1;
      } else if (!a.isPinned && b.isPinned) {
        return 1;
      }
      return b.latestMessage.createdAt.compareTo(a.latestMessage.createdAt);
    });
    return conversations;
  }
}

@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<Message> build(String otherUserId) {
    final currentUser = ref.watch(authProvider);
    final blockedUsers = ref.watch(blockedUsersProvider);
    if (currentUser == null) return [];
    if (blockedUsers.contains(otherUserId)) return [];

    final messages = AppRepository.instance.messages
        .where(
          (message) =>
              ((message.senderId == currentUser.id &&
                      message.receiverId == otherUserId) ||
                  (message.senderId == otherUserId &&
                      message.receiverId == currentUser.id)) &&
              !message.hiddenForUserIds.contains(currentUser.id),
        )
        .toList();

    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }
}

@riverpod
class SystemNotifications extends _$SystemNotifications {
  @override
  List<SystemNotificationItem> build() {
    final currentUser = ref.watch(authProvider);
    if (currentUser == null) return [];
    return AppRepository.instance.getSystemNotificationsForUser(currentUser.id);
  }
}
